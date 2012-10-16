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
  include Sidekiq::Worker

  def perform(account_id)
    @account = Account.find_by(id: account_id)
    return if @account.nil?

    # create an imap connection
    @imap = Envelope::IMAP.new(@account)
    imap_mailboxes = @imap.mailboxes.sort!{ |a,b| a.name <=> b.name }

    # delete old mailboxes
    imap_mailbox_locations = imap_mailboxes.collect{ |m| m.name }
    deleted_mailboxes = @account.mailboxes.where(:location.nin => imap_mailbox_locations).destroy_all

    # iterate over each mailbox and create/update it's attributes
    mailboxes_hash = Hash[ *@account.mailboxes.collect{|m| [m.location, m]}.flatten ]

    # iterate over each imap_mailbox and update our local mailbox
    imap_mailboxes.each_with_index do |imap_mailbox, index|
      mailbox = mailboxes_hash[imap_mailbox.name] || @account.mailboxes.new

      # set attributes
      mailbox.name = imap_mailbox.name
      mailbox.location = imap_mailbox.name
      mailbox.flags = imap_mailbox.attr

      mailboxes_hash[mailbox.location] = mailbox

      # does it have a parent?
      location = imap_mailbox.name.split(imap_mailbox.delim)[0...-1].join(imap_mailbox.delim)
      if parent = mailboxes_hash[location]
        mailbox.parent = parent
      end

      mailbox.save! if mailbox.changed?

      MailboxWorker.perform_async(mailbox.id)
    end

    MappingWorker.perform_async(@account.id)

    @account.save! if @account.changed?
  end
end
