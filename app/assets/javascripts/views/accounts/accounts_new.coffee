class Envelope.Views.AccountsNew extends Backbone.View
  template: JST['accounts/_form']

  events:
    'change select[name=provider]': 'changeProvider'
    'click #account-show-advanced-settings': 'showAdvanced'
    'submit #new-account-form': 'submit'
    'click #account-submit': 'submit'

  initialize: ->
    @options.common_account_settings.on('reset', @render, @)

  changeProvider: (event) ->
    provider = $(event.target).children('option:selected')
    data = JSON.parse(provider.attr('data-provider'))
    $('#incoming_server_attributes_address').val(data.incoming_server_address);
    $('#incoming_server_attributes_port').val(data.incoming_server_port);
    $('#incoming_server_attributes_ssl').attr('checked', data.incoming_server_ssl);
    $('#outgoing_server_attributes_address').val(data.outgoing_server_address);
    $('#outgoing_server_attributes_port').val(data.outgoing_server_port);
    $('#outgoing_server_attributes_ssl').attr('checked', data.outgoing_server_ssl);
    $('#imap_directory').val(data.imap_directory);

  showAdvanced: (event) ->
    $('.advanced').show()
    $('.simple').hide()
    $(event.target).hide()

  submit: (event) ->
    event.preventDefault()
    form_data = form2js('new-account-form', '.', false)

    collection = new Envelope.Collections.Accounts()
    collection.create form_data,
      wait: true
      success: (model, response) ->
        console.log 'model saved!'
        Backbone.history.navigate("accounts/#{model.id}", trigger: true)
      error: @_handleError

  render: ->
    $(@el).html(@template(account: @model, common_account_settings: @options.common_account_settings))
    @

  _handleError: (account, response) ->
    if response.status == 422
      errors = $.parseJSON(response.responseText).errors
      console.error 'There were errors:'
      for attribute, messages of errors
        console.error "#{attribute} #{message}" for message in messages
