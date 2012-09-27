FactoryGirl.define do
  factory :server do
    address 'server.example.com'
    port 993
    ssl true

    authentication { FactoryGirl.build(:server_authentication) }
  end
end
