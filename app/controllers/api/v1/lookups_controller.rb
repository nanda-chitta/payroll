class Api::V1::LookupsController < Api::V1::BaseController
  def index
    lookups = Rails.cache.fetch('lookups:index', expires_in: 15.minutes) do
      {
        departments: Department.ordered.pluck(:id, :name, :code).map { |id, name, code| { id:, name:, code: } },
        job_titles: JobTitle.ordered.pluck(:id, :name, :code).map { |id, name, code| { id:, name:, code: } },
        countries: EmployeeAddress.distinct.order(:country).pluck(:country),
        employment_types: EMPLOYMENT_TYPES,
        statuses: STATUSES,
        pay_frequencies: PAY_FREQUENCIES
      }
    end

    render json: lookups
  end
end
