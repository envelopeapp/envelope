require 'spec_helper'

describe Mailbox do
  before do
    Envelope::IMAP.any_instance.stub(:uid_store).and_return(true)
    Envelope::IMAP.any_instance.stub(:uid_copy).and_return(true)
  end

  subject { build(:mailbox) }

  # associations
  it { should have_many(:messages) }
  it { should belong_to(:account) }

  # validations
  it { should validate_presence_of(:name) }

  # methods
  describe '#last_seen_uid' do
    it 'returns the last uid' do
      [1040, 1041, 1042].each { |i| create(:message, uid: i, mailbox: subject) }
      subject.last_seen_uid.should == 1042
    end

    it 'returns 1 if there are no messages' do
      subject.last_seen_uid.should == 1
    end
  end
end
