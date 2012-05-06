class CommonAccountSetting < ActiveRecord::Base
  # associations

  # scopes
  default_scope order('name')

  # instance methods
  def html_options
    {
      :'data-incoming-server-address' => self.incoming_server_address,
      :'data-incoming-server-port' => self.incoming_server_port,
      :'data-incoming-server-ssl' => self.incoming_server_ssl,
      :'data-outgoing-server-address' => self.outgoing_server_address,
      :'data-outgoing-server-port' => self.outgoing_server_port,
      :'data-outgoing-server-ssl' => self.outgoing_server_ssl,
      :'data-imap-directory' => self.imap_directory
    }
  end
end
