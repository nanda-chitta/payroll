class Api::V1::SalaryInsightsController < Api::V1::BaseController
  def index
    render_result(country_report.call(country: params[:country], job_title_id: params[:job_title_id])) do |report|
      report
    end
  end

  private

  def country_report
    AppContainer['payroll.salary_insights.country_report']
  end
end
