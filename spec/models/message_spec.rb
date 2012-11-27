require 'spec_helper'

describe Message do
  before do
    Envelope::IMAP.any_instance.stub(:uid_store).and_return(true)
    Envelope::IMAP.any_instance.stub(:uid_copy).and_return(true)
  end

  before(:all) do
    @message = build(:message)
  end

  # assocations
  it { should have_and_belong_to_many(:labels) }
  it { should belong_to(:mailbox) }
  it { should embed_many(:attachments) }
  it { should embed_many(:participants) }

  # methods
  describe '#unread?' do
    it 'returns true if the message was not yet read' do
      @message.push(:flags, 'read')
      @message.unread?.should be_false
    end

    it 'returns false if the was was already read' do
      @message.pull(:flags, 'read')
      @message.unread?.should be_true
    end
  end

  describe '#mark_as_read!' do
    it 'marks a message as read' do
      @message.pull(:flags, 'seen')

      expect {
        @message.mark_as_read!
      }.to change(@message, :read?).to(true)
    end
  end

  describe '#mark_as_unread!' do
    it 'marks a message as unread' do
      @message.push(:flags, 'seen')

      expect {
        @message.mark_as_unread!
      }.to change(@message, :read?).to(false)
    end
  end

  describe '#flag!' do
    it 'flags a message' do
      @message.pull(:flags, 'flagged')

      expect {
        @message.flag!
      }.to change(@message, :flagged?).to(true)
    end
  end

  describe '#unflag!' do
    it 'unflags a message' do
      @message.push(:flags, 'flagged')

      expect {
        @message.unflag!
      }.to change(@message, :flagged?).to(false)
    end
  end

  describe '#move_to_trash!' do
    it 'deletes the message' do
      @message.save!

      expect {
        @message.move_to_trash!
      }.to change(Message, :count).by(-1)
    end
  end
end
