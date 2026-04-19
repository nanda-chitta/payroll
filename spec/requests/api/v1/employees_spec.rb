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

    it 'applies text, country, job title, and status filters together' do
      hr_manager = create(:job_title, name: 'HR Manager')
      engineer = create(:job_title, name: 'Engineering Manager')
      india_match = create(:employee, first_name: 'Aarav', last_name: 'Chen', job_title: hr_manager, status: 'active')
      canada_match = create(:employee, first_name: 'Chen', last_name: 'Brown', job_title: hr_manager, status: 'active')
      inactive_match = create(:employee, first_name: 'Chitra', last_name: 'Rao', job_title: hr_manager, status: 'inactive')
      wrong_role = create(:employee, first_name: 'Chandan', last_name: 'Rao', job_title: engineer, status: 'active')
      create(:employee_address, :primary, employee: india_match, country: 'India')
      create(:employee_address, :primary, employee: canada_match, country: 'Canada')
      create(:employee_address, :primary, employee: inactive_match, country: 'India')
      create(:employee_address, :primary, employee: wrong_role, country: 'India')

      get '/api/v1/employees', params: {
        query: 'ch',
        country: 'India',
        job_title_id: hr_manager.id,
        status: 'active'
      }

      expect(response).to have_http_status(:ok)
      body = response.parsed_body
      expect(body['meta']['total']).to eq(1)
      expect(body['employees'].pluck('id')).to eq([ india_match.id ])
      expect(body['employees'].pluck('country')).to eq([ 'India' ])
    end

    it 'normalizes service failures from index' do
      service = instance_double(EmployeeManagement::AppServices::EmployeeService)
      stub_const('AppContainer', double(:[] => service))
      allow(service).to receive(:employee_search).and_return(Dry::Monads::Failure(:bad_request))

      get '/api/v1/employees'

      expect(response).to have_http_status(:bad_request)
      expect(response.parsed_body['error']['code']).to eq('bad_request')
    end

    it 'paginates array results from the service' do
      first_employee = create(:employee, first_name: 'Asha', employee_code: 'EMP-00001', email: 'asha@example.com')
      second_employee = create(:employee, first_name: 'Bea', employee_code: 'EMP-00002', email: 'bea@example.com')
      create(:employee_address, :primary, employee: first_employee, country: 'India')
      create(:employee_address, :primary, employee: second_employee, country: 'India')
      create(:employee_salary, employee: first_employee, amount: 100_000)
      create(:employee_salary, employee: second_employee, amount: 120_000)

      service = instance_double(EmployeeManagement::AppServices::EmployeeService)
      stub_const('AppContainer', double(:[] => service))
      allow(service).to receive(:employee_search).and_return(Dry::Monads::Success([first_employee, second_employee]))

      get '/api/v1/employees', params: { page: 1, per_page: 1 }

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body['employees'].length).to eq(1)
      expect(response.parsed_body['employees'].first['id']).to eq(first_employee.id)
    end
  end

  describe 'GET /api/v1/employees/:id' do
    it 'returns a single employee payload' do
      employee = create(:employee, first_name: 'Maya', last_name: 'Shah')
      create(:employee_address, :primary, employee:, country: 'India')
      create(:employee_salary, employee:, amount: 90_000)

      get "/api/v1/employees/#{employee.id}"

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body.fetch('employee').fetch('full_name')).to eq('Maya Shah')
    end
  end

  describe 'POST /api/v1/employees' do
    it 'creates an employee with primary address and current salary' do
      department = create(:department)
      job_title = create(:job_title)

      post '/api/v1/employees', params: {
        employee: employee_payload(department:, job_title:, employee_code: 'EMP-NEW')
      }, as: :json

      expect(response).to have_http_status(:created)
      body = response.parsed_body.fetch('employee')
      employee = Employee.find(body['id'])

      expect(employee.full_name).to eq('Anika Mehta')
      expect(employee.current_address.country).to eq('India')
      expect(employee.current_salary.amount).to eq(120_000)
    end

    it 'returns validation errors' do
      post '/api/v1/employees', params: { employee: { first_name: '' } }, as: :json

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
      }, as: :json

      expect(response).to have_http_status(:ok)
      employee.reload
      expect(employee.first_name).to eq('Updated')
      expect(employee.current_address.country).to eq('United States')
      expect(employee.current_salary.amount).to eq(95_000)
    end

    it 'returns not found when updating a missing employee' do
      patch '/api/v1/employees/999999', params: { employee: { first_name: 'Updated' } }, as: :json

      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'DELETE /api/v1/employees/:id' do
    it 'deletes the employee' do
      employee = create(:employee)

      delete "/api/v1/employees/#{employee.id}"

      expect(response).to have_http_status(:no_content)
      expect(Employee.exists?(employee.id)).to be(false)
    end

    it 'returns not found when deleting a missing employee' do
      delete '/api/v1/employees/999999'

      expect(response).to have_http_status(:not_found)
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
