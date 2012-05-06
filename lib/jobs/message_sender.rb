module Jobs
  # This Job sends a message for the current account and authentication
  # and then tells the front end the message has been delivered (or failed)
  class MessageSender < Struct.new(:user_id, :message_hash)
    def before
      @user = User.find(user_id)
      @account = @user.accounts.find(message_hash[:account_id])
    end

    def perform
      mail = Mail.new
      mail.from = @account.email_address
      mail.reply_to = @account.reply_to_address.presence || @account.email_address
      mail.to = message_hash[:to].presence
      mail.cc = message_hash[:cc].presence
      mail.bcc = message_hash[:bcc].presence
      mail.subject = message_hash[:subject].presence
      mail.body = message_hash[:body]

      mail.delivery_method :smtp, :address => @account.outgoing_server.address,
                                  :port => @account.outgoing_server.port,
                                  :user_name => @account.outgoing_server.server_authentication.username,
                                  :password => @account.outgoing_server.server_authentication.password,
                                  :authentication => 'plain',
                                  :ssl => true,
                                  :tls => true
      begin
        mail.deliver!
      rescue => e
        PrivatePub.publish_to @user.queue_name, :action => 'error', :message => e
      end
    end

    def success
      PrivatePub.publish_to @user.queue_name, :action => 'notice', :message => 'Message was delivered!'
    end
  end
end