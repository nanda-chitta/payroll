require 'rails_helper'

RSpec.describe 'Api::V1::Lookups', type: :request do
  describe 'GET /api/v1/lookups' do
    it 'returns values needed to render employee forms' do
      department = create(:department, name: 'People')
      job_title = create(:job_title, name: 'HR Manager')
      employee = create(:employee, department:, job_title:)
      create(:employee_address, :primary, employee:, country: 'India')

      get '/api/v1/lookups'

      expect(response).to have_http_status(:ok)
      body = response.parsed_body
      expect(body['departments'].first['name']).to eq('People')
      expect(body['job_titles'].first['name']).to eq('HR Manager')
      expect(body['countries']).to include('India')
      expect(body['employment_types']).to include('full_time')
      expect(body['statuses']).to include('active')
    end
  end
end
