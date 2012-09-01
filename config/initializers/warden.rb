# Rails.application.config.middleware.use Warden::Manager do |manager|
#   manager.default_strategies :password
#   manager.failure_app = lambda { |env| SessionsController.action(:new).call(env) }
# end

# Warden::Manager.serialize_into_session do |user|
#   user.id
# end

# Warden::Manager.serialize_from_session do |id|
#   User.find(id)
# end

# Warden::Strategies.add(:password) do
#   def valid?
#     params['login'] && params['password']
#   end

#   def authenticate!
#     user = User.where(['username = :value OR email_address = :value', { value:params['login'] }]).first || Account.find_by_email_address(params['login']).try(:user)
#     if user.try(:authenticate, params['password'])
#       if user.confirmed?
#         success! user
#       else
#         fail 'Your credentials were valid, but your account is not active!'
#       end
#     else
#       fail 'Invalid Login!'
#     end
#   end
# end
