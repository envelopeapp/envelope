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
      @mailbox.messages.where(:uid.in => imap_deleted_messages.keys).destroy_all

      # mass-import messages
      existing_uids = Hash[*@mailbox.messages.collect{ |m| [m.uid, 1] }.flatten] # because Ruby imap uid_fetch sucks
      messages = imap_new_messages.collect do |message|
        {
          :mailbox_id => @mailbox._id,
          :message_id => message.message_id,
          :uid => message.uid,
          :subject => message.subject,
          :read => message.read?,
          :downloaded => false,
          :date => message.date,
        } unless existing_uids[message.uid]
      end.compact

      # import in batches of 1,000
      messages.each_slice(1000) do |batch|
        Message.collection.insert(batch)
      end

      # update the mailbox
      @mailbox.update_attribute(:last_synced, Time.now)

      # now import the rest of the message bodiess
      Delayed::Job.enqueue(Jobs::MessageBodyLoader.new(@mailbox._id), queue: @mailbox.queue_name)
    end

    def success
      PrivatePub.publish_to @user.queue_name, :action => 'loaded_messages', :mailbox => @mailbox
    end
  end
end
