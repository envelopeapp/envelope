class Attachment
  include Mongoid::Document

  # fields
  field :filename, type: String
  field :path, type: String

  # associations
  embedded_in :message

  # validations
  validates_presence_of :filename

  # scopes

  # callbacks

  # class methods
  class << self

  end

  # instance methods
  def serializable_hash(options = {})
    {
      id: self.id,
      filename: self.filename,
      path: self.path
    }
  end
end
