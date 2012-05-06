class Label < ActiveRecord::Base
  # Label Colors
  COLORS = [['gray', ''], ['green', 'label-success'], ['yellow', 'label-warning'], ['red', 'label-important'], ['blue', 'label-info'], ['black', 'label-inverse']] unless const_defined?("COLORS")

  # associations
  belongs_to :user
  has_and_belongs_to_many :messages

  # validations
  validates_presence_of :user, :name
  validates_uniqueness_of :name, :scope => :user_id

  # scopes

  # class methods
  class << self

  end

  # instance methods

  # private methods
  private
end
