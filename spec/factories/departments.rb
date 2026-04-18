FactoryBot.define do
  factory :department do
    sequence(:name) { |n| "Department #{n}" }
    sequence(:code) { |n| "D#{n}" }
    description { 'Department description' }
  end
end
