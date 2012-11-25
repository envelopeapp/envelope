class Server
  include Mongoid::Document

  # fields
  field :address, type: String
  field :port, type: Integer
  field :ssl, type: Boolean, default: true
  field :tls, type: Boolean, default: true

  # associations
  embedded_in :account
  embeds_one :authentication, class_name: 'ServerAuthentication'

  # validations
  validates_presence_of :address, :port, :authentication

  # nested attributes
  accepts_nested_attributes_for :authentication

  # scopes

  # class methods
  class << self

  end

  # instance methods

  # private methods
  private
end
