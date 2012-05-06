require 'net/imap'

class Account < ActiveRecord::Base
  # attr accessible
  attr_accessor :provider, :password

  # associations
  belongs_to :incoming_server, :class_name => 'Server', :dependent => :destroy
  belongs_to :outgoing_server, :class_name => 'Server', :dependent => :destroy
  belongs_to :user
  has_many :mailboxes, :dependent => :destroy
    belongs_to :inbox_mailbox, :class_name => 'Mailbox', :dependent => :destroy
    belongs_to :sent_mailbox, :class_name => 'Mailbox', :dependent => :destroy
    belongs_to :junk_mailbox, :class_name => 'Mailbox', :dependent => :destroy
    belongs_to :drafts_mailbox, :class_name => 'Mailbox', :dependent => :destroy
    belongs_to :trash_mailbox, :class_name => 'Mailbox', :dependent => :destroy
    belongs_to :starred_mailbox, :class_name => 'Mailbox', :dependent => :destroy
    belongs_to :important_mailbox, :class_name => 'Mailbox', :dependent => :destroy
  has_many :messages, :through => :mailboxes

  # nested attributes
  accepts_nested_attributes_for :incoming_server
  accepts_nested_attributes_for :outgoing_server

  # validations
  validates_presence_of :incoming_server, :outgoing_server, :user, :name, :email_address

  # callbacks
  after_create :sync!

  # scopes

  # friendly id
  extend FriendlyId
  friendly_id :name, :use => [:scoped, :slugged], :scope => :user_id

  # class methods
  class << self

  end

  # instance methods
  def sync!
    Delayed::Job.enqueue(Jobs::MailboxLoader.new(self.id), queue:self.queue_name)
  end

  # returns the account's queue name (prefixed with /) for delayed job
  def queue_name
    ['', self.user_id, self.slug].join('/')
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
