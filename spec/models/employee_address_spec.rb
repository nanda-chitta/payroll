require 'rails_helper'

RSpec.describe EmployeeAddress, type: :model do
  describe 'validations' do
    it 'builds a valid address from the factory' do
      expect(build(:employee_address)).to be_valid
    end

    it 'allows only one primary address per employee' do
      employee = create(:employee)
      create(:employee_address, :primary, employee:)

      duplicate = build(:employee_address, :primary, employee:)

      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:primary_address]).to include('already exists for this employee')
    end

    it 'rejects unsupported address types' do
      address = build(:employee_address, address_type: 'vacation')

      expect(address).not_to be_valid
      expect(address.errors[:address_type]).to be_present
    end
  end

  describe 'normalization' do
    it 'strips address fields' do
      address = build(:employee_address, line1: '  123 Main  ', line2: '  Apt 4  ', city: '  Pune  ')

      address.validate

      expect(address.line1).to eq('123 Main')
      expect(address.line2).to eq('Apt 4')
      expect(address.city).to eq('Pune')
    end
  end
end
