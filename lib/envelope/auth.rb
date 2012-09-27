module Envelope::Auth
  def self.included(controller)
    controller.send :helper_method, :warden, :current_user, :logged_in?
  end

  def current_user
    @current_user ||= User.first#User.find_by(_id: session[:user_id])
  end

  def logged_in?
    !current_user.nil?
  end
end
