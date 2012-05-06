class ServerAuthentication < ActiveRecord::Base
  # associations
  belongs_to :server, :inverse_of => :server_authentication

  # validations
  validates_presence_of :server, :username
  validates_presence_of :password, :on => :create

  # scopes

  # class methods
  class << self

  end

  # instance methods
  def password=(unencrypted_password)
    unless unencrypted_password.blank?
      self.encrypted_password = encryptor.encrypt_and_sign(unencrypted_password.to_s)
    end
  end

  def password
    unless self.encrypted_password.blank?
      encryptor.decrypt_and_verify(self.encrypted_password.to_s)
    end
  end

  # private methods
  private
  def encryptor
    @@encryptor ||= ActiveSupport::MessageEncryptor.new(Rails.application.config.encryption_key)
  end
end
