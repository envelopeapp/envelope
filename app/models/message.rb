class Message
  include Mongoid::Document
  include Mongoid::Timestamps

  # search
  include Tire::Model::Search
  include Tire::Model::Callbacks
  index_name BONSAI_INDEX_NAME

  include Kaminari::MongoidExtension::Criteria
  include Kaminari::MongoidExtension::Document

  mapping do
    indexes :_id, index: :not_analyzed
    indexes :user_id
    indexes :mailbox
    indexes :subject, type: 'string', analyzer: 'snowball', boost: 10
    indexes :text_part, type: 'string', analyzer: 'snowball'
    indexes :participants
    indexes :labels
  end

  # fields
  field :uid, type: Integer
  field :message_id, type: String
  field :subject, type: String
  field :timestamp, type: DateTime
  field :read, type: Boolean
  field :flags, type: Array, default: []
  field :flagged, type: Boolean # TODO remove
  field :full_text_part, type: String
  field :text_part, type: String
  field :full_html_part, type: String
  field :html_part, type: String
  field :sanitized_html, type: String
  field :preview, type: String
  field :raw, type: String

  # indexes
  index({ uid: 1 }, { name: 'uid_index' })
  index({ message_id: 1 }, { name: 'message_id_index' })

  # ancestry
  include Mongoid::Ancestry
  has_ancestry :cache_depth => true

  # attr_accessor
  attr_accessor :account_id

  # callbacks
  after_save :update_mailbox_cache
  before_destroy :clear_labels
  after_destroy :update_mailbox_cache

  # associations
  has_and_belongs_to_many :labels, index: true
  belongs_to :mailbox, index: true
  embeds_many :participants
  embeds_many :attachments

  # validations
  validates_presence_of :timestamp, :read

  # scopes
  default_scope order_by(:timestamp => :desc).includes(:mailbox, :labels)
  scope :read, where(read:true)
  scope :unread, where(read:false)

  # attr_accessor
  attr_accessor :to, :cc, :bcc, :body

  # class methods
  class << self

  end

  # instance methods
  def user_id
    self.mailbox.account.user_id
  end

  def account
    self.mailbox.account
  end

  # Determines if this message has been read
  #
  # @return [Boolean] true if the message has been read, false otherwise
  def read?
    !(%w(seen read) & flags).empty?
  end

  # Determines if this message has not been read
  #
  # @return [Boolean] false if the message has been read, true otherwise
  def unread?
    !read?
  end

  # Determines if this message has been deleted
  #
  # @return [Boolean] true if the message has been deleted, false otherwise
  def deleted?
    !(%w(deleted removed) & flags).empty?
  end

  # Determines if this message has been flagged
  #
  # @return [Boolean] true if the message has been flagged, false otherwise
  def flagged?
    !(%w(flagged) & flags).empty?
  end

  # Determines if this message has been answered
  #
  # @return [Boolean] true if the message has been answered, false otherwise
  def answered?
    !(%w(answered) & flags).empty?
  end

  def mark_as_read!
    self.push(:flags, 'read')
    uid_store('+FLAGS.SILENT', [:Seen])
  end

  def mark_as_unread!
    self.pull(:flags, 'read')
    uid_store('-FLAGS.SILENT', [:Seen])
  end

  def flag!
    self.push(:flags, 'flagged')
    uid_store('+FLAGS.SILENT', [:Flagged])
  end

  def unflag!
    self.pull(:flags, 'flagged')
    uid_store('-FLAGS.SILENT', [:Flagged])
  end

  def move_to_trash!
    uid_copy(self.account.trash_mailbox.location) unless self.account.trash_mailbox.nil?
    uid_store('+FLAGS', [:Deleted])
    self.destroy
  end
  alias :delete! :move_to_trash!

  # Always include certain methods when serializing a message
  def serializable_hash(options = {})
    options = {
      :include => [:account, :mailbox, :labels, :fromers]
    }.update(options)
    super(options)
  end

  def to_indexed_json
    to_json :methods => %w(user_id)
  end

  # private methods
  private
  def uid_store(keys, fields)
    imap = Envelope::IMAP.new(self.account)
    imap.uid_store(self.mailbox, self.uid, keys, fields)
  end

  def uid_copy(destination)
    imap = Envelope::IMAP.new(self.account)
    imap.uid_copy(self.mailbox, self.uid, destination)
  end

  def clear_labels
    self.labels.clear
  end

  def update_mailbox_cache
    self.mailbox.update_unread_messages_counter_cache!
  end
end
