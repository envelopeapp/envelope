class CommonAccountSetting
  include Mongoid::Document

  # fields
  field :name, type: String
  field :incoming_server, type: Hash
  field :outgoing_server, type: Hash
  field :imap_directory, type: String

  # associations

  # validations
  validates_presence_of :name, :incoming_server, :outgoing_server

  # scopes
  default_scope order_by(:name => :asc)

  # instance methods
  def html_options
    {
      :'data-incoming-server-address'  =>   incoming_server[:address],
      :'data-incoming-server-port'     =>   incoming_server[:port],
      :'data-incoming-server-ssl'      =>   incoming_server[:ssl],
      :'data-outgoing-server-address'  =>   outgoing_server[:address],
      :'data-outgoing-server-port'     =>   outgoing_server[:port],
      :'data-outgoing-server-ssl'      =>   outgoing_server[:ssl],
      :'data-imap-directory'           =>   imap_directory,
    }
  end
end
