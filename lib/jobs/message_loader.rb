module Jobs
  # This Job loads the messages into the database. It only loads the most important information
  # like the information from the imap envelope. It does *not* parse the message bodies or match
  # participants and contacts. That is handled by Jobs::MessageBodyLoader.
  class MessageLoader < Struct.new(:mailbox_id)
    def before
      # grab the account and user
      @mailbox = Mailbox.find(mailbox_id)
      @account = @mailbox.account
      @user = @account.user

      # tell the front end what we are doing
      PrivatePub.publish_to @user.queue_name, :action => 'loading_messages', :account => @account, :mailbox => @mailbox
    end

    def perform
      # don't do anything if the mailbox is not selectable
      return unless @mailbox.selectable?

      # create an imap connection
      @imap = Envelope::IMAP.new(@account)

      # make sure we can rely on UIDs
      @mailbox.send(:check_uid_validity!)

      # get new/changed messages
      last_seen_uid = @mailbox.send(:last_seen_uid)
      imap_new_messages = @imap.uid_fetch(@mailbox, [last_seen_uid+1..-1], ['UID', 'FLAGS', 'INTERNALDATE', 'ENVELOPE'])
      imap_changed_messages = @imap.uid_fetch(@mailbox, [1..last_seen_uid], ['UID', 'FLAGS'])

      # delete any messages that have been deleted...
      imap_deleted_messages = Hash[*imap_changed_messages.collect{|m| [m.attr['UID'], m] if m.deleted? }.compact.flatten]
      @mailbox.messages.where('messages.uid IN (?)', imap_deleted_messages.keys).destroy_all

      # mass-import messages
      existing_uids = Hash[*@mailbox.messages.pluck(:uid).collect{|i| [i, 1]}.flatten] # because Ruby imap uid_fetch sucks
      cols = [:mailbox_id, :message_id, :uid, :subject, :read, :date]
      messages = imap_new_messages.collect{ |m| [@mailbox.id, m.message_id, m.uid, m.subject, m.read?, m.date] unless existing_uids.has_key?(m.uid) }.compact
      Message.import(cols, messages, validate:false)

      # update the mailbox
      @mailbox.last_synced = Time.now
      @mailbox.save!

      # now import the rest of the message bodiess
      Delayed::Job.enqueue(Jobs::MessageBodyLoader.new(@mailbox.id), queue:@mailbox.queue_name)
    end

    def success
      PrivatePub.publish_to @user.queue_name, :action => 'loaded_messages', :mailbox => @mailbox
    end
  end
end
