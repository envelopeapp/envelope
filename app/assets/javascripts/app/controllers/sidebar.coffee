class Envelope.Sidebar extends Spine.Controller
  constructor: ->
    super

    Envelope.Account.bind 'refresh change', @render
    Envelope.Account.fetch()

    @render()

  render: =>
    @accounts = Envelope.Account.all()
    @html @view('sidebar/main')(@)

  helper:
    arrange: (mailboxes) ->
      JST['app/views/sidebar/test'](mailboxes: mailboxes)

# def nested_mailboxes(mailboxes)
#   return '' if mailboxes.blank?

#   content_tag :ul do
#     mailboxes.collect do |mailbox, children|
#       content_tag :li do
#         (mailbox_link(mailbox) + nested_mailboxes(children)).html_safe
#       end
#     end.join.html_safe
#   end
# end
