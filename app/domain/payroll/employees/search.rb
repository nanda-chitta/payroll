require 'dry/monads'

module Payroll
  module Employees
    class Search
      include Dry::Monads[:result]

      DEFAULT_LIMIT = 25
      MAX_LIMIT = 100

      def call(params:)
        page = page_param(params)
        limit = limit_param(params)
        employees = apply_filters(base_scope, params)
        total = employees.count

        Success(
          employees: employees.offset((page - 1) * limit).limit(limit),
          meta: {
            page:,
            limit:,
            total:,
            total_pages: (total.to_f / limit).ceil
          }
        )
      rescue StandardError => e
        Failure(type: :internal_error, message: e.message)
      end

      private

      def base_scope
        Employee
          .includes(:department, :job_title, :employee_addresses, :employee_salaries)
          .references(:employee_addresses, :job_titles)
          .left_joins(:employee_addresses, :job_title)
          .where(employee_addresses: { primary_address: true })
          .order(created_at: :desc)
      end

      def apply_filters(scope, params)
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

      def page_param(params)
        params.fetch(:page, 1).to_i.clamp(1, Float::INFINITY)
      end

      def limit_param(params)
        params.fetch(:limit, DEFAULT_LIMIT).to_i.clamp(1, MAX_LIMIT)
      end
    end
  end
end
