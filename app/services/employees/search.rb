module Employees
  class Search
    DEFAULT_LIMIT = 25
    MAX_LIMIT = 100

    def self.call(params:)
      new(params:).call
    end

    def initialize(params:)
      @params = params
    end

    def call
      employees = Employee
                  .includes(:department, :job_title, :employee_addresses, :employee_salaries)
                  .references(:employee_addresses, :job_titles)
                  .left_joins(:employee_addresses, :job_title)
                  .where(employee_addresses: { primary_address: true })
                  .order(created_at: :desc)

      employees = apply_filters(employees)
      total = employees.count
      page = params.fetch(:page, 1).to_i.clamp(1, Float::INFINITY)
      limit = params.fetch(:limit, DEFAULT_LIMIT).to_i.clamp(1, MAX_LIMIT)

      {
        employees: employees.offset((page - 1) * limit).limit(limit),
        meta: {
          page:,
          limit:,
          total:,
          total_pages: (total.to_f / limit).ceil
        }
      }
    end

    private

    attr_reader :params

    def apply_filters(scope)
      scope = scope.where(status: params[:status]) if params[:status].present?
      scope = scope.where(employee_addresses: { country: params[:country] }) if params[:country].present?
      scope = scope.where(job_title_id: params[:job_title_id]) if params[:job_title_id].present?

      return scope if params[:query].blank?

      query = "%#{ActiveRecord::Base.sanitize_sql_like(params[:query].strip)}%"

      scope.where(
        'employees.employee_code ILIKE :query OR employees.first_name ILIKE :query OR employees.last_name ILIKE :query OR employees.email ILIKE :query',
        query:
      )
    end
  end
end
