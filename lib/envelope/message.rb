module Envelope
  class Message
    attr_reader :attr, :uid, :flags, :envelope, :message_id, :date, :subject

    def initialize(imap_message)
      @attr = imap_message.attr

      @uid = @attr['UID']
      @flags = @attr['FLAGS']

      @envelope = @attr['ENVELOPE']

      unless @envelope.nil?
        @subject = Mail::Encodings.decode_encode(@envelope.subject || '(No Subject)', :decode).to_utf8
        @message_id = @envelope.message_id
        @date = @envelope.date.to_time
      end
    end

    def read?
      read_flags = [:Seen, :Read, :New]
      @flags.each { |flag| return true if read_flags.include?(flag) }
      false
    end

    def unread?
      !read?
    end

    def deleted?
      deleted_flags = [:Deleted, :Removed]
      @flags.each { |flag| return true if deleted_flags.include?(flag) }
      false
    end
  end
end