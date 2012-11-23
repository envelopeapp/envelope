FactoryGirl.define do
  factory :attachment do
    sequence(:filename){ |i| "file_#{i}" }
    size 1000000
  end
end
