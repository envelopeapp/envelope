require 'spec_helper'

describe Contact do
  before do
    @contact = create(:contact, first_name:'Bill', last_name:'Jones')
    @email = create(:email, contact:@contact, email_address:'bill@example.com')
  end

  after do
    @contact.destroy
    @email.destroy
  end

  # assocations
  it { should belong_to(:user) }
  it { should have_many(:addresses) }
  it { should have_many(:phones) }
  it { should have_many(:emails) }
  it { should have_many(:participants) }

  # validations

  # methods
  describe 'search' do
    it 'should return the correct records' do
      create(:email, contact:@contact, email_address:'seth@example.com')
      create(:email, contact:@contact, email_address:'lizzie@example.com')
      create(:email, contact:@contact, email_address:'xun@example.com')

      @results = Contact.search('bill@example.com')
      @results.collect{ |r| r.email_address }.should == %w(bill@example.com)

      @results = Contact.search('example')
      @results.collect{ |r| r.email_address }.should == %w(bill@example.com seth@example.com lizzie@example.com xun@example.com)
    end

    it 'should run the correct query' do
      q = 'x'
      Contact.search(q).to_sql.should == Contact.joins(:emails).select('contacts.first_name, contacts.last_name, emails.email_address').where('contacts.first_name LIKE (:q) OR contacts.last_name LIKE (:q) OR emails.email_address LIKE (:q)', { q:"%#{q}%" }).to_sql
    end
  end

  describe 'import_from_vcard' do
    it 'should create the temporary directory, if it doesn\'t exist' do
      tmp = Rails.root.join('tmp', 'uploads')
      FileUtils.rm_rf(tmp)
      lambda { Dir::mkdir(tmp) unless File.directory?(tmp) }.should_not raise_error
    end

    it 'should build a unique temporary path to tmp' do
      path = [Rails.root.join('tmp', 'uploads'), "#{Time.now.to_i.to_s}.vcf"].join('/')
      lambda { File.open(path,  'w+') { |f| f.write('test') } }.should_not raise_error
      FileUtils.rm_rf(path)
    end
  end

  describe 'name' do
    it 'should return the first name and last name' do
      @contact.name.should == [@contact.first_name, @contact.last_name].join(' ')
    end
  end

  describe 'name=' do
    it 'should set the first_name' do
      @contact.name = 'Seth Vargo'
      @contact.first_name.should == 'Seth'
    end

    it 'should set the last_name' do
      @contact.name = 'Seth Vargo'
      @contact.last_name.should == 'Vargo'
    end

    it 'should split the name into two parts' do
      name = 'Seth Vargo'
      @contact.name = name
      @contact.first_name.should == name.split(' ', 2)[0]
      @contact.last_name.should == name.split(' ', 2)[1]
    end
  end

  describe 'name_email' do
    it 'should return `name - email` if joined with emails' do
      @contact = Contact.select('contacts.first_name, contacts.last_name, emails.email_address').where(id:@contact.id).joins(:emails).first
      @contact.name_email.should == [@contact.name, '-', @contact.send(:email_address)].join(' ')
    end

    it 'should return `name - email` if not joined with emails' do
      @contact.name_email.should == [@contact.name, '-', @contact.emails.first.try(:email_address)].join(' ')
    end
  end
end