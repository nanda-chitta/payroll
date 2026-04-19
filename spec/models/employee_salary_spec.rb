require 'rails_helper'

RSpec.describe EmployeeSalary, type: :model do
  describe 'validations' do
    it 'builds a valid salary from the factory' do
      expect(build(:employee_salary)).to be_valid
    end

    it 'rejects a negative amount' do
      salary = build(:employee_salary, amount: -1)

      expect(salary).not_to be_valid
      expect(salary.errors[:amount]).to be_present
    end

    it 'rejects an effective end date before the start date' do
      salary = build(:employee_salary, effective_from: Date.current, effective_to: 1.day.ago.to_date)

      expect(salary).not_to be_valid
      expect(salary.errors[:effective_to]).to include('must be on or after effective from')
    end
  end

  describe 'normalization' do
    it 'uppercases currency and strips optional text fields' do
      salary = build(:employee_salary, currency: ' usd ', reason: '  promotion  ', notes: '  approved  ')

      salary.validate

      expect(salary.currency).to eq('USD')
      expect(salary.reason).to eq('promotion')
      expect(salary.notes).to eq('approved')
    end
  end

  describe '.current' do
    it 'returns only currently effective salaries' do
      employee = create(:employee)
      expired = create(:employee_salary, employee:, effective_from: 2.years.ago.to_date, effective_to: 1.year.ago.to_date)
      current = create(:employee_salary, employee:, effective_from: 1.month.ago.to_date, effective_to: nil)

      expect(described_class.current).to include(current)
      expect(described_class.current).not_to include(expired)
    end
  end
end
