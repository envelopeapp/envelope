class Participant
  TYPES = %w(to from sender cc bcc reply_to).freeze unless defined?(TYPES)

  include Mongoid::Document

  # fields
  field :participant_type, type: String
  field :name, type: String
  field :email_address, type: String

  # callbacks
  #before_save :find_contact

  # associations
  embedded_in :message
  belongs_to :contact, inverse_of: nil

  # validations
  validates_presence_of :participant_type
  validates_inclusion_of :participant_type, :in => Participant::TYPES

  # scopes
  scope :toers, where(participant_type: 'to')
  scope :fromers, where(participant_type: 'from')
  scope :senders, where(participant_type: 'sender')
  scope :ccers, where(participant_type: 'cc')
  scope :bccers, where(participant_type: 'bcc')
  scope :reply_toers, where(participant_type: 'reply_to')

  # class methods
  class << self

  end

  # instance methods
  def to_s
    if self.contact.present?
      self.contact.name
    else
      self.name.presence || self.email_address
    end
  end

  def serializable_hash(options = {})
    {
      id: self.id,
      participant_type: self.participant_type,
      name: self.name,
      email_address: self.email_address,
      contact: self.contact
    }
  end

  # private methods
  private
  def find_contact
    if contact = self.message.mailbox.account.user.contact_emails.find{ |email| email.email_address == self.email_address }.try(:contact)
      self.name, self.email_address = nil, nil
      self.contact = contact
    end
  end
end
