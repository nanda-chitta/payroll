FactoryBot.define do
  factory :employee_salary do
    employee
    amount { 75_000.00 }
    currency { 'USD' }
    pay_frequency { 'monthly' }
    effective_from { 1.year.ago.to_date }
    effective_to { nil }
    reason { 'Initial salary' }
    notes { nil }
  end
end
