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
  attributes :id, :label, :email_address
end

child :phones do
  attributes :id, :label, :phone_number
end

child :addresses do
  attributes :id, :label, :line_1, :line_2, :city, :state, :country, :zip_code
end
