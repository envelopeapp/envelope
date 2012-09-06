object :@server

attributes :address, :port, :ssl

child :server_authentication do
  attributes :username, :encrypted_password
end
