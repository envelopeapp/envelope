module Api
  module V1
    class MessagesController < ApplicationController
      respond_to :json, :xml

      load_and_authorize_resource :account
      load_and_authorize_resource :mailbox, :through => :account
      load_and_authorize_resource :message, :through => :mailbox, :shallow => true

      def index
        @messages = @messages.page(params[:page] || 1).per(15)
        respond_with(@messages)
      end

      def search
        @search = Message.search do
          fulltext params[:q]
          with(:user_id, current_user.id)
          paginate(per_page:15, page:params[:page] || 1)
        end

        @messages = @search.results
        respond_with(@messages, location:nil)
      end

      def unified
        @messages = current_user.send("#{params[:unified_mailbox]}_messages".to_sym).includes(:fromers).page(params[:page] || 1).per(15)
        respond_with(@messages) do |format|
          format.html { render action:'index' }
          format.json
        end
      end

      def labels
        if params[:label_ids].blank?
          @messages = []
        else
          @labels = current_user.labels.find(params[:label_ids])
          @messages = current_user.messages.collect{ |m| m if @labels.all?{|l| m.labels.include?(l)} }.compact
        end

        respond_with(@messages) do |format|
          format.html { render action:'index' }
          format.json
        end
      end

      def show
        @message.mark_as_read! unless @message.read?
        respond_with(@message)
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

          @message.account_id = @parent_message.account.id
          @message.body = (@parent_message.html_part.presence || @parent_message.text_part.presence || '=====')
        end

        respond_with(@message)
      end

      def unread
        @message = Message.find(params[:message_id])
        @message.mark_as_unread! unless @message.unread?
        respond_with(@message)
      end

      def toggle_label
        @account = Account.find(params[:account_id])
        @mailbox = @account.mailboxes.find(params[:mailbox_id])
        @message = @mailbox.messages.find(params[:message_id])
        @label = current_user.labels.find(params[:label_id])

        if @message.labels.include?(@label)
          @message.labels.delete(@label)
          PrivatePub.publish_to current_user.queue_name, :action => 'removed_label', :label => @label, :message => @message
        else
          @message.labels.push(@label)
          PrivatePub.publish_to current_user.queue_name, :action => 'added_label', :label => @label, :message => @message
        end

        respond_with(@label, @message)
      end

      def create
        Delayed::Job.enqueue(Jobs::MessageSender.new(current_user.id, params[:message]))
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

        respond_with(@message)
      end

      def update
        respond_with(@message.update_attributes(params[:message]))
      end

      def destroy
        @message.move_to_trash!
      end
    end
  end
end
