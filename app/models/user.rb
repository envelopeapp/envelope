class User < ActiveRecord::Base
  has_secure_password

  # callbacks
  after_create { generate_token!(:auth_token) }
  after_create { send_confirmation_email }

  # associations
  has_many :accounts, :dependent => :destroy
  has_many :mailboxes, :through => :accounts
  has_many :messages, :through => :mailboxes
    has_many :inbox_mailboxes, :through => :accounts
      has_many :inbox_messages, :through => :inbox_mailboxes, :class_name => 'Message', :source => :messages
    has_many :sent_mailboxes, :through => :accounts
      has_many :sent_messages, :through => :sent_mailboxes, :class_name => 'Message', :source => :messages
    has_many :trash_mailboxes, :through => :accounts
      has_many :trash_messages, :through => :trash_mailboxes, :class_name => 'Message', :source => :messages
  has_many :labels, :dependent => :destroy
  has_many :contacts, :dependent => :destroy
  has_many :contact_emails, :through => :contacts, :source => :emails, :class_name => 'Email'

  # validations
  validates_uniqueness_of :username, :email_address
  validates_presence_of :name, :username, :email_address, :password, :on => :create
  validates_confirmation_of :password, :on => :create

  # scopes

  # class methods
  class << self

  end

  # instance methods
  def name
    [self.first_name, self.last_name].join(' ')
  end

  def name=(value)
    self.first_name, self.last_name = value.split(' ', 2) unless value.nil?
  end

  def queue_name
    ['', Digest::SHA1.hexdigest([self.id, self.name, self.created_at, self.updated_at].join('/'))].join('/')
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
    Delayed::Job.enqueue(Jobs::UserResetPassword.new(self.id))
  end

  # Generates a unique token for this user. It accepts a `column`
  # argument so that we can have multiple tokens. This method
  # returns the generated token
  def generate_token!(column)
    begin
      token = SecureRandom.urlsafe_base64
    end while User.exists?(column => token)

    self.send("#{column}=", token)
    self.save!

    token
  end

  # Calls the job to send a user his confirmation email
  def send_confirmation_email
    Delayed::Job.enqueue(Jobs::UserConfirmation.new(self.id))
  end
end
