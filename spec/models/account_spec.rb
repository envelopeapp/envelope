require 'spec_helper'

describe Account do
  subject { build(:account) }

  # associations
  it { should belong_to(:user) }
  it { should embed_one(:incoming_server) }
  it { should embed_one(:outgoing_server) }
  it { should have_many(:mailboxes) }
    it { should belong_to(:inbox_mailbox) }
    it { should belong_to(:sent_mailbox) }
    it { should belong_to(:junk_mailbox) }
    it { should belong_to(:drafts_mailbox) }
    it { should belong_to(:trash_mailbox) }

  # validations
  it { should validate_presence_of(:user) }
  it { should validate_presence_of(:incoming_server) }
  it { should validate_presence_of(:outgoing_server) }
  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:email_address) }

  # methods
end
