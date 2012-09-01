class ApplicationController < ActionController::Base
  layout :layout

  #before_filter :ensure_login

  protect_from_forgery
  include Envelope::Auth

  #rescue_from CanCan::AccessDenied, :with => :rescue_cancan

  # def rescue_cancan
  #   redirect_to login_path, alert:'You are not authorized to access that page!'
  # end

  private
  def layout
    request.xhr? ? nil : 'application'
  end

  # def ensure_login
  #   return redirect_to login_path, :notice => "Please login to continue. New to Envelope? #{view_context.link_to('Sign Up', signup_path)}".html_safe unless logged_in?
  # end
end
