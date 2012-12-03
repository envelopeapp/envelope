class AccountsController < ApplicationController
  load_and_authorize_resource :account
  layout 'full'

  def index
    redirect_to new_account_path if current_user.accounts.empty?
    @accounts = current_user.accounts
  end

  def new
    @account.build_incoming_server.build_authentication
    @account.build_outgoing_server.build_authentication
  end

  def create
    @account = Account.new(params[:account])
    @account.user = current_user

    if @account.save
      redirect_to unified_mailbox_messages_path('inbox'), notice: "The #{@account.name} was successfully created! We are importing your email. This can take up to 5 minutes."
    else
      render action: "new"
    end
  end

  def update
    @account = Account.find(params[:id])

    if @account.update_attributes(params[:account])
      redirect_to @account, notice: 'Account was successfully updated.'
    else
      render action: "edit"
    end
  end

  def destroy
    @account = Account.find(params[:id])
    @account.destroy
    redirect_to accounts_url
  end

  def sync
    current_user.accounts.each(&:sync!)
    redirect_to :back, notice: 'Fetching new messages...'
  end
end
