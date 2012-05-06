class Contact < ActiveRecord::Base
  # associations
  belongs_to :user
  has_many :emails, :inverse_of => :contact
  has_many :phones, :inverse_of => :contact
  has_many :addresses, :inverse_of => :contact
  has_many :participants

  # validations
  #validates_presence_of :emails, :on => :create, :message => "Cannot create a contact with no email"

  # scopes
  default_scope order('first_name', 'last_name')

  # attr accessor
  attr_accessor :vcards

  # nested attributes
  accepts_nested_attributes_for :emails, :reject_if => lambda{|a| a[:email_address].blank?}
  accepts_nested_attributes_for :phones, :reject_if => lambda{|a| a[:phone_number].blank?}
  accepts_nested_attributes_for :addresses

  # class methods
  class << self
    def search(q)
      q ||= ''
      self.joins(:emails).select('contacts.first_name, contacts.last_name, emails.email_address').where('contacts.first_name LIKE (:q) OR contacts.last_name LIKE (:q) OR emails.email_address LIKE (:q)', { q:"%#{q}%" })
    end

    def import_from_vcard(user, upload)
      # copy the file to a temporary location
      tmp = Rails.root.join('tmp', 'uploads')
      Dir::mkdir(tmp) unless File.directory?(tmp)

      # build the path
      path = "#{tmp}/#{Time.now.to_i.to_s}.vcf"
      File.open(path, 'w+') { |f| f.write(upload.read) }

      # put it into delayed job
      Delayed::Job.enqueue(Jobs::ContactImporter.new(user.id, path))
    end
  end

  # instance methods
  def name
    [self.first_name, self.last_name].join(' ')
  end

  def name=(str)
    self.first_name, self.last_name = str.split(' ', 2)
  end

  def name_email
    if self.respond_to?(:email_address)
      [self.name, '-', self.email_address].join(' ')
    else
      [self.name, '-', self.emails.first.try(:email_address)].join(' ')
    end
  end

  # private methods
  private
end
