require 'rails_helper'

RSpec.describe Employee, type: :model do
  describe 'validations' do
    it 'builds a valid employee from the factory' do
      expect(build(:employee)).to be_valid
    end

    it 'requires a job title' do
      employee = build(:employee, job_title: nil)

      expect(employee).not_to be_valid
      expect(employee.errors[:job_title]).to be_present
    end

    it 'rejects a termination date before the hire date' do
      employee = build(:employee, hire_date: Date.current, termination_date: 1.day.ago.to_date)

      expect(employee).not_to be_valid
      expect(employee.errors[:termination_date]).to include('must be on or after hire date')
    end
  end

  describe 'normalization' do
    it 'normalizes identifying fields' do
      employee = build(:employee, employee_code: ' emp-1 ', email: ' Person@Example.COM ')

      employee.validate

      expect(employee.employee_code).to eq('EMP-1')
      expect(employee.email).to eq('person@example.com')
    end
  end

  describe '#full_name' do
    it 'joins present name parts' do
      employee = build(:employee, first_name: 'Asha', middle_name: nil, last_name: 'Rao')

      expect(employee.full_name).to eq('Asha Rao')
    end
  end

  describe '#current_address' do
    it 'returns the primary address when one exists' do
      employee = create(:employee)
      create(:employee_address, employee:, address_type: 'mailing', city: 'Mumbai')
      primary_address = create(:employee_address, :primary, employee:, address_type: 'home', city: 'Bengaluru')

      expect(employee.current_address).to eq(primary_address)
    end
  end

  describe '#current_salary' do
    it 'returns the salary active today' do
      employee = create(:employee)
      create(:employee_salary, employee:, amount: 60_000, effective_from: 2.years.ago.to_date,
                               effective_to: 1.year.ago.to_date)
      current_salary = create(:employee_salary, employee:, amount: 75_000, effective_from: 1.month.ago.to_date)

      expect(employee.current_salary).to eq(current_salary)
    end
  end

  describe '#as_indexed_json' do
    it 'returns the searchable employee payload' do
      employee = create(:employee, employee_code: 'EMP-10', first_name: 'Maya', last_name: 'Shah', email: 'maya@example.com')
      create(:employee_address, :primary, employee:, country: 'India')

      expect(employee.as_indexed_json).to include(
        employee_code: 'EMP-10',
        first_name: 'Maya',
        last_name: 'Shah',
        email: 'maya@example.com',
        status: employee.status,
        job_title_id: employee.job_title_id,
        country: 'India'
      )
    end

    it 'returns nil country when there is no current address' do
      employee = build(:employee)
      allow(employee).to receive(:current_address).and_return(nil)

      expect(employee.as_indexed_json[:country]).to be_nil
    end
  end

  describe 'date of birth validation' do
    it 'rejects unreasonable dates of birth' do
      employee = build(:employee, date_of_birth: 150.years.ago.to_date)

      expect(employee).not_to be_valid
      expect(employee.errors[:date_of_birth]).to include('is not within a reasonable range')
    end
  end

  describe 'termination date validation' do
    it 'allows a termination date on or after the hire date' do
      employee = build(:employee, hire_date: Date.current, termination_date: Date.current)

      expect(employee).to be_valid
    end
  end
end
