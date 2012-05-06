module Envelope::Auth
  def self.included(controller)
    controller.send :helper_method, :warden, :current_user, :logged_in?
  end

  def warden
    env['warden']
  end

  def current_user
    @current_user ||= warden.user
  end

  def logged_in?
    !current_user.nil?
  end
end