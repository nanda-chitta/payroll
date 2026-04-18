class Api::V1::EmployeeAddressSerializer < Api::V1::BaseSerializer
  attributes :address_type, :line1, :line2, :city, :state, :postal_code, :country, :primary_address
end
