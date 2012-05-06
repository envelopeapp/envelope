FactoryGirl.define do
  factory :label do
    association :user

    name 'Default Label'
    color 'label-warning'
  end
end