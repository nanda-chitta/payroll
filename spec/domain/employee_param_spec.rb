require 'rails_helper'

RSpec.describe EmployeeManagement::AppServices::Validators::EmployeeParam do
  subject(:validator) { described_class.new }

  let(:params) do
    ActionController::Parameters.new(
      employee_code: 'EMP-1',
      first_name: 'Maya',
      last_name: 'Shah',
      email: 'maya@example.com',
      hire_date: Date.current,
      employment_type: 'full_time',
      status: 'active',
      department_id: 1,
      job_title_id: 1,
      country: 'India',
      salary_amount: 100_000
    )
  end

  it 'validates create params from ActionController::Parameters' do
    result = validator.call(params)

    expect(result).to be_success
    expect(result.value![:employee_code]).to eq('EMP-1')
  end

  it 'validates partial update params' do
    result = validator.call(ActionController::Parameters.new(first_name: 'Updated'), partial: true)

    expect(result).to be_success
    expect(result.value!).to eq(first_name: 'Updated')
  end

  it 'normalizes plain hashes without relying on ActionController parameters' do
    result = validator.call(
      {
        employee_code: 'EMP-2',
        first_name: 'Riya',
        last_name: 'Mehta',
        email: 'riya@example.com',
        hire_date: Date.current,
        employment_type: 'full_time',
        status: 'active',
        department_id: 1,
        job_title_id: 1,
        country: 'India',
        salary_amount: 110_000
      }
    )

    expect(result).to be_success
    expect(result.value![:employee_code]).to eq('EMP-2')
  end
end
