#
# Loads an account including all the mailboxes
#
# - If a mailbox in our database no longer exists on the remote server, that mailbox (along
#   with all it's messages, etc) is destroyed
# - If a mailbox not in our database exists on the remote server, that mailbox is created and
#   associated with the account
# - If a mailbox is in our database and exists on the remote server, we update any attributes
#   that might have changed (such as attr) and save the existing mailbox
#
# This Job does NOT import messages.
#
# @author Seth Vargo
#
class AccountWorker
  require 'envelope/imap'
  include Sidekiq::Worker

  def perform(account_id)
    @account = Account.find(account_id)
    @user = @account.user

    publish_start

    # create an imap connection
    @imap = Envelope::IMAP.new(@account)
    imap_mailboxes = @imap.mailboxes.sort!{ |a,b| a.name <=> b.name }

    # delete old mailboxes
    @account.mailboxes.where(:location.nin => imap_mailboxes.map(&:name)).destroy_all

    # iterate over each imap_mailbox and update our local mailbox
    imap_mailboxes.each_with_index do |imap_mailbox, index|
      mailbox = @account.mailboxes.where(location: imap_mailbox.name).first || @account.mailboxes.new

      # set attributes
      mailbox.name = imap_mailbox.name.split(imap_mailbox.delim)[-1]    # INBOX.My Folder.Sub-Folder => Sub-Folder
      mailbox.location = imap_mailbox.name
      mailbox.flags = imap_mailbox.attr.collect{ |f| f.to_s.downcase }

      # does it have a parent?
      path = imap_mailbox.name.split(imap_mailbox.delim)        # INBOX.My Folder.Sub-Folder
      parent_location = path[0...-1].join(imap_mailbox.delim)   # INBOX.My Folder
      if parent = @account.mailboxes.where(location: parent_location).first
        mailbox.parent = parent
      end

      mailbox.save! if mailbox.changed?

      MailboxWorker.perform_async(mailbox.id)
    end

    MappingWorker.perform_async(@account.id)

    @account.save! if @account.changed?

    publish_finish
  end

  private
  def publish_start
    @user.publish('account-worker-start', { account: @account })
  end

  def publish_finish
    @user.publish('account-worker-finish', { account: @account })
  end
end
