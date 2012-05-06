class MailboxesController < ApplicationController
  load_and_authorize_resource :account
  load_and_authorize_resource :mailbox, :through => :account

  def create
    @mailbox = Mailbox.new(params[:mailbox])

    if @mailbox.save
      redirect_to @mailbox, notice: 'Mailbox was successfully created.'
    else
      render action: "new"
    end
  end

  def update
    @mailbox = Mailbox.find(params[:id])

    if @mailbox.update_attributes(params[:mailbox])
      redirect_to @mailbox, notice: 'Mailbox was successfully updated.'
    else
      render action: "edit"
    end
  end

  def destroy
    @mailbox = Mailbox.find(params[:id])
    @mailbox.destroy

    redirect_to mailboxes_url
  end

  def sync
    @mailbox.sync!
  end
end
