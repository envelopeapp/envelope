require 'charlock_holmes'
require 'charlock_holmes/string'
require 'json'
require 'mail'
require 'nokogiri'
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
    ALL_SPACES = /[\s\u0085\u00a0\u1680\u180e\u2000-\u200a\u2028\u2029\u202f\u205f\u3000]/

    # Creates a new MessageLoader object
    #
    # @param [IMAP::Message] the IMAP mail message to read
    def initialize(message)
      @uid = message.attr['UID'].to_i
      @rfc822 = message.attr['RFC822']
      @flags = (message.attr['FLAGS'] || []).collect{ |f| f.to_s.downcase }
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
      @read_ ||= !(%w(seen read) & flags).empty?
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
      @deleted_ ||= !(%w(deleted removed) & flags).empty?
    end

    # Determines if this message has been flagged
    #
    # @return [Boolean] true if the message has been flagged, false otherwise
    def flagged?
      @flagged_ ||= !(%w(flagged) & flags).empty?
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

    # Use Charlock Holmes to convert everything to UTF-8.
    # At this time, we are not supporting other encodings.
    #
    # @param [String] text the arbitrary text to be encoded
    # @return [String] the utf-8 encoded string result
    def convert(text)
      return nil if text.nil? || text.empty?
      string = text.to_s # ensure we have a string
      string = string.gsub /\r\n?/, "\n" # normalize line breaks
      string.detect_encoding!

      string.encode!('UTF-8', :invalid => nil)
      string
    end

    # Attempt to normalize the text by converting newlines and breaks appropriately
    #
    # @param [String] text the text to filter
    # @return [String] the filtered text
    def filter(text)
      return nil if text.nil? || text.empty?
      string = text.to_s # ensure we have a string
      string.gsub! /\u00A0/, ' ' # convert all non-breaking spaces to normal-people spaces
      string.gsub! /\ +/, ' ' # replace double+ spaces with single spaces
      string.gsub! /&nbsp;/, ' '
      string.squeeze! ' '
      string.squeeze! "\n"
      string.chomp! '<br>'
      string.strip!
      string
    end

    # Finds and removes all the appended messages from a given email
    #
    # @param [String] text the search string
    # @return [String] the text of the email without appended messages
    def remove_appended_messages(text)
      return nil if text.nil? || text.empty?
      string = text.to_s # ensure we have a string

      # ------------ Original Message ------------
      string.gsub! /(<[\w\s=:"#]+>|^)+[-=]+.*Original Message.*/mi, ''

      # ------------ Forwarded Message ------------
      string.gsub! /(<[\w\s=:"#]+>|^)+[-=]+.*Forwarded Message.*/mi, ''

      # From: Seth Vargo <svargo@andrew.cmu.edu>
      # Send: Tues, Oct 9, 2012
      # To: Robbin Stormer <a@example.com>
      # Subject: Cookies and Cream
      string.gsub! /(<[\w\s=:"#]+>|^)+From:.*Sent:.*(To:.*)?.*(Cc:.*)?.*(Subject:.*)?.*/im, ''

      # On Oct 9, 2012, at 6:48 PM, Robbin Stormer wrote:
      string.gsub! /(<[\w\s=:"#]+>|^)+On \w+,? [\w\d]+ \d+,? \d+ at \d+:\d+ [AP]M,?.*wrote\:.*/mi, ''

      # Begin forwarded message:
      string.gsub! /(<[\w\s=:"#]+>|^)+Begin\ forwarded\ message:.*/mi, ''
      string
    end

    # A very strict sanitization of the DOM. This method removes any styles, classes,
    # ids, fonts, backgrounds, images, etc. This allows us to format messages using
    # Envelope standards, not the original email senders.
    #
    # @param [String] text the string representation of the HTML
    # @return [String] the sanitized HTML
    def sanitize(text)
      return nil if text.nil? || text.empty?
      string = text.to_s # ensure we have a string

      doc = Nokogiri::HTML.parse(text)

      doc.xpath('//@style').remove
      doc.xpath('//@class').remove
      doc.xpath('//@id').remove
      doc.xpath('//@font-size').remove
      doc.xpath('//@color').remove
      doc.xpath('//@size').remove
      doc.xpath('//@face').remove
      doc.xpath('//@bgcolor').remove

      # remove "bad" elements
      doc.css('script, link, img').each { |node| node.remove }

      # convert all <div>s to <p>s
      doc.css('div').each do |div|
        node = doc.create_element 'p'
        node.inner_html = div.inner_html
        div.replace(node)
      end

      # remove <font> and <span> tags, but preserve their content
      doc.css('font, span').each do |node|
        node.swap(node.children)
      end

      # wrap orphaned text nodes in <p> tags
      doc.css('html body').children.each do |orphan|
        if orphan.class == Nokogiri::XML::Text
          node = doc.create_element 'p'
          node.inner_html = orphan.text
          orphan.replace(node)
        end
      end

      # remove empty nodes
      doc.css('*').each do |node|
        unless node.name == 'br'
          node.remove if node.inner_text.gsub(Envelope::Message::ALL_SPACES, '').empty?
        end
      end

      doc.css('html body *').to_s.squeeze("\n").gsub("\n", '<br>')
    end

    # Attempt to convert the HTML document to it's text part.
    # This is only used in the event that the message was not multi-part and did
    # not specify a text_part MIME
    #
    # @param [String] text the HTML document to extract text from
    # @return [String] the resulting text
    def html2text(text)
      return nil if text.nil? || text.empty?

      doc = Nokogiri::HTML.parse(text.to_s)
      doc.css('script, link, img').each { |node| node.remove } # remove evil things
      doc.css('br').each { |node| node.replace "\n" } # br to newline

      string = doc.css('body').text
      string.gsub! /[\t ]+/, ' '
      string.squeeze! "\n"
      string.squeeze! ' '
      string.gsub! /(\n )+/, "\n"
      string.strip!
      string
    end
  end
end

# require 'net/imap'
# require 'benchmark'
# connection = Net::IMAP.new('imap.gmail.com', port: 993, ssl: true)
# connection.login('', '')
# connection.examine('[Gmail]/Sent Mail')

# uids = connection.uid_search(['ALL'])
# connection.uid_fetch(uids, ['RFC822', 'FLAGS']).each do |message|
#   m = Envelope::Message.new(message)
#   puts "#{m.subject}"
#   puts '='*10
#   puts m.text_part
#   puts '-'*10
#   puts "\n"*5
# end
