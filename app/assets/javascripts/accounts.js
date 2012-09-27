// Populates form when mail provider is selected
$(function() {
  $('#account_provider').bind('change', function() {
    var $provider = $(this).children('option:selected');

    // grab all the values
    var incoming_server_address = $provider.attr('data-incoming-server-address');
    var incoming_server_port = $provider.attr('data-incoming-server-port');
    var incoming_server_ssl = $provider.attr('data-incoming-server-ssl') === 'true';
    var outgoing_server_address = $provider.attr('data-outgoing-server-address');
    var outgoing_server_port = $provider.attr('data-outgoing-server-port');
    var outgoing_server_ssl = $provider.attr('data-outgoing-server-ssl') === 'true';
    var imap_directory = $provider.attr('data-imap-directory');

    // populate the fields
    $('#account_incoming_server_attributes_address').val(incoming_server_address);
    $('#account_incoming_server_attributes_port').val(incoming_server_port);
    $('#account_incoming_server_attributes_ssl').attr('checked', incoming_server_ssl);
    $('#account_outgoing_server_attributes_address').val(outgoing_server_address);
    $('#account_outgoing_server_attributes_port').val(outgoing_server_port);
    $('#account_outgoing_server_attributes_ssl').attr('checked', outgoing_server_ssl);
    $('#account_imap_directory').val(imap_directory);
  });

  $('#account_email_address').on('keyup paste blur', function() {
    var value = $(this).val();
    $('#account_incoming_server_attributes_authentication_attributes_username').val(value);
    $('#account_outgoing_server_attributes_authentication_attributes_username').val(value);
  });

  $('#account_password').on('keyup paste blur', function() {
    var value = $(this).val();
    $('#account_incoming_server_attributes_authentication_attributes_password').val(value);
    $('#account_outgoing_server_attributes_authentication_attributes_password').val(value);
  });

  $('#account_show_advanced_settings').toggle(function() {
    $(this).html('Hide Advanced Settings');
    $('.advanced').show();
    $('.simple').hide();
  }, function() {
    $(this).html('Show Advanced Settings');
    $('.advanced').hide();
    $('.simple').show();
  });

  $('.contact-link').live('click', function(e) {
    e.preventDefault();

    var $contactPane = $('#contact_pane');

    var url = $(this).attr('href') + '.json';
    $.getJSON(url, function(contact) {
      $contactPane.html(JST['views/contacts/show']({ contact:contact }));
    });
  });
});
