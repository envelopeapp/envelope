class MessagesController < ApplicationController
  skip_before_filter :verify_authenticity_token

  respond_to :html, :json

  load_and_authorize_resource :account
  load_and_authorize_resource :mailbox, :through => :account
  load_and_authorize_resource :message, :through => :mailbox, :shallow => true, :except => [:create]

  def index
    @messages = @messages.page(params[:page] || 1).per(15)
  end

  def search
    @search = current_user.search(params[:q], page: params[:page])
    @messages = @search.results
    render action: 'index'
  end

  def unified
    @messages = case params[:unified_mailbox]
    when 'inbox'
      current_user.inbox_messages
    when 'sent'
      current_user.sent_messages
    when 'trash'
      current_user.trash_messages
    end

    @messages = @messages.page(params[:page] || 1).per(15)
    render action: 'index'
  end

  def labels
    if params[:label_ids].blank?
      @messages = []
    else
      @labels = current_user.labels.find(params[:label_ids])
      mailbox_ids = current_user.accounts.collect{ |account| account.mailbox_ids }.flatten
      @messages = Message.where(:mailbox_id.in => mailbox_ids).select{ |message| !(@labels & message.labels).empty? }
    end
  end

  def show
    @message.mark_as_read! unless @message.read?
    render layout: false
  end

  def new
    @message.account_id = params[:account_id]

    if params[:message_id].present?
      @parent_message = Message.find(params[:message_id])

      if params[:mode] == 'reply'
        @message.to = @parent_message.fromers.collect{|f| f.email_address}.join(', ')
        @message.subject = "Re: #{@parent_message.subject}"
      elsif params[:mode] == 'reply-all'
        @message.to = @parent_message.fromers.collect{|f| f.email_address}.join(', ')
        @message.cc = @parent_message.ccers.collect{|c| c.email_address}.join(', ')
        @message.bcc = @parent_message.bccers.collect{|b| b.email_address}.join(', ')
        @message.subject = "Re: #{@parent_message.subject}"
      end

      @message.account_id = @parent_message.account._id
      @message.body = (@parent_message.html_part.presence || @parent_message.text_part.presence || '=====')
    end

    respond_to do |format|
      format.html {
        if current_user.accounts.empty?
          redirect_to new_account_path, alert:'You must add an account before you can send a message!'
        else
          render action:'new', layout:'full'
        end
      }
    end
  end

  def unread
    @message = Message.find(params[:message_id])
    @message.mark_as_unread! unless @message.unread?

    render action:'show'
  end

  def toggle_label
    @account = Account.find(params[:account_id])
    @mailbox = @account.mailboxes.find(params[:mailbox_id])
    @message = @mailbox.messages.find(params[:message_id])
    @label = current_user.labels.find(params[:label_id])

    if @message.labels.include?(@label)
      @message.labels.delete(@label)
    else
      @message.labels.push(@label)
    end

    respond_to do |format|
      format.json { render json:{ :label => @label, :message => @message } }
    end
  end

  def create
    params[:message][:attachments] ||= []

    params[:message][:attachments] = params[:message][:attachments].collect do |attachment|
      # Create a temporary storage path
      parent = Rails.root.join 'tmp', 'attachments', current_user.id
      FileUtils.mkdir_p parent

      # Move the file to the tmp path
      path = File.join(parent, attachment.original_filename)
      FileUtils.cp attachment.tempfile.path, path

      { filename: attachment.original_filename, path: path }
    end

    MessageSenderWorker.perform_async(current_user.id, params[:message])
    redirect_to unified_mailbox_messages_path(:inbox)
  end

  def flag
    @account = Account.find(params[:account_id])
    @mailbox = @account.mailboxes.find(params[:mailbox_id])
    @message = @mailbox.messages.find(params[:message_id])

    if @message.flagged?
      @message.unflag!
    else
      @message.flag!
    end

    respond_to do |format|
      format.html { redirect_to account_mailbox_messages_path(@account, @mailbox), notice: 'Flagged' }
      format.js { render json:@message }
    end
  end

  def destroy
    @message.move_to_trash!

    respond_to do |format|
      format.html { redirect_to account_mailbox_messages_path(@account, @mailbox), notice: 'Message was deleted.' }
      format.js { render nothing:true, status: :ok }
    end
  end
end
