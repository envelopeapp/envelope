class Message
  include Mongoid::Document
  include Mongoid::Timestamps

  # search
  include Tire::Model::Search
  include Tire::Model::Callbacks

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
  end unless Rails.env.test?

  # fields
  field :uid, type: Integer
  field :message_id, type: String
  field :subject, type: String, default: '(no subject}'
  field :date, type: DateTime
  field :read, type: Boolean
  field :downloaded, type: Boolean
  field :flagged, type: Boolean
  field :text_part, type: String
  field :html_part, type: String
  field :preview, type: String
  field :raw, type: String

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
  has_and_belongs_to_many :labels
  belongs_to :mailbox
  embeds_many :participants
  embeds_many :attachments

  # validations
  validates_presence_of :date, :read, :downloaded

  # scopes
  default_scope order_by(:date => :desc).includes(:mailbox, :labels)
  scope :read, where(read:true)
  scope :unread, where(read:false)
  scope :downloaded, where(downloaded:true)
  scope :undownloaded, where(downloaded:false)

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

  def unread?
    !self.read?
  end

  def mark_as_read!
    self.update_attributes!(read:true)
    uid_store('+FLAGS.SILENT', [:Seen])
  end

  def mark_as_unread!
    self.update_attributes!(read:false)
    uid_store('-FLAGS.SILENT', [:Seen])
  end

  def flag!
    self.update_attributes(flagged:true)
    uid_store('+FLAGS.SILENT', [:Flagged])
  end

  def unflag!
    self.update_attributes(flagged:false)
    uid_store('-FLAGS.SILENT', [:Flagged])
  end

  def move_to_trash!
    uid_copy(self.account.trash_mailbox.location) unless self.account.trash_mailbox.nil?
    uid_store('+FLAGS', [:Deleted])
    self.destroy
  end

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
