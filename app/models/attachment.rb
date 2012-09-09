class Attachment
  include Mongoid::Document

  # fields
  field :filename, type: String
  field :size, type: String

  # associations
  embedded_in :message

  # validations
  validates_presence_of :filename, :size

  # scopes

  # class methods
  class << self

  end

  # instance methods

  # private methods
  private
end
