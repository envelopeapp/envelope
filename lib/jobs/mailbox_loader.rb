module Jobs
  # This Job updates mailboxes for the given account.
  #
  # - If a mailbox in our database no longer exists on the remote server, that mailbox (along
  #   with all it's messages, etc) is destroyed
  # - If a mailbox not in our database exists on the remote server, that mailbox is created and
  #   associated with the account
  # - If a mailbox is in our database and exists on the remote server, we update any attributes
  #   that might have changed (such as attr) and save the existing mailbox
  #
  # This Job does NOT import messages. See Jobs::MessageLoader for importing messages from a
  # given mailbox
  class MailboxLoader < Struct.new(:account_id)
    def before
      # grab the account and user
      @account = Account.find(account_id)
      @user = @account.user

      # tell the front-end how many messages we have to load
      PrivatePub.publish_to @user.queue_name, :action => 'loading_mailboxes', :account => @account
    end

    def perform
      # create an imap connection
      @imap = Envelope::IMAP.new(@account)
      imap_mailboxes = @imap.mailboxes.sort!{ |a,b| a.name <=> b.name }

      # delete old mailboxes
      imap_mailbox_locations = imap_mailboxes.collect{ |m| m.name }
      deleted_mailboxes = @account.mailboxes.where(:location.nin => imap_mailbox_locations).destroy_all

      # iterate over each mailbox and create/update it's attributes
      mailboxes_hash = Hash[*@account.mailboxes.collect{|m| [m.location, m]}.flatten]

      # iterate over each imap_mailbox and update our local mailbox
      imap_mailboxes.each_with_index do |imap_mailbox, index|
        mailbox = mailboxes_hash[imap_mailbox.name] || @account.mailboxes.new

        split_name = imap_mailbox.name.split(imap_mailbox.delim)

        # set attributes
        mailbox.name = split_name.try{|n| n.last.downcase.titleize} || 'Inbox'
        mailbox.location = imap_mailbox.name
        mailbox.selectable = !imap_mailbox.attr.include?(:Noselect)

        mailboxes_hash[mailbox.location] = mailbox

        # determine if this is a "special" mailbox
        # @account.inbox_mailbox_id = mailbox._id if @account.send(:inbox_mailbox?, imap_mailbox)
        # @account.sent_mailbox_id = mailbox._id if @account.send(:sent_mailbox?, imap_mailbox)
        # @account.junk_mailbox_id = mailbox._id if @account.send(:junk_mailbox?, imap_mailbox)
        # @account.drafts_mailbox_id = mailbox._id if @account.send(:drafts_mailbox?, imap_mailbox)
        # @account.trash_mailbox_id = mailbox._id if @account.send(:trash_mailbox?, imap_mailbox)
        # @account.starred_mailbox_id = mailbox._id if @account.send(:starred_mailbox?, imap_mailbox)
        # @account.important_mailbox_id = mailbox._id if @account.send(:important_mailbox?, imap_mailbox)

        # does it have a parent?
        location = imap_mailbox.name.split(imap_mailbox.delim)[0...-1].join(imap_mailbox.delim)
        if parent = mailboxes_hash[location]
          mailbox.parent = parent
        end

        mailbox.save! if mailbox.changed?

        # tell the front-end that we loaded a mailbox
        PrivatePub.publish_to @user.queue_name, :action => 'loaded_mailbox', :mailbox => mailbox, :account => @account, :percent_complete => index/(imap_mailboxes.length*1.0)

        Delayed::Job.enqueue(Jobs::MessageLoader.new(mailbox._id), queue:mailbox.queue_name)
      end

      @account.save! if @account.changed?
    end

    def success
      PrivatePub.publish_to @user.queue_name, :action => 'loaded_mailboxes', :account => @account
    end
  end
end
