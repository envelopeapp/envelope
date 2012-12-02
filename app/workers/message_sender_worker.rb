#
# Send the given message, with all the parameters
#
# - If the message is invalid for any reason, fail gracefully and alert the user
# - When the message is delivered, notify the user
#
# @author Seth Vargo
#
class MessageSenderWorker
  include Sidekiq::Worker

  # Send a message using Mail
  #
  # @param [String] user_id the id of the user delivering this message
  # @param [Hash] message a Ruby hash of the message with strings as keys
  def perform(user_id, message)
    @message  = message
    @user     = User.find_by(id: user_id)
    @account  = @user.accounts.find_by(id: @message['account_id'])

    # Create the basic message
    mail = Mail.new(
      from:       @account.email_address,
      to:         @message['to'],
      cc:         @message['cc'],
      bcc:        @message['bcc'],
      subject:    @message['subject'],
      body:       @message['body']
    )

    # Set the reply-to value, unless it is the same as the account
    unless @account.reply_to_address.blank? || @account.reply_to_address == @account.email_address
      mail.reply_to = @account.reply_to_address
    end

    # Add attachments
    @message['attachments'].each do |attachment|
      mail.add_file attachment['path']
    end unless @message['attachments'].nil?

    # Setup the SMTP server to use the user's credentials
    smtp = @account.outgoing_server
    mail.delivery_method :smtp, address:          smtp.address,
                                port:             smtp.port,
                                ssl:              smtp.ssl?,
                                tls:              smtp.tls?,
                                user_name:        smtp.authentication.username,
                                password:         smtp.authentication.password,
                                authentication:   'plain'

    begin
      mail.deliver!
      publish_finish
    rescue Exception => e
      publish_error(e)
    end
  end

  private
  def publish_finish
    #@user.publish 'message-sender-worker-finish'
  end

  def publish_error(exception = nil)
    #@user.publish 'error', { error: exception.message, message: @message }
  end
end
