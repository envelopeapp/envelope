require 'net/imap'
require File.expand_path 'lib/envelope/message'

module Envelope
  class IMAP
    attr_accessor :settings

    def initialize(account = nil, options = {})
      @account = account.is_a?(Account) ? account : Account.find(account)

      self.settings = {
        address: host,
        port: port,
        username: username,
        password: password,
        authentication: nil,
        ssl?: ssl?
      }.merge(options)
    end

    def connect(&block)
      raise ArgumentError.new('Envelope::IMAP takes a block') unless block_given?

      connection = Net::IMAP.new(settings[:address], port: settings[:port], ssl: settings[:ssl?])
      if settings[:authentication].nil?
        connection.login(settings[:username], settings[:password])
      else
        # authenticate('LOGIN', ...) is not the same as login(...)
        connection.authenticate(settings[:authentication], settings[:username], settings[:password])
      end

      yield connection
    rescue Net::IMAP::NoResponseError => e
      case e.message.strip
      when 'Too many simultaneous connections. (Failure)'
        return
      else
        raise
      end
    ensure
      if defined?(connection) && connection && !connection.disconnected?
        connection.logout
        connection.disconnect
      end
    end

    # Return a list of all mailboxes on this server
    def mailboxes
      self.connect do |connection|
        begin
          connection.xlist(directory, '*')
        rescue
          connection.list(directory, '*')
        end
      end
    end

    def examine(mailbox, &block)
      raise ArgumentError.new("Envelope::IMAP.examine takes a block") unless block_given?

      mailbox_name = mailbox.is_a?(String) ? mailbox : mailbox.location

      self.connect do |connection|
        connection.examine(Net::IMAP.encode_utf7(mailbox_name))
        yield connection
      end
    end

    def select(mailbox, &block)
      raise ArgumentError.new("Envelope::IMAP.select takes a block") unless block_given?

      mailbox_name = mailbox.is_a?(String) ? mailbox : mailbox.location
      self.connect do |connection|
        connection.select(Net::IMAP.encode_utf7(mailbox_name))
        yield connection
      end
    ensure
      if defined?(connection) && connection && !connection.disconnected?
        connection.close
      end
    end

    def uid_store(mailbox, uid, keys, fields, &block)
      self.select(mailbox) do |connection|
        connection.uid_store(uid, keys, fields)
        yield connection if block_given?
      end
    end

    def uid_copy(mailbox, uid, destination, &block)
      destination_name = destination.is_a?(String) ? destination : destination.location

      self.examine(mailbox) do |connection|
        connection.uid_copy(uid, Net::IMAP.encode_utf7(destination_name))
        yield connection if block_given?
      end
    end

    # Fetch messages in the given mailbox parameter using UIDs.
    # This method returns a hash of messages (not an array), in the
    # following format:
    #
    # { uid<String> => message<Envelope::Message> }
    #
    # Example:
    #   { '234' => <Envelope::Message@da2j3a> }
    #
    # This is so we can quickly find a message by its UID without
    # rebuilding the hash.
    #
    # You can easily get an array of all messages by calling `.values`
    # on the returned hash.
    #
    # @param [String] mailbox the mailbox to examine and search
    # @param [Array] set the list of UIDs to search
    # @param [Array] attrs the IMAP message attributes to fetch
    # @return [Hash] the hash of all messages (key: uid)
    def uid_fetch(mailbox, set = [], attrs = [])
      return {} if set.empty?

      examine(mailbox) do |connection|
        # Gmail throws an error on uid_fetch empty mailbox
        if connection.uid_search(['ALL']).try(:size) > 0
          uid_messages = connection.uid_fetch(set, attrs) || []
          list = uid_messages.collect do |imap_message|
            message = ::Envelope::Message.new(imap_message)
            [ message.uid, message ]
          end

          return Hash[ *list.flatten ]
        else
          return {}
        end
      end || {}
    end

    # Search for messages in the given mailbox parameter using UIDs.
    # This method returns an Array of message UIDs
    #
    # Example:
    #   [123, 456, 789]
    #
    # @param [String] mailbox the mailbox to examine and search
    # @param [Array] query the query to search
    # @return [Array] the Array of message UIDs
    def uid_search(mailbox, query = [])
      return [] if query.nil? || query.empty?

      examine(mailbox) do |connection|
        return connection.uid_search(query)
      end || []
    end

    # Return the uid_validity value of the given mailbox
    def get_uid_validity(mailbox)
      mailbox = mailbox.is_a?(Mailbox) ? mailbox.location : mailbox

      self.connect do |connection|
        if status = connection.status(mailbox, ['UIDVALIDITY'])
          return status['UIDVALIDITY'].to_i
        else
          nil
        end
      end
    end


    private
    # Resets the connection and mailbox state.
    def reset
      @connection = nil
    end

    # Gets the IMAP host
    def host
      @account.incoming_server.address
    end

    # Gets the IMAP port
    def port
      @account.incoming_server.port || ssl? ? 993 : 143
    end

    # Gets the IMAP username
    def username
      @account.incoming_server.authentication.username
    end

    # Gets the IMAP password
    def password
      @account.incoming_server.authentication.password
    end

    # Determines if the connection should use ssl
    def ssl?
      @account.incoming_server.ssl?
    end

    # Get the directory where our stuff is stored
    def directory
      @account.imap_directory || ''
    end

    # Gets the server's mailbox hierarchy delimiter.
    def delimiter
      @delimiter ||= self.list[0].delim || '.'
    end
  end
end
