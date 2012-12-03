#
# Update existing message flags according to RFC-4551 and RFC-4549
#
# @author Seth Vargo
#
class MessageUpdateWorker
  include Sidekiq::Worker

  def perform(mailbox_id)
    @mailbox = Mailbox.find(mailbox_id)
    @account = @mailbox.account
    @user = @account.user
    @imap = Envelope::IMAP.new(@account)

    publish_start

    # RFC-4549 recommends the following commands:
    #   tag1 UID FETCH <last_seen_uid+1>:* <descriptors>
    #   tag2 UID FETCH 1:<last_seen_uid> FLAGS
    #
    # tag1 is handled by both Envelope::MailboxWorker and Envelope::MessageWorker,
    # so we are just handling tag2 here.
    #
    # Fetch all messages from 1 up to an including the last_seen_uid, iterate, and
    # update the message flags in the database.
    messages = @imap.uid_fetch(@mailbox, [1..@mailbox.last_seen_uid], ['FLAGS'])

    # Delete all messages that no longer exist on the server. It's safe to assume
    # that, if they no longer exist on the server, that they should not exist in
    # our local cache either.
    existing_uids = @imap.uid_search(@mailbox, ['ALL'])
    @mailbox.messages.where(:uid.nin => existing_uids).destroy_all

    @mailbox.messages.where(:uid.in => messages.keys).each do |message|
      # If the message has been deleted, we should just destroy it from this mailbox,
      # since the subsequent run of Envelope::MailboxWorker on the Trash mailbox will
      # download the message for us.
      if messages[message.uid].deleted?
        message.destroy
      else
        message.update_attributes(flags: messages[message.uid].flags)
      end
    end

    publish_finish
  end

  def publish_start
    @user.publish 'message-update-worker-start', { mailbox: @mailbox }
  end

  def publish_finish
    @user.publish 'message-update-worker-finish', { mailbox: @mailbox }
  end
end
