# Populates form when mail provider is selected
$ ->
  @advanced = $('#account_show_advanced_settings')
  @provider_select = $('#account_provider')
  @username = $('#account_email_address')
  @password = $('#account_password')
  @reply_to_address = $('#account_reply_to_address')
  @incoming_server_address = $('#account_incoming_server_address')
  @incoming_server_port = $('#account_incoming_server_port')
  @incoming_server_ssl = $('#account_incoming_server_ssl')
  @incoming_server_username = $('#account_incoming_server_authentication_username')
  @incoming_server_password = $('#account_incoming_server_authentication_password')
  @outgoing_server_address = $('#account_outgoing_server_address')
  @outgoing_server_port = $('#account_outgoing_server_port')
  @outgoing_server_ssl = $('#account_outgoing_server_ssl')
  @outgoing_server_username = $('#account_outgoing_server_authentication_username')
  @outgoing_server_password = $('#account_outgoing_server_authentication_password')
  @imap_directory = $('#account_imap_directory')

  @provider_select.bind 'change', =>
    @provider = @provider_select.children('option:selected')
    @incoming_server_address.val @provider.data('incoming-server-address')
    @incoming_server_port.val @provider.data('incoming-server-port')
    @incoming_server_ssl.attr 'checked', (@provider.data('incoming-server-ssl') == true)
    @outgoing_server_address.val @provider.data('outgoing-server-address')
    @outgoing_server_port.val @provider.data('outgoing-server-port')
    @outgoing_server_ssl.attr 'checked', (@provider.data('outgoing-server-ssl') == true)
    @imap_directory.val @provider.data('imap-directory')

  @advanced.toggle ->
    $(@).html('Hide Advanced Settings')
    $('.advanced').show()
    $('.simple').hide()
    false
  , ->
    $(@).html('Show Advanced Settings')
    $('.advanced').hide()
    $('.simple').show()
    false

  @username.on 'keyup paste blur', =>
    @reply_to_address.val @username.val()
    @incoming_server_username.val @username.val()
    @outgoing_server_username.val @username.val()

  @password.on 'keyup paste blur', =>
    @incoming_server_password.val @password.val()
    @outgoing_server_password.val @password.val()
