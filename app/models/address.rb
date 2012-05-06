class Address < ActiveRecord::Base
  # associations
  belongs_to :contact, :inverse_of => :addresses

  # validations
  validates_presence_of :contact

  # scopes

  # class methods
  class << self

  end

  # instance methods

  # private methods
  private
end
