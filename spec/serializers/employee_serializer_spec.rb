require 'rails_helper'

RSpec.describe Api::V1::EmployeeSerializer do
  it 'returns nil for optional associations when they are missing' do
    employee = build(:employee)
    allow(employee).to receive(:department).and_return(nil)
    allow(employee).to receive(:job_title).and_return(nil)
    allow(employee).to receive(:current_address).and_return(nil)
    allow(employee).to receive(:current_salary).and_return(nil)

    serializer = described_class.new(employee)

    expect(serializer.department).to be_nil
    expect(serializer.job_title).to be_nil
    expect(serializer.address).to be_nil
    expect(serializer.salary).to be_nil
    expect(serializer.country).to be_nil
  end

  it 'serializes present associations' do
    employee = create(:employee)
    address = create(:employee_address, :primary, employee:, country: 'India')
    salary = create(:employee_salary, employee:, amount: 90_000)

    serializer = described_class.new(employee)

    expect(serializer.country).to eq('India')
    expect(serializer.department).to include(id: employee.department.id, name: employee.department.name, code: employee.department.code)
    expect(serializer.job_title).to include(id: employee.job_title.id, name: employee.job_title.name, code: employee.job_title.code)
    expect(serializer.address).to include(id: address.id)
    expect(serializer.salary).to include(id: salary.id)
  end
end
