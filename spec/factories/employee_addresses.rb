FactoryBot.define do
  factory :employee_address do
    employee { nil }
    address_type { "MyString" }
    line1 { "MyString" }
    line2 { "MyString" }
    city { "MyString" }
    state { "MyString" }
    postal_code { "MyString" }
    country { "MyString" }
    primary_address { false }
  end
end
