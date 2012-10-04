require 'spec_helper'

describe Mailbox do
  before do
    Envelope::IMAP.any_instance.stub(:uid_store).and_return(true)
    Envelope::IMAP.any_instance.stub(:uid_copy).and_return(true)
  end

  before(:all) do
    @mailbox = build(:mailbox)
  end

  # associations
  it { should have_many(:messages) }
  it { should belong_to(:account) }

  # validations
  it { should validate_presence_of(:name) }

  # methods
  describe 'last_seen_uid' do
    it 'should get the last uid' do
      3.times { create(:message, mailbox:@mailbox) }
      @mailbox.last_seen_uid.should == @mailbox.messages.order_by(:uid => :desc).limit(1).last.try(:uid)
    end

    it 'should return 1 if there are no messages' do
      @mailbox.last_seen_uid.should == 1
    end
  end
end
