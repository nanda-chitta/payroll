FactoryBot.define do
  factory :employee_salary do
    employee
    amount { Faker::Number.decimal(l_digits: 5, r_digits: 2).to_f }
    currency { 'USD' }
    pay_frequency { 'monthly' }
    effective_from { Faker::Date.backward(days: 365) }
    effective_to { nil }
    reason { Faker::Lorem.sentence(word_count: 3) }
    notes { nil }
  end
end
