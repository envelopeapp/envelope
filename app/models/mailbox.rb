class Mailbox
  include Mongoid::Document

  # fields
  field :name, type: String
  field :location, type: String
  field :flags, type: Array
  field :uid_validity, type: Integer
  field :remote, type: Boolean
  field :last_synced, type: DateTime

  # ancestry
  include Mongoid::Ancestry
  has_ancestry :cache_depth => true

  # callbacks

  # associations
  belongs_to :account, :inverse_of => :mailboxes, index: true
  has_many :messages, :dependent => :destroy

  # validations
  validates_presence_of :account, :name

  # scopes
  default_scope includes(:account)

  # class methods
  class << self

  end

  # instance methods
  # Determines if this mailbox is selectable. Not all IMAP mailboxes
  # are selectable (they may just be  a parent grouping mailbox)
  #
  # @return [Boolean] true if the mailbox is selectable, false otherwise
  def selectable?
    (%w(noselect) & self.flags).empty?
  end

  # Return the UID of the last message received by this client
  #
  # @return [Integer] the last UID
  def last_seen_uid
    self.messages.order_by(:uid => :desc).limit(1).last.try(:uid) || 1
  end

  # returns the mailbox's queue name (prefixed with /) for delayed job
  def queue_name
    ['', self.account.user._id, self.account._id, self._id].join('/')
  end

  def unread_messages
    Rails.cache.fetch(unread_messages_cache_key) { self.messages.unread.size }
  end

  # private methods
  private
  # This method returns the sha1 of the location hash. This is
  # used by friendly-id for generating nice urls, since we could
  # have inifinite ancestry depth for mailboxes, this was easier
  def sha_location
    Digest::SHA1.hexdigest(self.location.to_s)
  end

  def unread_messages_cache_key
    cache_key = [self._id, 'unread_messages'].join('/')
  end
end
