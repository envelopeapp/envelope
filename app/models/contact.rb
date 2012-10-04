class Contact
  include Mongoid::Document
  include Mongoid::Timestamps

  field :prefix, type: String
  field :first_name, type: String
  field :middle_name, type: String
  field :last_name, type: String
  field :suffix, type: String
  field :nickname, type: String
  field :title, type: String
  field :department, type: String
  field :birthday, type: Date
  field :notes, type: String

  # associations
  belongs_to :user, index: true
  embeds_many :emails
  embeds_many :phones
  embeds_many :addresses

  # nested attributes
  accepts_nested_attributes_for :emails, :phones, :addresses

  # validations
  validates_presence_of :first_name

  # scopes
  default_scope order_by(:last_name => :asc, :first_name => :asc)

  # attr accessor
  attr_accessor :vcards

  # class methods
  class << self
    def search(q)
      return [] unless q.present?
      Contact.any_of({ 'first_name' => q }, { 'last_name' => q }, { 'emails.email_address' => q })
    end

    def import_from_vcard(user, upload)
      # copy the file to a temporary location
      tmp = Rails.root.join('tmp', 'uploads')
      Dir::mkdir(tmp) unless File.directory?(tmp)

      # build the path
      path = "#{tmp}/#{Time.now.to_i.to_s}.vcf"
      File.open(path, 'w+') { |f| f.write(upload.read) }

      # put it into delayed job
      VcardWorker.perform_async(user.id, path)
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
    [self.name, '-', self.emails.first.try(:email_address)].join(' ')
  end

  # private methods
  private
end
