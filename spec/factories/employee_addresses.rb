FactoryBot.define do
  factory :employee_address do
    employee
    address_type { 'home' }
    line1 { '123 Payroll Street' }
    line2 { nil }
    city { 'Bengaluru' }
    state { 'Karnataka' }
    postal_code { '560001' }
    country { 'India' }
    primary_address { false }

    trait :primary do
      primary_address { true }
    end
  end
end
