# Common Account Settings
CommonAccountSetting.create!(name:'AOL', incoming_server_address:'imap.aol.com', incoming_server_port:993, incoming_server_ssl:true, outgoing_server_address:'smtp.aol.com', outgoing_server_port:'587', outgoing_server_ssl:true, imap_directory:'[Gmail]')
CommonAccountSetting.create!(name:'CMU', incoming_server_address:'cyrus.andrew.cmu.edu', incoming_server_port:993, incoming_server_ssl:true, outgoing_server_address:'smtp.andrew.cmu.edu', outgoing_server_port:'465', outgoing_server_ssl:true, imap_directory:'INBOX')
CommonAccountSetting.create!(name:'Yahoo!', incoming_server_address:'imap.mail.yahoo.com', incoming_server_port:993, incoming_server_ssl:true, outgoing_server_address:'smtp.mail.yahoo.com', outgoing_server_port:'465', outgoing_server_ssl:true)
CommonAccountSetting.create!(name:'Gmail', incoming_server_address:'imap.gmail.com', incoming_server_port:993, incoming_server_ssl:true, outgoing_server_address:'smtp.gmail.com', outgoing_server_port:'465', outgoing_server_ssl:true)

user = User.create!(first_name:'Seth', last_name:'Vargo', username:'svargo', email_address:ENV['GMAIL_USERNAME'], password:'test', confirmed_at:Time.now)
user.accounts.create!(
  name: 'Gmail',
  slug: 'gmail',
  email_address: ENV['GMAIL_USERNAME'],
  reply_to_address: ENV['GMAIL_USERNAME'],
  imap_directory: '[Gmail]',
  incoming_server_attributes: {
    address: 'imap.gmail.com',
    port: 993,
    ssl: true,
    server_authentication_attributes: {
      username: ENV['GMAIL_USERNAME'],
      password: ENV['GMAIL_PASSWORD']
    },
  },
  outgoing_server_attributes: {
    address: 'smtp.gmail.com',
    port: 465,
    ssl: true,
    server_authentication_attributes: {
      username: ENV['GMAIL_USERNAME'],
      password: ENV['GMAIL_PASSWORD']
    },
  },
)
