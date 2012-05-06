require 'spec_helper'

describe Participant do
  # association
  it { should belong_to(:message) }
  it { should belong_to(:contact) }

  # validations
  it { should validate_presence_of(:message) }
  it { should validate_presence_of(:participant_type) }

  # methods
  describe 'to_s' do
    it 'should show the contacts name if the contact is present' do
      @participant_contact = create(:participant_with_contact)
      @participant_contact.to_s.should == 'Jeremy Contact'
    end

    it 'should show the name if no contact is present and name is present' do
      @participant_without_contact = create(:participant, name:'Bill Participant')
      @participant_without_contact.to_s.should == 'Bill Participant'
    end

    it 'should show the email address if no contact and no name is present' do
      @participant_without_contact_name = create(:participant, name:nil, email_address:'sample@example.com')
      @participant_without_contact_name.to_s.should == 'sample@example.com'
    end
  end

  describe 'find_contact' do
    context 'success' do
      before do
        email_address = 'bill@example.com'
        @user = create(:user)
        @contact = create(:contact, user:@user, emails_attributes:[{ label:'Sample', email_address:email_address }])
        @account = create(:account, user:@user)
        @mailbox = create(:mailbox, account:@account)
        @message = create(:message, mailbox:@mailbox)
        @participant = create(:participant, message:@message, email_address:email_address)
      end

      after do
        @user.destroy
        @contact.destroy
        @account.destroy
        @mailbox.destroy
        @message.destroy
        @participant.destroy
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
        @participant = create(:participant)
      end

      after do
        @participant.destroy
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