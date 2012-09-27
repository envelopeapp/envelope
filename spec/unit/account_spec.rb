require 'spec_helper'

describe Account do
  before do
    @account = build(:account)
  end

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
  describe 'queue_name' do
    it 'should return the user_id and slug joined together' do
      @account.queue_name.should == ['', @account.user_id, @account._id].join('/')
    end
  end

  context 'mailbox recognizers' do
    describe 'inbox_mailbox?' do
      it 'should recognize mailbox with [:Inbox] flag and Inbox name' do
        imap_mailbox = Net::IMAP::MailboxList.new([:Inbox], '/', 'Inbox')
        @account.send(:inbox_mailbox?, imap_mailbox).should be_true
      end

      it 'should recognize mailbox with [:Inbox] flag and random name' do
        imap_mailbox = Net::IMAP::MailboxList.new([:Inbox], '/', 'Random')
        @account.send(:inbox_mailbox?, imap_mailbox).should be_true
      end

      it 'should recognize mailbox with no flags and Inbox name' do
        imap_mailbox = Net::IMAP::MailboxList.new({}, '/', 'Inbox')
        @account.send(:inbox_mailbox?, imap_mailbox).should be_true
      end

      it 'should not recognize a mailbox that is not an inbox' do
        imap_mailbox = Net::IMAP::MailboxList.new([], '/', 'Random')
        @account.send(:inbox_mailbox?, imap_mailbox).should be_false
      end
    end

    describe 'sent_mailbox?' do
      it 'should recognize mailbox with [:Sent] flag and Sent name' do
        imap_mailbox = Net::IMAP::MailboxList.new([:Sent], '/', 'Sent')
        @account.send(:sent_mailbox?, imap_mailbox).should be_true
      end

      it 'should recognize mailbox with [:Delivered] flag and Sent name' do
        imap_mailbox = Net::IMAP::MailboxList.new([:Delivered], '/', 'Sent')
        @account.send(:sent_mailbox?, imap_mailbox).should be_true
      end

      it 'should recognize mailbox with [:Sent] flag and random name' do
        imap_mailbox = Net::IMAP::MailboxList.new([:Sent], '/', 'Random')
        @account.send(:sent_mailbox?, imap_mailbox).should be_true
      end

      it 'should recognize mailbox with [:Delivered] flag and random name' do
        imap_mailbox = Net::IMAP::MailboxList.new([:Delivered], '/', 'Random')
        @account.send(:sent_mailbox?, imap_mailbox).should be_true
      end

      it 'should recognize mailbox with no flags and Sent name' do
        imap_mailbox = Net::IMAP::MailboxList.new({}, '/', 'Sent')
        @account.send(:sent_mailbox?, imap_mailbox).should be_true
      end

      it 'should recognize mailbox with no flags and Delivered name' do
        imap_mailbox = Net::IMAP::MailboxList.new({}, '/', 'Delivered')
        @account.send(:sent_mailbox?, imap_mailbox).should be_true
      end

      it 'should not recognize a mailbox that is not an sent' do
        imap_mailbox = Net::IMAP::MailboxList.new([], '/', 'Random')
        @account.send(:sent_mailbox?, imap_mailbox).should be_false
      end
    end

    describe 'junk_mailbox?' do
      it 'should recognize mailbox with [:Junk] flag and Junk name' do
        imap_mailbox = Net::IMAP::MailboxList.new([:Junk], '/', 'Junk')
        @account.send(:junk_mailbox?, imap_mailbox).should be_true
      end

      it 'should recognize mailbox with [:Spam] flag and Spam name' do
        imap_mailbox = Net::IMAP::MailboxList.new([:Spam], '/', 'Spam')
        @account.send(:junk_mailbox?, imap_mailbox).should be_true
      end

      it 'should recognize mailbox with [:Junk] flag and random name' do
        imap_mailbox = Net::IMAP::MailboxList.new([:Junk], '/', 'Random')
        @account.send(:junk_mailbox?, imap_mailbox).should be_true
      end

      it 'should recognize mailbox with [:Spam] flag and random name' do
        imap_mailbox = Net::IMAP::MailboxList.new([:Spam], '/', 'Random')
        @account.send(:junk_mailbox?, imap_mailbox).should be_true
      end

      it 'should recognize mailbox with no flags and Junk name' do
        imap_mailbox = Net::IMAP::MailboxList.new({}, '/', 'Junk')
        @account.send(:junk_mailbox?, imap_mailbox).should be_true
      end

      it 'should recognize mailbox with no flags and Delivered name' do
        imap_mailbox = Net::IMAP::MailboxList.new({}, '/', 'Spam')
        @account.send(:junk_mailbox?, imap_mailbox).should be_true
      end

      it 'should not recognize a mailbox that is not an sent' do
        imap_mailbox = Net::IMAP::MailboxList.new([], '/', 'Random')
        @account.send(:junk_mailbox?, imap_mailbox).should be_false
      end
    end

    describe 'drafts_mailbox?' do
      it 'should recognize mailbox with [:Drafts] flag and Drafts name' do
        imap_mailbox = Net::IMAP::MailboxList.new([:Drafts], '/', 'Drafts')
        @account.send(:drafts_mailbox?, imap_mailbox).should be_true
      end

      it 'should recognize mailbox with [:Drafts] flag and random name' do
        imap_mailbox = Net::IMAP::MailboxList.new([:Drafts], '/', 'Random')
        @account.send(:drafts_mailbox?, imap_mailbox).should be_true
      end

      it 'should recognize mailbox with no flags and Drafts name' do
        imap_mailbox = Net::IMAP::MailboxList.new({}, '/', 'Drafts')
        @account.send(:drafts_mailbox?, imap_mailbox).should be_true
      end

      it 'should not recognize a mailbox that is not an drafts' do
        imap_mailbox = Net::IMAP::MailboxList.new([], '/', 'Random')
        @account.send(:drafts_mailbox?, imap_mailbox).should be_false
      end
    end

    describe 'trash_mailbox?' do
      it 'should recognize mailbox with [:Trash] flag and Trash name' do
        imap_mailbox = Net::IMAP::MailboxList.new([:Trash], '/', 'Trash')
        @account.send(:trash_mailbox?, imap_mailbox).should be_true
      end

      it 'should recognize mailbox with [:Deleted] flag and Deleted name' do
        imap_mailbox = Net::IMAP::MailboxList.new([:Deleted], '/', 'Deleted')
        @account.send(:trash_mailbox?, imap_mailbox).should be_true
      end

      it 'should recognize mailbox with [:Removed] flag and Removed name' do
        imap_mailbox = Net::IMAP::MailboxList.new([:Removed], '/', 'Removed')
        @account.send(:trash_mailbox?, imap_mailbox).should be_true
      end

      it 'should recognize mailbox with [:Trash] flag and random name' do
        imap_mailbox = Net::IMAP::MailboxList.new([:Trash], '/', 'Random')
        @account.send(:trash_mailbox?, imap_mailbox).should be_true
      end

      it 'should recognize mailbox with [:Deleted] flag and random name' do
        imap_mailbox = Net::IMAP::MailboxList.new([:Deleted], '/', 'Random')
        @account.send(:trash_mailbox?, imap_mailbox).should be_true
      end

      it 'should recognize mailbox with [:Removed] flag and random name' do
        imap_mailbox = Net::IMAP::MailboxList.new([:Removed], '/', 'Random')
        @account.send(:trash_mailbox?, imap_mailbox).should be_true
      end

      it 'should recognize mailbox with no flags and Trash name' do
        imap_mailbox = Net::IMAP::MailboxList.new({}, '/', 'Trash')
        @account.send(:trash_mailbox?, imap_mailbox).should be_true
      end

      it 'should recognize mailbox with no flags and Deleted name' do
        imap_mailbox = Net::IMAP::MailboxList.new({}, '/', 'Deleted')
        @account.send(:trash_mailbox?, imap_mailbox).should be_true
      end

      it 'should recognize mailbox with no flags and Removed name' do
        imap_mailbox = Net::IMAP::MailboxList.new({}, '/', 'Removed')
        @account.send(:trash_mailbox?, imap_mailbox).should be_true
      end

      it 'should not recognize a mailbox that is not an trash' do
        imap_mailbox = Net::IMAP::MailboxList.new([], '/', 'Random')
        @account.send(:trash_mailbox?, imap_mailbox).should be_false
      end
    end

    describe 'starred_mailbox?' do
      it 'should recognize mailbox with [:Starred] flag and Drafts name' do
        imap_mailbox = Net::IMAP::MailboxList.new([:Starred], '/', 'Drafts')
        @account.send(:starred_mailbox?, imap_mailbox).should be_true
      end

      it 'should recognize mailbox with [:Starred] flag and random name' do
        imap_mailbox = Net::IMAP::MailboxList.new([:Starred], '/', 'Random')
        @account.send(:starred_mailbox?, imap_mailbox).should be_true
      end

      it 'should recognize mailbox with no flags and Starred name' do
        imap_mailbox = Net::IMAP::MailboxList.new({}, '/', 'Starred')
        @account.send(:starred_mailbox?, imap_mailbox).should be_true
      end

      it 'should not recognize a mailbox that is not an starred' do
        imap_mailbox = Net::IMAP::MailboxList.new([], '/', 'Random')
        @account.send(:starred_mailbox?, imap_mailbox).should be_false
      end
    end

    describe 'important_mailbox?' do
      it 'should recognize mailbox with [:Important] flag and Important name' do
        imap_mailbox = Net::IMAP::MailboxList.new([:Important], '/', 'Important')
        @account.send(:important_mailbox?, imap_mailbox).should be_true
      end

      it 'should recognize mailbox with [:Important] flag and random name' do
        imap_mailbox = Net::IMAP::MailboxList.new([:Important], '/', 'Random')
        @account.send(:important_mailbox?, imap_mailbox).should be_true
      end

      it 'should recognize mailbox with no flags and Important name' do
        imap_mailbox = Net::IMAP::MailboxList.new({}, '/', 'Important')
        @account.send(:important_mailbox?, imap_mailbox).should be_true
      end

      it 'should not recognize a mailbox that is not an mportant' do
        imap_mailbox = Net::IMAP::MailboxList.new([], '/', 'Random')
        @account.send(:important_mailbox?, imap_mailbox).should be_false
      end
    end
  end
end
