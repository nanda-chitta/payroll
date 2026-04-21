FactoryBot.define do
  factory :employee_address do
    employee
    address_type { 'home' }
    line1 { Faker::Address.street_address }
    line2 { nil }
    city { Faker::Address.city }
    state { Faker::Address.state }
    postal_code { Faker::Address.zip_code }
    country { Faker::Address.country }
    primary_address { false }

    trait :primary do
      primary_address { true }
    end
  end
end
