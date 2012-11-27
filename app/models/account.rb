class Account
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String
  field :email_address, type: String
  field :reply_to_address, type: String, default: -> { email_address }
  field :imap_directory, type: String
  field :last_synced, type: DateTime

  # attr accessible
  attr_accessor :provider, :password

  # associations
  embeds_one :incoming_server, :class_name => 'Server'
  embeds_one :outgoing_server, :class_name => 'Server'
  belongs_to :user, index: true
  has_many :mailboxes, :dependent => :destroy
    belongs_to :inbox_mailbox, :class_name => 'Mailbox', :foreign_key => :inbox_mailbox_id, index: true
    belongs_to :sent_mailbox, :class_name => 'Mailbox', :foreign_key => :sent_mailbox_id, index: true
    belongs_to :junk_mailbox, :class_name => 'Mailbox', :foreign_key => :junk_mailbox_id, index: true
    belongs_to :drafts_mailbox, :class_name => 'Mailbox', :foreign_key => :drafts_mailbox_id, index: true
    belongs_to :trash_mailbox, :class_name => 'Mailbox', :foreign_key => :trash_mailbox_id, index: true
    belongs_to :starred_mailbox, :class_name => 'Mailbox', :foreign_key => :starred_mailbox_id, index: true
    belongs_to :important_mailbox, :class_name => 'Mailbox', :foreign_key => :important_mailbox_id, index: true

  # validations
  validates_presence_of :user, :incoming_server, :outgoing_server, :name, :email_address

  # callbacks
  after_create :sync!

  # scopes

  # class methods
  class << self

  end

  # instance methods
  def sync!
    AccountWorker.perform_async(self.id)
  end
end
