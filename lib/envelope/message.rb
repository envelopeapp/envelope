# encoding: utf-8
require 'mail'
require 'yaml'

require 'date'
require 'time'

#
# Reads and parses email message bodies.
#
# @author Seth Vargo
#
module Envelope
  class Message
    include Envelope::MessageTools

    ALL_SPACES = /[\s\u0085\u00a0\u1680\u180e\u2000-\u200a\u2028\u2029\u202f\u205f\u3000]/.freeze unless defined?(ALL_SPACES)

    # Creates a new MessageLoader object
    #
    # @param [IMAP::Message] the IMAP mail message to read
    def initialize(message)
      @uid = message.attr['UID'].to_i
      @rfc822 = message.attr['RFC822']
      @flags = (message.attr['FLAGS'] || []).collect{ |f| f.to_s.downcase.gsub('$', '') }.uniq
    end

    # Returns only the relevant text part of the conversation,
    # i.e. the last part of the message received, without the
    # rest of the conversation thread
    def text_part
      return nil if full_text_part.nil?
      @text_part ||= filter(remove_appended_messages(full_text_part))
    end

    # Returns the full text part of the email, including
    # the previously included content like replies and forwards
    def full_text_part
      part = (message.text_part && message.text_part.body) || html2text(full_html_part)
      return nil if part.nil?
      @full_text_part ||= filter(convert(part))
    end

    # Returns only the relevant html part of the conversation,
    # i.e. the last part of the message received, without the
    # rest of the conversation thread
    def html_part
      return nil if full_html_part.nil?
      @html_part ||= remove_appended_messages(full_html_part)
    end

    # Returns the full html part of the email, including
    # the previously included content like replies and forwards
    def full_html_part
      part = (message.html_part && message.html_part.body) || message.body
      return nil if part.nil?
      @full_html_part ||= filter(convert(part))
    end

    # Returns the fully-sanitized HTML, removing any classes, styles,
    # fonts, etc.
    def sanitized_html
      return nil if html_part.nil?
      @sanitized_html ||= sanitize(html_part)
    end

    # The flags on this message
    #
    # @return [Array<String>] array of flags on this message
    def flags
      @flags
    end

    # Determines if this message has been read
    #
    # @return [Boolean] true if the message has been read, false otherwise
    def read?
      !(%w(seen read) & flags).empty?
    end

    # Determines if this message has not been read
    #
    # @return [Boolean] false if the message has been read, true otherwise
    def unread?
      !read?
    end

    # Determines if this message has been deleted
    #
    # @return [Boolean] true if the message has been deleted, false otherwise
    def deleted?
      !(%w(deleted removed) & flags).empty?
    end

    # Determine if this message is a draft
    #
    # @return [Boolean] true if the message is a draft, false otherwise
    def draft?
      !(%w(draft) & flags).empty?
    end

    # Determines if this message has been flagged
    #
    # @return [Boolean] true if the message has been flagged, false otherwise
    def flagged?
      !(%w(flagged) & flags).empty?
    end

    # Returns the unique identifier for this message
    #
    # @return [Integer] the uid
    def uid
      @uid
    end

    # The unique message_id assigned by the server
    #
    # @return [String] the message id
    def message_id
      @message_id ||= message.message_id
    end

    # The headers for the message
    #
    # @return [Array] the headers
    def headers
      @headers ||= message.header_fields
    end

    # The MIME type for this message
    #
    # @return [String] the MIME type
    def mime_type
      @mime_type ||= message.mime_type
    end

    # The receiving stack. Used for authenticating messages
    #
    # @return [String] the receiving stack
    def received
      @received ||= message.received
    end

    # The list of references or authorities for this message
    #
    # @return [Array] the list of references
    def references
      @references ||= message.references || []
    end

    # The character set for this message
    #
    # @return [String] the character set (lowercase)
    def charset
      @charset ||= message.charset.upcase
    end

    # Was the message a bounce?
    #
    # @return [Boolean] true if the message is a bounce, false otherwise
    def bounced?
      message.bounced?
    end

    # Is this a multipart message?
    #
    # @return [Boolean] true if the message is multipart, false otherwise
    def multipart?
      message.multipart?
    end

    # The timestamp on the message header
    #
    # @return [Time] the message datetime in UTC
    def timestamp
      Time.parse(message.date.to_s).utc
    end

    # The subject of the email message
    #
    # @return [String] the subject
    def subject
      @subject ||= convert(Mail::Encodings.decode_encode(message.subject || '', :decode))
    end

    # Accessor methods for each of the participant types
    [:to, :from, :sender, :cc, :bcc, :reply_to].each do |participant_type|
      define_method participant_type do
        addresses = [message[participant_type] || []].flatten

        addresses.collect do |address|
          email_address = convert(Mail::Encodings.decode_encode(address.field.addresses.first, :decode)) unless address.field.addresses.first.nil?
          name = convert(Mail::Encodings.decode_encode(address.field.display_names.first, :decode)) unless address.field.display_names.first.nil?

          OpenStruct.new({ name: name, email_address: email_address })
        end
      end

      define_method "formatted_#{participant_type}" do
        self.send(participant_type).collect { |p| p.name || p.email_address }
      end
    end

    def participants
      [:to, :from, :sender, :cc, :bcc, :reply_to].collect do |participant_type|
        self.send(participant_type).collect do |participant|
          {
            participant_type: participant_type.to_s,
            name: participant.name,
            email_address: participant.email_address
          }
        end
      end.flatten
    end

    # Determine whether there are attachments to this message
    #
    # @return [Boolean] true if there are attachments, false otherwise
    def attachments?
      !attachments.empty?
    end

    # Get a list of all the message attachments, if there are any
    #
    # @return [Array] the attachments
    def attachments
      @attachments ||= message.attachments
    end

    # The full, unedited and unmodified email
    #
    # @return [String] the unmodified email
    def raw_source
      @raw_source ||= convert(message.raw_source)
    end

    # Pretty print the Message
    #
    # @return [String] the string representation of this message
    def to_s
      "#<Envelope::Message to=#{formatted_to} from=#{formatted_from} cc=#{formatted_cc} bcc=#{formatted_bcc} reply_to=#{formatted_reply_to} subject=\"#{subject}\" text_part=\"#{text_part.gsub(/\s+/, ' ')[0..50]}...\">"
    end

    # YAML dump of the object
    #
    # @return [String] the YAML dump
    def to_yaml
      YAML::dump(self)
    end

    private
    # Parses the email message into its various parts
    #
    # @return [Mail::Message] the message
    def message
      @message ||= Mail.new(@rfc822)
    end
  end
end
