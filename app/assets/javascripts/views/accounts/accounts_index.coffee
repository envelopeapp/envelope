class Envelope.Views.AccountsIndex extends Backbone.View
  template: JST['accounts/index']

  events:
    'click #new-account-button': 'navigateNew'
    'click .delete-account': 'deleteAccount'
    'change input': 'fieldChanged'

  initialize: ->
    @collection.on('reset', @render, @)

  # Navigation functions
  # These functions basically control the routing flow
  navigateNew: (event) ->
    event.preventDefault()
    Backbone.history.navigate('accounts/new', trigger: true)

  # Other event functions
  fieldChanged: (event) ->
    field = $(event.target)
    attributes = {}
    attributes['id'] = field.parents('form').attr('data-account-id')
    attributes[field.attr('name')] = field.val()

    model = new Envelope.Models.Account()
    model.save(
      attributes,
      success: (model, response) ->
        control_div = field.parent().parent()
        control_div.addClass('success')
        setTimeout (-> control_div.removeClass('success')), 2500
      error: (model, response) ->
        console.error(response)
    )

  deleteAccount: (event) ->
    event.preventDefault()
    account_id = $(event.target).attr('data-account-id')
    account = new Envelope.Models.Account(id: account_id)
    account.destroy(
      success: (model, response) =>
        @render()
      error: (model, response) ->
        console.error 'There were errors'
    )

    @collection.reset()

  render: ->
    $(@el).html(@template(accounts: @collection))
    @
