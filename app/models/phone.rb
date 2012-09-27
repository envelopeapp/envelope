class Phone
  include Mongoid::Document

  # fields
  field :label, type: String
  field :phone_number, type: String

  # associations
  embedded_in :contact

  # validations
  validates_presence_of :label, :phone_number

  # scopes

  # class methods
  class << self

  end

  # instance methods

  # private methods
  private
end
