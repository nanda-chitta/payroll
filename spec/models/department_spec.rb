require 'rails_helper'

RSpec.describe Department, type: :model do
  describe 'validations' do
    it 'requires a name and code' do
      department = described_class.new

      expect(department).not_to be_valid
      expect(department.errors[:name]).to be_present
      expect(department.errors[:code]).to be_present
    end
  end

  describe 'normalization' do
    it 'strips text fields and uppercases code' do
      department = build(:department, name: '  Finance  ', code: ' fin ', description: '  Payroll team  ')

      department.validate

      expect(department.name).to eq('Finance')
      expect(department.code).to eq('FIN')
      expect(department.description).to eq('Payroll team')
    end
  end
end
