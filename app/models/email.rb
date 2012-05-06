class Email < ActiveRecord::Base
  # associations
  belongs_to :contact, :inverse_of => :emails

  # validations
  validates_presence_of :contact, :label, :email_address

  # scopes

  # class methods
  class << self

  end

  # instance methods

  # private methods
  private
end
