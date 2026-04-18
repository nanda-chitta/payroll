FactoryBot.define do
  factory :employee_salary do
    employee { nil }
    amount { "9.99" }
    currency { "MyString" }
    pay_frequency { "MyString" }
    effective_from { "2026-04-18" }
    effective_to { "2026-04-18" }
    reason { "MyString" }
    notes { "MyText" }
  end
end
