#
# This Job loads the messages into the database. It only loads
# the most important information like the information from the IMAP
# envelope. It does *not* parse the message bodies or match participants
# and contacts.
#
# @author Seth Vargo
#
class MailboxWorker
  include Sidekiq::Worker

  def perform(mailbox_id)
    @mailbox = Mailbox.find(mailbox_id)
    @account = @mailbox.account
    @user = @account.user

    # don't do anything if the mailbox is not selectable
    return unless @mailbox.selectable?

    # tell the frontend we've started to load this mailbox
    publish_start

    # create an imap connection
    @imap = Envelope::IMAP.new(@account)

    # ensure we can import messages
    check_uid_validity!

    # import new messages
    MessageWorker.perform_async(@mailbox.id)

    # update old messages
    MessageUpdateWorker.perform_async(@mailbox.id)

    # update the mailbox
    @mailbox.update_attribute(:last_synced, Time.now)

    # tell the frontend we are done
    publish_finish
  end

  private
  # Check the mailbox UIDVALIDITY
  # If UIDVALIDITY value returned by the server differs, the client MUST
  #   - empty the local cache of that mailbox;
  #   - remove any pending "actions" that refer to UIDs in that mailbox and consider them failed
  def check_uid_validity!
    imap_uid_validity = @imap.get_uid_validity(@mailbox)

    if imap_uid_validity != @mailbox.uid_validity
      # empty the local cache of that mailbox
      @mailbox.messages.destroy_all

      # set the UIDVALIDITY
      @mailbox.uid_validity = imap_uid_validity
      @mailbox.update_attribute(:uid_validity, imap_uid_validity)
    end
  end

  def publish_start
    #@user.publish('mailbox-worker-start', { mailbox: @mailbox, account: @account })
  end

  def publish_finish
    #@user.publish('mailbox-worker-finish', { mailbox: @mailbox, account: @account })
  end
end
