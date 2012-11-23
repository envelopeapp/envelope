require 'spec_helper'

describe Participant do
  subject { build(:participant) }

  # association
  it { should be_embedded_in(:message) }

  # validations
  it { should validate_presence_of(:participant_type) }

  # methods
  describe '#to_s' do
    its(:to_s){ should == 'Bill Participant' }

    context 'without a name' do
      subject { build(:participant, name: nil) }
      its(:to_s){ should == 'bparticipant@example.com' }
    end

    context 'with a contact' do
      subject { build(:participant_with_contact) }
      its(:to_s){ should == 'Jeremy Contact' }
    end
  end

  describe '#find_contact' do
    context 'success' do
      let(:user) { build(:user) }
      let!(:contact) { build(:contact, emails: [ build(:email, email_address: 'bparticipant@example.com') ], user: user) }
      let(:account) { build(:account, user: user) }
      let(:mailbox) { build(:mailbox, account: account) }
      let(:message) { build(:message, mailbox:  mailbox) }

      subject { build(:participant, message: message).send(:find_contact) }

      its(:contact){ should_not be_nil }
      its(:name){ should be_nil }
      its(:email_address){ should be_nil }
    end

    context 'failure' do
      its(:name) { should == 'Bill Participant' }
      its(:email_address) { should == 'bparticipant@example.com' }
    end
  end
end
