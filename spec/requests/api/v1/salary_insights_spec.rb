require 'rails_helper'

RSpec.describe 'Api::V1::SalaryInsights', type: :request do
  describe 'GET /api/v1/salary_insights' do
    it 'returns country and job-title salary aggregates' do
      engineer = create(:job_title, name: 'Engineer', code: 'ENG')
      analyst = create(:job_title, name: 'Analyst', code: 'ANL')

      create_employee_with_salary(country: 'India', job_title: engineer, amount: 100_000)
      create_employee_with_salary(country: 'India', job_title: engineer, amount: 150_000)
      create_employee_with_salary(country: 'India', job_title: analyst, amount: 50_000)
      create_employee_with_salary(country: 'Canada', job_title: engineer, amount: 200_000)

      get '/api/v1/salary_insights', params: { country: 'India', job_title_id: engineer.id }

      expect(response).to have_http_status(:ok)
      body = response.parsed_body

      expect(body['country_salary']).to include(
        'employee_count' => 3,
        'minimum_salary' => '50000.00',
        'maximum_salary' => '150000.00',
        'average_salary' => '100000.00'
      )
      expect(body['job_title_salary']).to include(
        'employee_count' => 2,
        'minimum_salary' => '100000.00',
        'maximum_salary' => '150000.00',
        'average_salary' => '125000.00'
      )
      expect(body['headcount_by_job_title'].first['name']).to eq('Engineer')
    end
  end

  def create_employee_with_salary(country:, job_title:, amount:)
    employee = create(:employee, job_title:)
    create(:employee_address, :primary, employee:, country:)
    create(:employee_salary, employee:, amount:)
  end
end
