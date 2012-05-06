class Attachment < ActiveRecord::Base
  # associations
  belongs_to :message

  # validations
  validates_presence_of :message, :file

  # scopes

  # class methods
  class << self

  end

  # instance methods

  # private methods
  private
end
