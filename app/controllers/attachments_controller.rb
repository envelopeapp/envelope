class AttachmentsController < ApplicationController
  respond_to :html, :json

  load_and_authorize_resource :account
  load_and_authorize_resource :mailbox, :through => :account
  load_and_authorize_resource :message, :through => :mailbox, :shallow => true
  load_and_authorize_resource :attachment, :through => :message, :shallow => true

  def index
    respond_with(@attachments)
  end

  def show
    send_file(@attachment.path, filename: @attachment.filename, disposition: 'inline')
  end

  def new
    respond_with(@attachment)
  end

  def edit
    respond_with(@attachment)
  end

  def create
    @attachment = Attachment.new(params[:attachment])

    respond_to do |format|
      if @attachment.save
        format.html { redirect_to @attachment, notice: 'Attachment was successfully created.' }
        format.json { render json: @attachment, status: :created, location: @attachment }
      else
        format.html { render action: "new" }
        format.json { render json: @attachment.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @attachment = Attachment.find(params[:id])

    respond_to do |format|
      if @attachment.update_attributes(params[:attachment])
        format.html { redirect_to @attachment, notice: 'Attachment was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @attachment.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    respond_with(@attachment.destroy)
  end
end
