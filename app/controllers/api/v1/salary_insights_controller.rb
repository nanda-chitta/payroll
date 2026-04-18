module Api
  module V1
    class SalaryInsightsController < ApplicationController
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
  end
end
