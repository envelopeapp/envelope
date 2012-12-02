class User
  include Mongoid::Document
  include Mongoid::Timestamps

  # fields
  field :first_name, type: String
  field :last_name, type: String
  field :username, type: String
  field :email_address, type: String
  field :password_digest, type: String
  field :reset_password_token, type: String
  field :reset_password_sent_at, type: DateTime
  field :confirmation_token, type: String
  field :confirmation_sent_at, type: DateTime
  field :confirmed_at, type: DateTime

  # secure password
  include ActiveModel::SecurePassword
  has_secure_password

  # callbacks
  after_create { send_confirmation_email }

  # associations
  has_many :accounts, :dependent => :destroy
  has_many :labels, :dependent => :destroy
  has_many :contacts, :dependent => :destroy

  # validations
  validates_uniqueness_of :username, :email_address
  validates_presence_of :name, :username, :email_address, :password, :on => :create
  validates_confirmation_of :password, :on => :create

  # scopes

  # class methods
  class << self

  end

  # instance methods
  # Get a paginated list of all messages in the "inbox" mailboxes for all accounts;.
  # @return [Mongoid::Relation] the message objects
  def inbox_messages
    mailbox_messages('inbox')
  end

  # Get a paginated list of all messages in the "sent" mailboxes for all accounts.
  # @return [Mongoid::Relation] the message objects
  def sent_messages
    mailbox_messages('sent')
  end

  # Get a paginated list of all messages in the "trash" mailboxes for all accounts;.
  # @return [Mongoid::Relation] the message objects
  def trash_messages
    mailbox_messages('trash')
  end

  def name
    [self.first_name, self.last_name].join(' ')
  end

  def name=(value)
    self.first_name, self.last_name = value.split(' ', 2) unless value.nil?
  end

  # Publish a message to this user's queue using Pusher
  #
  # @param [String] event the name of the event to publish
  # @param [Hash] data the data to publish with the event
  def publish(event = 'default_event', data = {})
    unless Rails.env.test? || ENV['SEEDING']
      begin
        Pusher[self.channel].trigger!(event, { user: self, timestamp: Time.now }.merge(data))
      rescue Pusher::Error => e
        Rails.logger.error e
      rescue Exception => e
        Rails.logger.error e
      end
    end
  end

  # The channel name for this user, prefixed with private-
  # See PusherDocs for more informatoin
  #
  # @return [String] the channel name
  def channel
    "private-#{self.id.to_s}"
  end

  # Search elastic search index using tire. Currently we only search messages, but
  # in the future we will want to search contacts, filter by mailbox, etc.
  def search(q, options = {})
    user_id = self._id.to_s

    Message.tire.search(page: options[:page] || 1, per_page: 15, load: true) do
      query do
        string(q) if q.present?
      end
      filter :term, { user_id: user_id }
    end
  end

  # Confirms the user's confirmation_token is correct.
  # If the token is correct, the user is marked as "confirmed"
  # in the database.
  def confirm(confirmation_token)
    return true unless self.confirmed_at.nil?
    return false unless self.confirmation_token == confirmation_token

    return self.update_attributes(confirmed_at:Time.now)
  end

  # Ensures a user has responded to the confirmation email
  def confirmed?
    !confirmed_at.nil?
  end

  # Generates a new, unique password and sends an email to the user
  # with the new password.
  def reset_password!
    generate_token!(:reset_password_token)
    UserMail.delay.reset_password(self._id)
  end

  # Generates a unique token for this user
  # @param [String] column the column for which to generate a token
  # @return [String] the generated token
  def generate_token!(column)
    begin
      token = SecureRandom.urlsafe_base64
    end while User.where(column => token).exists?

    self.send("#{column}=", token)
    self.save!

    token
  end

  # Calls the job to send a user his confirmation email
  def send_confirmation_email
    generate_token!(:confirmation_token)
    UserMailer.delay.confirmation(self._id)
  end

  def mailbox_messages(mailbox_name)
    mailbox_ids = self.accounts.collect{ |account| account.send("#{mailbox_name}_mailbox_id") }.compact
    Message.where(:mailbox_id.in => mailbox_ids)
  end
end
