require 'rails_helper'

RSpec.describe SalaryAdjustment, type: :model do
  describe 'validations' do
    it 'builds a valid adjustment from the factory' do
      expect(build(:salary_adjustment)).to be_valid
    end

    it 'rejects unsupported reasons' do
      adjustment = build(:salary_adjustment, reason: 'bonus')

      expect(adjustment).not_to be_valid
      expect(adjustment.errors[:reason]).to be_present
    end

    it 'requires the salary to belong to the same employee' do
      adjustment = build(:salary_adjustment, employee: create(:employee))

      expect(adjustment).not_to be_valid
      expect(adjustment.errors[:employee_salary]).to include('must belong to the same employee')
    end
  end

  describe 'calculated fields' do
    it 'calculates amount and percentage change before validation' do
      adjustment = build(:salary_adjustment, previous_amount: 100, new_amount: 125)

      adjustment.validate

      expect(adjustment.change_amount).to eq(25)
      expect(adjustment.change_percentage).to eq(25)
    end
  end
end
