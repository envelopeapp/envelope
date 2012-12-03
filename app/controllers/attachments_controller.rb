class AttachmentsController < ApplicationController
  respond_to :html, :json

  load_and_authorize_resource :account
  load_and_authorize_resource :mailbox, :through => :account
  load_and_authorize_resource :message, :through => :mailbox, :shallow => true
  load_and_authorize_resource :attachment, :through => :message, :shallow => true

  def show
    send_file(@attachment.path, filename: @attachment.filename, disposition: 'inline')
  end
end
