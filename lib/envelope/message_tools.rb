# encoding: utf-8

module Envelope
  module MessageTools
    require 'nokogiri'

    def self.included(base)
      base.send :extend, ClassMethods
      base.send :include, InstanceMethods
    end

    module ClassMethods

    end

    module InstanceMethods
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

      # Determines if this message has been answered
      #
      # @return [Boolean] true if the message has been answered, false otherwise
      def answered?
        !(%w(answered) & flags).empty?
      end
    end

    module ModuleMethods
      # Attempt to normalize the text by converting everything to utf-8, and converting
      # newlines and breaks appropriately.
      #
      # @param [String] text the text to normalize
      # @return [String] a utf-8 encoded string with normalized line breaks and spaces
      def normalize(text)
        return nil if text.nil? || text.empty?
        string = Mail::Encodings.decode_encode(text.to_s, :decode)

        string.gsub! /\r\n?/, "\n" # normalize line breaks
        string.gsub! '&nbsp;', ' '
        string.gsub! /[[:blank:]]+/, ' ' # convert all spaces to normal-people spaces

        string.encode!(:invalid => :replace, :undef => :replace, :replace => '?')
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
        string.gsub! /(<[\w\s=:"#]+>|^)+On.+at.+wrote:.*/mi, ''

        # Begin forwarded message:
        string.gsub! /(<[\w\s=:"#]+>|^)+Begin\ forwarded\ message:.*/mi, ''
        string.strip!
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
        doc.xpath('//comment()').remove

        # remove "bad" elements
        doc.css('script, link, img, style').each { |node| node.remove }

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

        # removing tags leaves dangling text nodes that should really be merged, so let's
        # re-build the document
        doc = Nokogiri::HTML.parse(doc.to_s)

        # wrap orphaned text nodes in <p> tags
        doc.css('html body').children.each do |orphan|
          if orphan.class == Nokogiri::XML::Text && !orphan.text.strip.gsub(Envelope::Message::ALL_SPACES, '').empty?
            node = doc.create_element 'p'
            node.inner_html = orphan.text
            orphan.replace(node)
          end
        end

        # remove all <p><br><p>
        doc.css('p br').each do |node|
          node.remove
        end

        # convert all new lines to br and trim content
        doc.css('p').each do |node|
          node.inner_html = node.inner_html.gsub("\n", '<br>').strip
        end

        # remove empty tags
        doc.css('html body > *').each do |node|
          unless %w(br p).include?(node.name)
            node.remove if node.inner_html.gsub(Envelope::Message::ALL_SPACES, '').empty?
          end
        end

        doc.css('html body > *').to_s.gsub(/[\n\t]+?/, '')
      end

      # Attempt to convert the HTML document to it's text part.
      # This is only used in the event that the message was not multi-part and did
      # not specify a text_part MIME
      #
      # @param [String] text the HTML document to extract text from
      # @return [String] the resulting text
      def html_to_text(text)
        return nil if text.nil? || text.empty?
        text.gsub! /<br( \/)?>/i, "\n"

        string = Nokogiri::HTML.parse(text.to_s).css('body').text
        string.gsub! /[[:blank:]]/, ' '
        string = string.split("\n").collect{ |line| line.strip }.join("\n")
        string.gsub! /(\n{1,})\n/ do |match|; $1; end # convert x\n to (x-1)\n
        string.strip!
        string
      end
    end
    extend ModuleMethods
  end
end
