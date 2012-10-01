class Envelope.Sidebar extends Spine.Controller
  events:
    'click [data-mailbox-id]': 'click'

  constructor: ->
    super

    Envelope.Account.bind 'refresh change', @render
    Envelope.Account.fetch()

    @render()

  release: ->
    Envelope.Account.unbind 'refresh change', @render

  render: =>
    @accounts = Envelope.Account.all()
    @html @view('sidebar/main')(@)

    # Select first mailbox
    @$('[data-mailbox-id]:first').click()

  click: (e) ->
    element = $(e.target)
    item = element.item
    Spine.trigger 'change', item

  helper:
    arrange: (mailboxes) ->
      JST['app/views/sidebar/_mailboxes'](mailboxes: mailboxes)
