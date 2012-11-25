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
  its(:name){ should == 'Bill Jones' }
  its(:first_name){ should == 'Bill' }
  its(:last_name){ should == 'Jones' }
  its(:name_email){ should == 'Bill Jones - bparticipant@example.com' }
end
