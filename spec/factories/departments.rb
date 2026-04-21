FactoryBot.define do
  factory :department do
    sequence(:name) { |n| "#{Faker::Company.industry} #{n}" }
    sequence(:code) { |n| "DPT#{n}" }
    description { Faker::Lorem.sentence(word_count: 6) }
  end
end
