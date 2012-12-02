class UsersController < ApplicationController
  layout 'full'

  skip_before_filter :ensure_login, :only => [:new, :create, :confirm, :forgot_password, :reset_password, :confirmation_email]
  load_and_authorize_resource :user

  def create
    @user = User.new(params[:user])

    if @user.save
      redirect_to confirmation_email_path, notice:"We have sent a confirmation email to <strong>#{@user.email_address}</strong>. Please check your inbox and spam folders."
    else
      render action:'new'
    end
  end

  def confirm
    if @user.confirm(params[:confirmation_token])
      redirect_to login_path, notice:'Your account has been activated. Login to continue.'
    else
      redirect_to login_path, alert:'Your confirmation key was not correct.'
    end
  end

  def forgot_password
    if params[:login].present?
      @user.reset_password! if @user = User.find_by_username(params[:login])
      redirect_to forgot_password_path, notice:'If that account existed, we sent a new password to your email inbox.'
    end
  end

  def reset_password
    unless @user = User.find_by_reset_password_token(params[:reset_password_token])
      redirect_to root_url, notice:'The reset password link you provided has expired.'
    end
  end

  def update
    @user = User.find(params[:id])

    if @user.update_attributes(params[:user])
      redirect_to root_path, notice: 'User was successfully updated.'
    else
      render action:'edit'
    end
  end

  def destroy
    @user = User.find(params[:id])
    @user.destroy

    redirect_to users_url
  end
end
