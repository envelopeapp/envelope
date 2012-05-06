class Mailbox < ActiveRecord::Base
  has_ancestry :cache_depth => true

  # callbacks
  after_create :publish_mailbox_created
  after_destroy :publish_mailbox_destroyed

  # associations
  belongs_to :account
  has_one :user, :through => :account
  has_many :messages, :dependent => :destroy

  # validations
  validates_presence_of :account, :name

  # scopes
  default_scope includes(:account)

  # friendly id
  extend FriendlyId
  friendly_id :sha_location, :use => [:scoped, :slugged], :scope => :account

  # class methods
  class << self

  end

  # instance methods
  def load_messages
    Delayed::Job.enqueue(Jobs::MessageLoader.new(self.id), queue:self.queue_name)
  end

  # returns the mailbox's queue name (prefixed with /) for delayed job
  def queue_name
    ['', self.account.user.id, self.account.slug, self.slug].join('/')
  end

  def queues_remaining
    Delayed::Job.where(queue:self.queue_name, failed_at:nil)
  end

  def unread_messages
    Rails.cache.fetch(unread_messages_cache_key) { self.messages.unread.size }
  end

  def update_unread_messages_counter_cache!
    Rails.cache.delete(unread_messages_cache_key)
    PrivatePub.publish_to self.user.queue_name, :action => 'update_unread_messages_counter', :mailbox => self
  end

  # Always include certain methods when serializing a mailbox
  def serializable_hash(options = {})
    options = {
      :methods => [:queue_name, :unread_messages],
      :include => [:account]
    }.update(options)
    super(options)
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
    cache_key = [self.slug, 'unread_messages'].join('/')
  end

  def publish_mailbox_created
    #PrivatePub.publish_to self.user.queue_name, :action => 'mailbox_created', :mailbox => self
  end

  def publish_mailbox_destroyed
    #PrivatePub.publish_to self.user.queue_name, :action => 'mailbox_destroyed', :mailbox => self
  end

  # returns the UID of the last message received by this client
  def last_seen_uid
    self.messages.order('messages.uid DESC').limit(1).last.try(:uid) || 1
  end

  def check_uid_validity!
    # check the mailbox UIDVALIDITY
    # if UIDVALIDITY value returned by the server differs, the client MUST
    #   - empty the local cache of that mailbox;
    #   - remove any pending "actions" that refer to UIDs in that mailbox and consider them failed
    @imap = Envelope::IMAP.new(self.account)
    imap_uid_validity = @imap.get_uid_validity(self)

    if imap_uid_validity != self.uid_validity
      # empty the local cache of that mailbox
      self.messages.destroy_all

      # remove any pending actions of that mailbox
      Delayed::Job.where(queue:self.queue_name).delete_all

      # set the UIDVALIDITY
      self.uid_validity = imap_uid_validity
      self.update_attribute(:uid_validity, imap_uid_validity)
    end
  end
end
