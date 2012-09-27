class Address
  include Mongoid::Document

  # fields
  field :label, type: String
  field :line_1, type: String
  field :line_2, type: String
  field :city, type: String
  field :state, type: String
  field :country, type: String
  field :zip_code, type: String

  # associations
  embedded_in :contact

  # scopes

  # class methods
  class << self

  end

  # instance methods

  # private methods
  private
end
