class Server < ActiveRecord::Base
  # associations
  has_one :account
  has_one :server_authentication, :dependent => :destroy, :inverse_of => :server

  # nested attributes
  accepts_nested_attributes_for :server_authentication

  # validations
  validates_presence_of :address, :port

  # scopes


  # class methods
  class << self

  end

  # instance methods

  # private methods
  private
end
