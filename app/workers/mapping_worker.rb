#
# Maps each "special" mailbox with its associated types.
#
# @author Seth Vargo
#
class MappingWorker
  include Sidekiq::Worker

  def perform(account_id)
    @account = Account.find_by(id: account_id)
    @user = @account.user
    return if @account.nil?

    @account.mailboxes.each do |mailbox|
      @account.inbox_mailbox      = mailbox if !(mailbox.flags & inbox_flags).empty?      || mailbox.name.downcase =~ /^inbox/
      @account.sent_mailbox       = mailbox if !(mailbox.flags & sent_flags).empty?       || mailbox.name.downcase =~ /^(sent|delivered)/
      @account.junk_mailbox       = mailbox if !(mailbox.flags & junk_flags).empty?       || mailbox.name.downcase =~ /^(junk|spam)/
      @account.drafts_mailbox     = mailbox if !(mailbox.flags & drafts_flags).empty?     || mailbox.name.downcase =~ /^draft/
      @account.trash_mailbox      = mailbox if !(mailbox.flags & trash_flags).empty?      || mailbox.name.downcase =~ /^(trash|deleted)/
      @account.starred_mailbox    = mailbox if !(mailbox.flags & starred_flags).empty?    || mailbox.name.downcase =~ /^starred/
      @account.important_mailbox  = mailbox if !(mailbox.flags & important_flags).empty?  || mailbox.name.downcase =~ /^important/
    end

    if @account.changed?
      @account.save
      publish_finish
    end
  end

  private
  def inbox_flags
    %w(inbox)
  end

  def sent_flags
    %w(sent delivered)
  end

  def junk_flags
    %w(junk spam)
  end

  def drafts_flags
    %w(drafts)
  end

  def trash_flags
    %w(trash deleted removed)
  end

  def starred_flags
    %w(starred)
  end

  def important_flags
    %w(important)
  end

  def publish_finish
    @user.publish('mapping-worker-finish', { account: @account })
  end
end
