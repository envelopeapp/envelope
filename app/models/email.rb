class Email
  include Mongoid::Document

  # fields
  field :label, type: String
  field :email_address, type: String

  # associations
  embedded_in :contact

  # validations
  validates_presence_of :label, :email_address

  # scopes

  # class methods
  class << self

  end

  # instance methods

  # private methods
  private
end
