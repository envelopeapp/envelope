Rails.application.config.middleware.use Warden::Manager do |manager|
  manager.default_strategies :password
  manager.failure_app = lambda { |env| SessionsController.action(:new).call(env) }
end

Warden::Manager.serialize_into_session do |user|
  user._id
end

Warden::Manager.serialize_from_session do |id|
  User.find_by(:id => id)
end

Warden::Strategies.add(:password) do
  def valid?
    params['login'] && params['password']
  end

  def authenticate!
    user = User.or({ :username => params['login'] }, { :email_address => params['login'] }).first || Account.where(email_address: params['login']).first.try(:user)
    if user.try(:authenticate, params['password'])
      if user.confirmed?
        success! user
      else
        fail 'Your credentials were valid, but your account is not active!'
      end
    else
      fail 'Invalid Login!'
    end
  end
end
