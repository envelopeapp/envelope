class Participant < ActiveRecord::Base
  TYPES = %w(To From Sender Cc Bcc Reply-To) unless const_defined?("TYPES")

  # callbacks
  #before_save :find_contact

  # associations
  belongs_to :message
  belongs_to :contact
  has_one :mailbox, :through => :message
  has_one :account, :through => :message

  # validations
  validates_presence_of :message, :participant_type
  validates_inclusion_of :participant_type, :in => Participant::TYPES

  # scopes
  scope :toers, where(participant_type:'To')
  scope :fromers, where(participant_type:'From')
  scope :senders, where(participant_type:'Sender')
  scope :ccers, where(participant_type:'Cc')
  scope :bbcers, where(participant_type:'Bcc')
  scope :reply_toers, where(participant_type:'Reply-To')

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

  # private methods
  private
  def find_contact
    if contact = self.account.user.contact_emails.find_by_email_address(self.email_address).try(:contact)
      self.name, self.email_address = nil, nil
      self.contact = contact
    end
  end
end
