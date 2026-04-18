class EmployeeManagement::Infrastructures::Repos::EmployeeRepository
  include ::Dry::Monads::Result::Mixin
  include ::Dry::Monads::Maybe::Mixin
  include ::Dry::Monads::Try::Mixin

  def initialize
    @model = Employee
  end

  def get_transaction(&block)
    @model.transaction(&block)
  end

  def fetch_data(sort:, direction:)
    Try(ActiveRecord::RecordInvalid, ActiveRecord::ActiveRecordError) do
      employees = base_scope.order(sort => direction)
      employees.distinct
    end.to_result.or do |failure|
      Rails.logger.error "[employee_repository] #fetch_data #{failure.message}"
      Failure(::Dry::Monads::UnwrapError.new(failure.message))
    end
  end

  def search_data(query:, sort:, direction:)
    Try(ActiveRecord::RecordInvalid, ActiveRecord::ActiveRecordError) do
      scope = base_scope
      filters = query.respond_to?(:to_unsafe_h) ? query.to_unsafe_h.symbolize_keys : query

      if filters.is_a?(Hash)
        scope = scope.where(status: filters[:status]) if filters[:status].present?
        scope = scope.where(employee_addresses: { country: filters[:country] }) if filters[:country].present?
        scope = scope.where(job_title_id: filters[:job_title_id]) if filters[:job_title_id].present?

        return scope.order(sort => direction).distinct
      end

      return scope if query.blank?

      query = "%#{ActiveRecord::Base.sanitize_sql_like(query.to_s.strip)}%"

      scope = scope.where(
        'employees.employee_code ILIKE :query OR employees.first_name ILIKE :query OR employees.last_name ILIKE :query OR employees.email ILIKE :query',
        query:
      )

      scope.order(sort => direction).distinct
    end.to_result.or do |failure|
      Rails.logger.error "[employee_repository] #search_data #{failure.message}"
      Failure(::Dry::Monads::UnwrapError.new(failure.message))
    end
  end

  private

  def base_scope
    @model.includes(:department, :job_title, :employee_addresses, :employee_salaries)
                      .references(:employee_addresses, :job_titles)
                      .left_joins(:employee_addresses, :job_title)
                      .where(employee_addresses: { primary_address: true })
  end
end
