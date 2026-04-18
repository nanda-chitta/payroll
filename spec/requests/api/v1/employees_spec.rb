require 'rails_helper'

RSpec.describe 'Api::V1::Employees', type: :request do
  describe 'GET /api/v1/employees' do
    it 'returns employees with country and current salary' do
      employee = create(:employee, first_name: 'Maya', last_name: 'Shah')
      create(:employee_address, :primary, employee:, country: 'India')
      create(:employee_salary, employee:, amount: 90_000)

      get '/api/v1/employees'

      expect(response).to have_http_status(:ok)
      body = response.parsed_body
      expect(body['employees'].first['full_name']).to eq('Maya Shah')
      expect(body['employees'].first['country']).to eq('India')
      expect(body['employees'].first['salary']['amount']).to eq('90000.0')
      expect(body['meta']['total']).to eq(1)
    end
  end

  describe 'POST /api/v1/employees' do
    it 'creates an employee with primary address and current salary' do
      department = create(:department)
      job_title = create(:job_title)

      post '/api/v1/employees', params: {
        employee: employee_payload(department:, job_title:, employee_code: 'EMP-NEW')
      }

      expect(response).to have_http_status(:created)
      body = response.parsed_body.fetch('employee')
      employee = Employee.find(body['id'])

      expect(employee.full_name).to eq('Anika Mehta')
      expect(employee.current_address.country).to eq('India')
      expect(employee.current_salary.amount).to eq(120_000)
    end

    it 'returns validation errors' do
      post '/api/v1/employees', params: { employee: { first_name: '' } }

      expect(response).to have_http_status(:unprocessable_content)
      expect(response.parsed_body['errors']).to include('employee_code')
    end
  end

  describe 'PATCH /api/v1/employees/:id' do
    it 'updates employee profile, country, and salary' do
      employee = create(:employee)
      create(:employee_address, :primary, employee:, country: 'India')
      create(:employee_salary, employee:, amount: 80_000)

      patch "/api/v1/employees/#{employee.id}", params: {
        employee: {
          first_name: 'Updated',
          salary_amount: 95_000,
          country: 'United States'
        }
      }

      expect(response).to have_http_status(:ok)
      employee.reload
      expect(employee.first_name).to eq('Updated')
      expect(employee.current_address.country).to eq('United States')
      expect(employee.current_salary.amount).to eq(95_000)
    end
  end

  describe 'DELETE /api/v1/employees/:id' do
    it 'deletes the employee' do
      employee = create(:employee)

      delete "/api/v1/employees/#{employee.id}"

      expect(response).to have_http_status(:no_content)
      expect(Employee.exists?(employee.id)).to be(false)
    end
  end

  def employee_payload(department:, job_title:, employee_code:)
    {
      employee_code:,
      first_name: 'Anika',
      last_name: 'Mehta',
      email: "#{employee_code.downcase}@example.com",
      hire_date: Date.current,
      employment_type: 'full_time',
      status: 'active',
      department_id: department.id,
      job_title_id: job_title.id,
      line1: '100 Payroll Avenue',
      city: 'Bengaluru',
      postal_code: '560001',
      country: 'India',
      salary_amount: 120_000,
      currency: 'USD',
      pay_frequency: 'monthly'
    }
  end
end
