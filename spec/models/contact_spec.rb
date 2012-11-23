require 'spec_helper'

describe Contact do
  subject { build(:contact, first_name: 'Bill', last_name: 'Jones', emails: [ build(:email, email_address: 'bparticipant@example.com') ]) }

  # assocations
  it { should belong_to(:user) }
  it { should embed_many(:addresses) }
  it { should embed_many(:phones) }
  it { should embed_many(:emails) }

  # validations

  # methods
  describe '.import_from_vcard' do
    it 'creates the temporary directory' do
      tmp = Rails.root.join('tmp', 'uploads')
      FileUtils.rm_rf(tmp)
      lambda { Dir::mkdir(tmp) }.should_not raise_error
    end

    it 'builds a unique temporary path to tmp' do
      path = [Rails.root.join('tmp', 'uploads'), "#{Time.now.to_i.to_s}.vcf"].join('/')
      lambda { File.open(path,  'w+') { |f| f.write('test') } }.should_not raise_error
      FileUtils.rm_rf(path)
    end
  end

  its(:name){ should == 'Bill Jones' }
  its(:first_name){ should == 'Bill' }
  its(:last_name){ should == 'Jones' }
  its(:name_email){ should == 'Bill Jones - bparticipant@example.com' }
end
