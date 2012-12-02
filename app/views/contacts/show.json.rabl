object @contact
attributes :id,
           :prefix,
           :first_name,
           :middle_name,
           :last_name,
           :suffix,
           :nickname,
           :title,
           :department,
           :birthd,
           :notes

node :contact_url do |contact|
  contact_url(contact)
end

node :gravatar do |contact|
  "http://www.gravatar.com/avatar/#{Digest::MD5.hexdigest(contact.emails.first.try(:email_address))}"
end

child :emails do
  extends 'emails/index'
end

child :phones do
  extends 'emails/phones'
end

child :addresses do
  extends 'emails/addresses'
end
