object @participant
attribute :participant_type, :name, :email_address

node :gravatar do |participant|
  "http://www.gravatar.com/avatar/#{Digest::MD5.hexdigest(participant.email_address)}"
end
