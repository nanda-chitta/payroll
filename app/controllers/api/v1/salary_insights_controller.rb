module Api
  module V1
    class SalaryInsightsController < ApplicationController
      def index
        render json: SalaryInsights::CountryReport.call(country: params[:country], job_title_id: params[:job_title_id])
      end
    end
  end
end
