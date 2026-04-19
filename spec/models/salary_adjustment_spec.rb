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

    it 'keeps percentage nil when previous amount is zero' do
      adjustment = build(:salary_adjustment, previous_amount: 0, new_amount: 125)

      adjustment.validate

      expect(adjustment.change_amount).to eq(125)
      expect(adjustment.change_percentage).to be_nil
    end

    it 'skips derived fields when the required amounts are blank' do
      adjustment = build(:salary_adjustment, previous_amount: nil, new_amount: nil, change_amount: nil)

      adjustment.validate

      expect(adjustment.change_amount).to be_nil
    end

    it 'adds an error when change amount does not match the salary delta' do
      adjustment = build(:salary_adjustment, previous_amount: 100, new_amount: 125)

      adjustment.validate
      adjustment.change_amount = 10
      adjustment.errors.clear
      adjustment.send(:change_amount_matches_amounts)

      expect(adjustment.errors[:change_amount]).to include('must equal new amount minus previous amount')
    end

    it 'skips the change amount validation when a required amount is missing' do
      adjustment = build(:salary_adjustment, previous_amount: nil, new_amount: nil, change_amount: nil)

      adjustment.send(:change_amount_matches_amounts)

      expect(adjustment.errors[:change_amount]).to be_empty
    end

    it 'skips employee salary matching when employee or salary is blank' do
      adjustment = build(:salary_adjustment, employee: nil)

      adjustment.validate

      expect(adjustment.errors[:employee_salary]).to be_empty
    end
  end
end
