require 'spec_helper'

describe Participant do
  # association
  it { should be_embedded_in(:message) }

  # validations
  it { should validate_presence_of(:participant_type) }

  # methods
  describe 'to_s' do
    before do
      @message = build(:message)
    end

    it 'should show the contacts name if the contact is present' do
      @participant_contact = build(:participant_with_contact, message: @message)
      @participant_contact.to_s.should == 'Jeremy Contact'
    end

    it 'should show the name if no contact is present and name is present' do
      @participant = build(:participant, message: @message, name: 'Bill Participant')
      @participant.to_s.should == 'Bill Participant'
    end

    it 'should show the email address if no contact and no name is present' do
      @participant_name = build(:participant, message: @message, name: nil, email_address: 'sample@example.com')
      @participant_name.to_s.should == 'sample@example.com'
    end
  end

  describe 'find_contact' do
    before do
      @user = build(:user)
      @contact = build(:contact, user: @user)
      @account = build(:account, user: @user)
      @mailbox = build(:mailbox, account: @account)
      @message = build(:message, mailbox: @mailbox)
    end

    context 'success' do
      before do
        @participant = build(:participant, message: @message, email_address: 'bill@example.com')
      end

      it 'should find the contact with the same email address' do
        @participant.send(:find_contact)
        @participant.contact.should_not be_nil
      end

      it 'should set the name to nil' do
        @participant.send(:find_contact)
        @participant.name.should be_nil
      end

      it 'should set the email_address to nil' do
        @participant.send(:find_contact)
        @participant.email_address.should be_nil
      end
    end

    context 'failure' do
      before do
        @participant = build(:participant, message: @message)
      end

      it 'should leave the name unchanged' do
        expect {
          @participant.send(:find_contact)
        }.not_to change(@participant, :name)
      end

      it 'should leave the email_address unchanged' do
        expect {
          @participant.send(:find_contact)
        }.not_to change(@participant, :email_address)
      end
    end
  end
end

