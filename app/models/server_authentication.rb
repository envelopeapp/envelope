class ServerAuthentication
  include Mongoid::Document

  # fields
  field :username, type: String
  field :encrypted_password, type: String

  # associations
  embedded_in :server

  # validations
  validates_presence_of :username
  validates_presence_of :password, :on => :create

  # scopes

  # class methods
  class << self

  end

  # instance methods
  def password=(raw_password)
    self.encrypted_password = Base64.encode64(Base64.encode64(raw_password).encrypt)
  end

  def password
    Base64.decode64(Base64.decode64(self.encrypted_password).decrypt)
  end
end
