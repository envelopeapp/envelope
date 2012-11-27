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
    self.messages.order_by(:uid => :desc).limit(1).first.try(:uid) || 1
  end
end
