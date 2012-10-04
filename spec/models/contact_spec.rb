require 'spec_helper'

describe Contact do
  before(:all) do
    @contact = build(:contact, first_name: 'Bill', last_name: 'Jones')
    @email = build(:email, contact: @contact, email_address: 'bill@example.com')
  end

  # assocations
  it { should belong_to(:user) }
  it { should embed_many(:addresses) }
  it { should embed_many(:phones) }
  it { should embed_many(:emails) }

  # validations

  # methods
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
    it 'should return `name - email`' do
      @contact.name_email.should == [@contact.name, '-', @contact.emails.first.try(:email_address)].join(' ')
    end
  end
end
