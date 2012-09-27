module SidebarHelper
  def link_to_with_class(*args, &block)
    options = args.extract_options!
    options[:class] = "#{options[:class]} active" if current_page?(args[block_given? ? 0 : 1])

    link_to(*(args << options), &block)
  end

  def nested_mailboxes(mailboxes)
    return '' if mailboxes.blank?

    content_tag :ul do
      mailboxes.collect do |mailbox, children|
        content_tag :li do
          (mailbox_link(mailbox) + nested_mailboxes(children)).html_safe
        end
      end.join.html_safe
    end
  end

  # returns the name of the mailbox + the number of unread messages
  # in a nice span for styling
  def name_and_unread(mailbox)
    if mailbox.unread_messages.zero?
      folder_icon(mailbox) + mailbox.name
    else
      folder_icon(mailbox) + mailbox.name + content_tag(:span, mailbox.unread_messages, :class => 'unread-messages-counter')
    end
  end

  # returns the name of the mailbox + it's link
  def mailbox_link(mailbox)
    link_to name_and_unread(mailbox), account_mailbox_messages_path(mailbox.account_id, mailbox), :class => classes_for(mailbox), :'data-mailbox-id' => mailbox._id
  end

  def folder_icon(mailbox)
    account = mailbox.account
    if account.inbox_mailbox == mailbox
      content_tag(:i, '', :class => 'icon-white icon-inbox')
    elsif account.sent_mailbox == mailbox
      content_tag(:i, '', :class => 'icon-white icon-share')
    elsif account.junk_mailbox == mailbox
      content_tag(:i, '', :class => 'icon-white icon-random')
    elsif account.drafts_mailbox == mailbox
      content_tag(:i, '', :class => 'icon-white icon-file')
    elsif account.trash_mailbox == mailbox
      content_tag(:i, '', :class => 'icon-white icon-trash')
    elsif account.starred_mailbox == mailbox
      content_tag(:i, '', :class => 'icon-white icon-star')
    elsif account.important_mailbox == mailbox
      content_tag(:i, '', :class => 'icon-white icon-exclamation-sign')
    else
      content_tag(:i, '', :class => 'icon-white icon-folder-close')
    end
  end

  def classes_for(mailbox)
    classes = ['sidebar-mailbox']

    # add the active class
    classes << 'active' if mailbox._id == params[:mailbox_id]
    classes << 'selectable' if mailbox.selectable?

    classes.join(' ')
  end

end
