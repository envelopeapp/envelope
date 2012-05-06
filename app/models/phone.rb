class Phone < ActiveRecord::Base
  # associations
  belongs_to :contact, :inverse_of => :phones

  # validations
  validates_presence_of :contact, :label, :phone_number

  # scopes

  # class methods
  class << self

  end

  # instance methods

  # private methods
  private
end
