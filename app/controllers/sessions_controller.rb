class SessionsController < ApplicationController
  layout 'full'

  skip_before_filter :ensure_login, :only => [:new, :create]

  def new
    flash.now.alert = warden.message if warden.message.present?
  end

  def create
    warden.authenticate!

    if current_user.accounts.empty?
      redirect_to new_account_path, notice:'Create your first account!'
    else
      redirect_to unified_mailbox_messages_path(:inbox)
    end
  end

  def destroy
    warden.logout
    redirect_to login_url, notice:'Logged out!'
  end
end
