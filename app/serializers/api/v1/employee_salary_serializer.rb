class Api::V1::EmployeeSalarySerializer < Api::V1::BaseSerializer
  attributes :amount, :currency, :pay_frequency, :effective_from, :effective_to
end
