class Message
  include Mongoid::Document
  include Mongoid::Timestamps

  # search
  include Tire::Model::Search
  include Tire::Model::Callbacks
  index_name BONSAI_INDEX_NAME

  mapping do
    indexes :_id, index: :not_analyzed
    indexes :user_id
    indexes :mailbox
    indexes :subject, type: 'string', analyzer: 'snowball', boost: 10
    indexes :text_part, type: 'string', analyzer: 'snowball'
    indexes :participants
    indexes :labels
  end

  # pagination
  include Kaminari::MongoidExtension::Criteria
  include Kaminari::MongoidExtension::Document

  # message helpers
  include Envelope::MessageTools

  # fields
  field :uid, type: Integer
  field :message_id, type: String
  field :subject, type: String
  field :timestamp, type: DateTime
  field :read, type: Boolean
  field :flags, type: Array, default: []
  field :full_text_part, type: String
  field :text_part, type: String
  field :full_html_part, type: String
  field :html_part, type: String
  field :sanitized_html, type: String
  field :raw, type: String

  # mongo indexes
  index({ uid: 1 }, { name: 'uid_index' })
  index({ message_id: 1 }, { name: 'message_id_index' })

  # ancestry
  include Mongoid::Ancestry
  has_ancestry :cache_depth => true

  # callbacks
  before_destroy :clear_labels

  # associations
  has_and_belongs_to_many :labels, index: true
  belongs_to :mailbox, index: true
  embeds_many :participants
  embeds_many :attachments

  # nested attributes
  accepts_nested_attributes_for :participants, :attachments

  # validations
  validates_presence_of :mailbox, :timestamp, :read

  # scopes
  default_scope order_by(:timestamp => :desc).includes(:mailbox, :labels)
  scope :read, where(read:true)
  scope :unread, where(read:false)

  # attr_accessor
  attr_accessor :account_id, :to, :cc, :bcc, :body

  # class methods
  class << self

  end

  # instance methods
  def user_id
    account.user_id
  end

  def account
    self.mailbox.account
  end

  def account_id
    account.id
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

  # Determine if this message is a draft
  #
  # @return [Boolean] true if the message is a draft, false otherwise
  def draft?
    !(%w(draft) & flags).empty?
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

  # Returns a list of all participants; used for as_json
  #
  # @return [Hash] all participants
  [:toers, :fromers, :senders, :ccers, :bccers, :reply_toers].each do |participant_type|
    define_method participant_type do
      self.participants.send(participant_type)
    end
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

  def to_indexed_json
    to_json :methods => %w(user_id)
  end

  def as_json(options = {})
    super(options.merge({
      :only => [ :mailbox_id, :uid, :message_id, :subject, :timestamp, :flags, :text_part, :sanitized_html ],
      :methods => [ :id, :account_id, :read?, :flagged?, :unanswered?, :toers, :fromers, :senders, :ccers, :bccers, :reply_toers ],
      :include => [ :labels, :attachments ]
    }))
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
end
