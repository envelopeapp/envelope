# Common Account Settings
CommonAccountSetting.create!(
  name:'AOL',
  incoming_server: {
    address:'imap.aol.com',
    port:993,
    ssl:true,
  },
  outgoing_server: {
    address:'smtp.aol.com',
    port:'587',
    ssl:true,
  },
  imap_directory:'[Gmail]'
)

CommonAccountSetting.create!(
  name:'CMU',
  incoming_server: {
    address:'cyrus.andrew.cmu.edu',
    port:993,
    ssl:true,
  },
  outgoing_server: {
    address:'smtp.andrew.cmu.edu',
    port:'465',
    ssl:true,
  },
  imap_directory:'INBOX'
)

CommonAccountSetting.create!(
  name:'Yahoo!',
  incoming_server: {
    address:'imap.mail.yahoo.com',
    port:993,
    ssl:true,
  },
  outgoing_server: {
    address:'smtp.mail.yahoo.com',
    port:'465',
    ssl:true,
  }
)

CommonAccountSetting.create!(
  name:'Gmail',
  incoming_server: {
    address:'imap.gmail.com',
    port:993,
    ssl:true,
  },
  outgoing_server: {
    address:'smtp.gmail.com',
    port:'465',
    ssl:true
  }
)

# User
user = User.create!(first_name: 'Default', last_name: 'User', username: ENV['ANDREW_ID'], password: 'test', email_address: "#{ENV['ANDREW_ID']}@andrew.cmu.edu", confirmed_at: Time.now)

user.accounts.create!(
  name: 'CMU Cyrus',
  email_address: "#{ENV['ANDREW_ID']}@andrew.cmu.edu",
  imap_directory: 'INBOX',
  incoming_server: {
    address:'cyrus.andrew.cmu.edu',
    port:993,
    ssl:true,
    authentication_attributes: {
      username: ENV['ANDREW_ID'],
      password: ENV['ANDREW_PASSWORD'],
    }
  },
  outgoing_server: {
    address:'smtp.andrew.cmu.edu',
    port:'465',
    ssl:true,
    authentication_attributes: {
      username: ENV['ANDREW_ID'],
      password: ENV['ANDREW_PASSWORD'],
    }
  },
)
