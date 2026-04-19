require 'rails_helper'

RSpec.describe Payroll::SalaryInsights::CountryReport do
  describe '#call' do
    it 'returns an internal error when report generation fails' do
      allow(Rails.cache).to receive(:fetch).and_raise(StandardError, 'cache boom')

      result = described_class.new.call(country: 'India', job_title_id: nil)

      expect(result).to be_failure
      expect(result.failure).to eq(type: :internal_error, message: 'cache boom')
    end

    it 'handles blank country and blank job title filters' do
      report = described_class.new.call(country: '', job_title_id: '')

      expect(report).to be_success
      expect(report.value![:country]).to be_nil
      expect(report.value![:selected_job_title_id]).to be_nil
    end
  end
end
