require 'net/imap'

class Account
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String
  field :email_address, type: String
  field :reply_to_address, type: String, default: -> { email_address }
  field :imap_directory, type: String
  field :last_synced, type: DateTime

  # t.integer  "incoming_server_id"
  # t.integer  "outgoing_server_id"

  # t.string   "imap_directory"
  # t.integer  "inbox_mailbox_id"
  # t.integer  "sent_mailbox_id"
  # t.integer  "junk_mailbox_id"
  # t.integer  "drafts_mailbox_id"
  # t.integer  "trash_mailbox_id"
  # t.integer  "starred_mailbox_id"
  # t.integer  "important_mailbox_id"

  # attr accessible
  attr_accessor :provider, :password

  # associations
  embeds_one :incoming_server, :class_name => 'Server'
  embeds_one :outgoing_server, :class_name => 'Server'
  belongs_to :user
  has_many :mailboxes, :dependent => :destroy
    belongs_to :inbox_mailbox, :class_name => 'Mailbox', :foreign_key => :inbox_mailbox_id
    belongs_to :sent_mailbox, :class_name => 'Mailbox', :foreign_key => :sent_mailbox_id
    belongs_to :junk_mailbox, :class_name => 'Mailbox', :foreign_key => :junk_mailbox_id
    belongs_to :drafts_mailbox, :class_name => 'Mailbox', :foreign_key => :drafts_mailbox_id
    belongs_to :trash_mailbox, :class_name => 'Mailbox', :foreign_key => :trash_mailbox_id
    belongs_to :starred_mailbox, :class_name => 'Mailbox', :foreign_key => :starred_mailbox_id
    belongs_to :important_mailbox, :class_name => 'Mailbox', :foreign_key => :important_mailbox_id

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
    Delayed::Job.enqueue(Jobs::MailboxLoader.new(self._id), queue:self.queue_name)
  end

  # returns the account's queue name (prefixed with /) for delayed job
  def queue_name
    ['', self.user_id, self._id].join('/')
  end

  def queues_remaining
    Delayed::Job.where(queue:self.queue_name, failed_at:nil)
  end

  # private methods
  private
  def inbox_mailbox?(imap_mailbox)
    keywords = [:Inbox]
    imap_mailbox.attr.each{|a| return true if keywords.include?(a)}
    return true if Net::IMAP.decode_utf7(imap_mailbox.name).split(imap_mailbox.delim).last =~ /Inbox/i
    false
  end

  def sent_mailbox?(imap_mailbox)
    keywords = [:Sent, :Delivered]
    imap_mailbox.attr.each{|a| return true if keywords.include?(a)}
    return true if Net::IMAP.decode_utf7(imap_mailbox.name).split(imap_mailbox.delim).last =~ /Sent|Delivered/i
    false
  end

  def junk_mailbox?(imap_mailbox)
    keywords = [:Junk, :Spam]
    imap_mailbox.attr.each{|a| return true if keywords.include?(a)}
    return true if Net::IMAP.decode_utf7(imap_mailbox.name).split(imap_mailbox.delim).last =~ /Junk|Spam/i
    false
  end

  def drafts_mailbox?(imap_mailbox)
    keywords = [:Drafts]
    imap_mailbox.attr.each{|a| return true if keywords.include?(a)}
    return true if Net::IMAP.decode_utf7(imap_mailbox.name).split(imap_mailbox.delim).last =~ /Draft/i
    false
  end

  def trash_mailbox?(imap_mailbox)
    keywords = [:Trash, :Deleted, :Removed]
    imap_mailbox.attr.each{|a| return true if keywords.include?(a)}
    return true if Net::IMAP.decode_utf7(imap_mailbox.name).split(imap_mailbox.delim).last =~ /Trash|Deleted|Removed/i
    false
  end

  def starred_mailbox?(imap_mailbox)
    keywords = [:Starred]
    imap_mailbox.attr.each{|a| return true if keywords.include?(a)}
    return true if Net::IMAP.decode_utf7(imap_mailbox.name).split(imap_mailbox.delim).last =~ /Starred/i
    false
  end

  def important_mailbox?(imap_mailbox)
    keywords = [:Important]
    imap_mailbox.attr.each{|a| return true if keywords.include?(a)}
    return true if Net::IMAP.decode_utf7(imap_mailbox.name).split(imap_mailbox.delim).last =~ /Important/i
    false
  end
end
