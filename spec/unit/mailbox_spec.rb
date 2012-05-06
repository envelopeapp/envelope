require 'spec_helper'

describe Mailbox do
  before do
    @mailbox = create(:mailbox)
  end

  after do
    @mailbox.destroy
  end

  # associations
  it { should have_many(:messages) }
  it { should belong_to(:account) }

  # validations
  it { should validate_presence_of(:name) }

  # methods
  describe 'get_messages' do

  end

  describe 'last_seen_uid' do
    it 'should get the last uid' do
      10.times { create(:message, mailbox:@mailbox) }
      @mailbox.last_seen_uid.should == @mailbox.messages.order('messages.uid DESC').limit(1).last.try(:uid)
    end

    it 'should return 1 if there are no messages' do
      @mailbox.last_seen_uid.should == 1
    end
  end

  describe 'queues_remaining' do
    it 'should return 0 at start' do
      @mailbox.queues_remaining.should be_empty
    end

    it 'should increment by 1 when a job is added' do
      expect {
        Delayed::Job.enqueue(Jobs::Testing.new(nil), queue:@mailbox.queue_name)
      }.to change(@mailbox.queues_remaining, :size).by(1)
    end
  end
end