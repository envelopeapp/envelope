#
# Load an individual message
#
# @author Seth Vargo
#
class MessageWorker
  include Sidekiq::Worker

  # Find or update the given message
  #
  # @param [Integer] mailbox_id the mailbox_id to find the message in
  # @param [Binary] message Marshall dump of the messae
  def perform(mailbox_id)
    @mailbox = Mailbox.find(mailbox_id)
    @account = @mailbox.account
    @imap = Envelope::IMAP.new(@account)

    messages = @imap.uid_fetch(@mailbox, [@mailbox.last_seen_uid+1..-1], ['RFC822', 'FLAGS']).collect do |message|
      {
        mailbox_id: @mailbox.id,
        uid: message.uid,
        message_id: message.message_id,
        subject: message.subject,
        timestamp: message.timestamp,
        read: message.read?,
        flags: message.flags,
        flagged: message.flagged?,
        # full_text_part: message.full_text_part,
        text_part: message.text_part,
        # full_html_part: message.full_html_part,
        html_part: message.html_part,
        sanitized_html: message.sanitized_html,
        raw: message.raw_source
      }
    end

    messages.each_slice(2500) do |batch|
      Message.collection.insert(batch)
    end
  end
end
