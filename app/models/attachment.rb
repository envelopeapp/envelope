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
  after_create :write_attachment_to_file

  # attr
  attr_accessor :body

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

  # private methods
  private
  def write_attachment_to_file
    parent = Rails.root.join 'tmp', 'attachments', self.message.user_id, self.message.id
    path = File.join(parent, self.filename)
    FileUtils.mkdir_p(parent)

    self.update_attribute(:path, path)
    File.open(path, 'wb') { |f| f.write(self.body) }
  end
end
