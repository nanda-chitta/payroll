module Api
  module V1
    class LookupsController < ApplicationController
      def index
        render json: {
          departments: Department.ordered.pluck(:id, :name, :code).map { |id, name, code| { id:, name:, code: } },
          job_titles: JobTitle.ordered.pluck(:id, :name, :code).map { |id, name, code| { id:, name:, code: } },
          countries: EmployeeAddress.distinct.order(:country).pluck(:country),
          employment_types: EMPLOYMENT_TYPES,
          statuses: STATUSES,
          pay_frequencies: PAY_FREQUENCIES
        }
      end
    end
  end
end
