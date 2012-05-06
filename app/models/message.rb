class Message < ActiveRecord::Base
  has_ancestry :cache_depth => true

  # searchable
  searchable do
    integer :mailbox_id
    integer :account_id do
      self.account.id
    end
    integer :user_id do
      self.user.id
    end
    text :subject, :boost => 10
    text :preview, :boost => 7
    text :toers, :boost => 5
    text :fromers, :boost => 5
    text :senders, :boost => 5
    text :ccers, :boost => 2
    text :bccers, :boost => 1
    text :text_part
    text :html_part
  end

  # attr_accessor
  attr_accessor :account_id

  # callbacks
  after_save :update_mailbox_cache
  before_destroy :clear_labels
  after_destroy :update_mailbox_cache

  # associations
  has_and_belongs_to_many :labels
  belongs_to :mailbox
  has_one :account, :through => :mailbox
  has_one :user, :through => :account
  has_many :attachments, :dependent => :destroy
  has_many :participants, :dependent => :destroy
    has_many :toers, :class_name => 'Participant', :conditions => { :participant_type => 'To' }
    has_many :fromers, :class_name => 'Participant', :conditions => { :participant_type => 'From' }
    has_many :senders, :class_name => 'Participant', :conditions => { :participant_type => 'Sender' }
    has_many :ccers, :class_name => 'Participant', :conditions => { :participant_type => 'Cc' }
    has_many :bccers, :class_name => 'Participant', :conditions => { :participant_type => 'Bcc' }
    has_many :reply_toers, :class_name => 'Participant', :conditions => { :participant_type => 'Reply-To' }

  # validations
  validates_presence_of :mailbox

  # scopes
  default_scope order('messages.date DESC').includes(:account, :mailbox, :labels, :fromers)
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
