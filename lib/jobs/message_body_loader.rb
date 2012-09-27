module Jobs
  # This doesn't actually load messages - it load's message bodies. The RFC822 is fetched from the
  # remote server and parsed by the `mail` gem.
  class MessageBodyLoader < Struct.new(:mailbox_id)
    include ActionView::Helpers::SanitizeHelper
    include ActionView::Helpers::TextHelper

    def before
      # grab the account and user
      @mailbox = Mailbox.find(mailbox_id)
      @account = @mailbox.account
      @user = @account.user

      # tell the front-end that we are working...
      begin
        PrivatePub.publish_to @user.queue_name, :action => 'loading_message_bodies', :mailbox => @mailbox
      rescue; end
    end

    def perform
      # create an imap connection
      @imap = Envelope::IMAP.new(@account)

      # get uids
      uids = @mailbox.messages.undownloaded.collect(&:uid)

      # get all messages
      imap_messages = @imap.uid_fetch(@mailbox, uids, ['UID', 'FLAGS', 'ENVELOPE', 'RFC822'])
      @imap_messages_hash = Hash[*imap_messages.collect{|m| [m.uid.to_i, m]}.flatten]

      # load the bodies of all undownloaded messages
      @mailbox.messages.undownloaded.each do |message|
        begin
          parse_message_body(message)
          begin
            PrivatePub.publish_to @user.queue_name, :action => 'loaded_message_body', :message => message
          rescue; end
        rescue Exception => e
          error = "Error loading message(id:#{message._id}): #{e}"
          puts error + e.backtrace.join("\t\n")
          begin
            PrivatePub.publish_to @user.queue_name, :action => 'error', :message => error
          rescue; end
        end
      end
    end

    def success
      begin
        PrivatePub.publish_to @user.queue_name, :action => 'loaded_message_bodies', :mailbox => @mailbox
      rescue; end
    end

    private
    def parse_message_body(message)
      mail = Mail.new(@imap_messages_hash[message.uid].attr['RFC822'])

      begin
        if mail.multipart?
          html_part = mail.html_part.try(:body).try(:decoded).to_utf8 if mail.respond_to?(:html_part)
          text_part = mail.text_part.try(:body).try(:decoded).to_utf8 if mail.respond_to?(:text_part)

          # the message was multipart, but didn't respond to html/text parts
          if html_part.blank? && text_part.blank?
            text_part = "I had no idea how to handle this message... It was not formatted properly".to_utf8
          end
        else
          text_part = mail.body.try(:decoded).to_utf8
        end
      rescue Exception => e
        text_part = "I could not parse this message because: #{e}\n\n#{e.backtrace}".to_utf8
      end

      preview = strip_tags(text_part.presence || html_part.presence || 'No Message Preview').try(:squish).try(:strip).try(:slice, 0, 256)

      message.text_part = simple_format(strip_tags(text_part))
      message.html_part = sanitize(html_part, tags:%w(div p span table tr td th b i u strong em br), attributes:%w(style class))
      message.preview = preview
      message.downloaded = true
      message.save!

      Participant::TYPES.each do |pt|
        key = pt.downcase.underscore.to_sym # "To" => :to
        values = mail[key] || []

        values.each do |addr|
          name = Mail::Encodings.decode_encode(addr.display_name || '', :decode).to_utf8.presence
          email_address = Mail::Encodings.decode_encode(addr.address|| '', :decode).to_utf8.presence
          message.participants.create!(name:name, email_address:email_address, participant_type:pt)
        end
      end
    end

    def strip_comments(str)
      (str || '').gsub(/\<\!\-\-(.*)\-\-\>/, '')
    end
  end
end
