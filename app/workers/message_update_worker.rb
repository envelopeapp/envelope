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
    @imap = Envelope::IMAP.new(@account)

    # create a hash of messages for O(1) lookups later
    messages = Hash[ *@imap.uid_fetch(@mailbox, [1..@mailbox.last_seen_uid], ['FLAGS']).collect{ |m| [m.uid, m] }.flatten ]

    # update existing message flags
    @mailbox.messages.where(:uid.in => messages.keys).each do |message|
      message.update_attributes(
        flags: messages[message.uid].flags,
        mailbox_id: mailbox_id_for(message)
      )
    end
  end

  private
  def mailbox_id_for(message)
    return @account.trash_mailbox_id if message.deleted? && @account.trash_mailbox
    return @account.drafts_mailbox_id if message.drafts? && @account.drafts_mailbox
  end
end
