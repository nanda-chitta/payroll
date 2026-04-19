module EmployeeManagement
  module Infrastructures
    module Repos
      class EmployeeRepository
  include ::Dry::Monads::Result::Mixin

  CACHE_TTL = 5.minutes
  SORT_COLUMNS = %w[created_at employee_code first_name last_name email hire_date status].freeze
  READ_ERRORS = [ ActiveRecord::ActiveRecordError ].freeze
  WRITE_ERRORS = [ ActiveRecord::ActiveRecordError ].freeze

  def initialize
    @model = Employee
  end

  def get_transaction(&block)
    @model.transaction(&block)
  end

  def fetch_data(sort:, direction:)
    catch_database_errors(:fetch_data, exceptions: READ_ERRORS) do
      cached_scope(base_scope, sort, direction, {})
    end
  end

  def search_data(query:, sort:, direction:)
    catch_database_errors(:search_data, exceptions: READ_ERRORS) do
      scope = base_scope
      filters = query.respond_to?(:to_unsafe_h) ? query.to_unsafe_h.symbolize_keys : query

      if filters.is_a?(Hash)
        cached_scope(apply_filters(scope, filters), sort, direction, filters)
      elsif query.blank?
        scope
      else
        cached_scope(apply_text_search(scope, query), sort, direction, { query: query.to_s })
      end
    end
  end

  def find_data(id:)
    catch_database_errors(:find_data, exceptions: READ_ERRORS, not_found: true) do
      detail_scope.find(id)
    end
  end

  def upsert_data(employee:, params:)
    catch_database_errors(:upsert_data, exceptions: WRITE_ERRORS, passthrough: true) do
      get_transaction do
        employee.update!(employee_attributes(params))
        upsert_primary_address!(employee, params)
        upsert_current_salary!(employee, params)
        expire_employee_cache

        employee.reload
      end
    end
  end

  def destroy_data(employee:)
    catch_database_errors(:destroy_data, exceptions: WRITE_ERRORS, passthrough: true) do
      employee.destroy!
      expire_employee_cache
      true
    end
  end

  private

  def base_scope
    @model.includes(:department, :job_title, :employee_addresses, :employee_salaries)
                      .references(:employee_addresses, :job_titles)
                      .left_joins(:employee_addresses, :job_title)
                      .where(employee_addresses: { primary_address: true })
  end

  def detail_scope
    @model.includes(:department, :job_title, :employee_addresses, :employee_salaries)
  end

  def ordered_scope(scope, sort, direction)
    sort = SORT_COLUMNS.include?(sort.to_s) ? sort.to_s : 'created_at'
    direction = direction.to_s.downcase == 'asc' ? 'asc' : 'desc'

    scope.order(sort => direction)
  end

  def cached_scope(scope, sort, direction, filters)
    ordered = ordered_scope(scope, sort, direction).distinct
    ids = Rails.cache.fetch(cache_key(sort, direction, filters), expires_in: CACHE_TTL) { ordered.to_a.map(&:id) }

    return @model.none if ids.blank?

    base_scope.where(id: ids)
              .order(Arel.sql("array_position(ARRAY[#{ids.map(&:to_i).join(',')}]::bigint[], employees.id)"))
  end

  def cache_key(sort, direction, filters)
    normalized_filters = filters.compact.sort.to_h
    digest = Digest::SHA256.hexdigest(normalized_filters.to_json)

    [ 'employees', sort, direction, digest ].join(':')
  end

  def apply_filters(scope, filters)
    scope = scope.where(status: filters[:status]) if filters[:status].present?
    scope = scope.where(employee_addresses: { country: filters[:country] }) if filters[:country].present?
    scope = scope.where(job_title_id: filters[:job_title_id]) if filters[:job_title_id].present?
    scope = apply_text_search(scope, filters[:query]) if filters[:query].present?

    scope
  end

  def apply_text_search(scope, query)
    query = query.to_s.strip
    elastic_ids = elasticsearch_ids(query)

    return scope.where(id: elastic_ids) if elastic_ids.present?

    like_query = "%#{ActiveRecord::Base.sanitize_sql_like(query)}%"

    scope.where(
      'employees.employee_code ILIKE :query OR employees.first_name ILIKE :query OR employees.last_name ILIKE :query OR employees.email ILIKE :query',
      query: like_query
    )
  end

  def elasticsearch_ids(query)
    Employee.__elasticsearch__.search(
      query: {
        multi_match: {
          query: query,
          fields: %w[employee_code^3 first_name last_name email],
          fuzziness: 'AUTO'
        }
      },
      size: 10_000
    ).records.pluck(:id)
  rescue StandardError => e
    Rails.logger.info "[employee_repository] elasticsearch fallback #{e.class}: #{e.message}"
    []
  end

  def employee_attributes(params)
    params.slice(
      :employee_code,
      :first_name,
      :middle_name,
      :last_name,
      :email,
      :date_of_birth,
      :hire_date,
      :termination_date,
      :employment_type,
      :status,
      :department_id,
      :job_title_id
    )
  end

  def upsert_primary_address!(employee, params)
    address = employee.employee_addresses.primary.first || employee.employee_addresses.build(primary_address: true)
    address.update!(address_attributes(params))
  end

  def address_attributes(params)
    {
      address_type: 'home',
      line1: params[:line1].presence || 'Not provided',
      line2: params[:line2],
      city: params[:city].presence || 'Not provided',
      state: params[:state],
      postal_code: params[:postal_code].presence || '000000',
      country: params[:country],
      primary_address: true
    }.compact
  end

  def upsert_current_salary!(employee, params)
    salary = employee.current_salary || employee.employee_salaries.build(effective_from: Date.current)
    salary.update!(salary_attributes(employee, params))
  end

  def salary_attributes(employee, params)
    {
      amount: params[:salary_amount],
      currency: params[:currency].presence || 'USD',
      pay_frequency: params[:pay_frequency].presence || 'monthly',
      effective_from: employee.hire_date || Date.current
    }.compact
  end

  def expire_employee_cache
    Rails.cache.delete_matched('employees:*')
    Rails.cache.delete_matched('salary_insights:*')
    Rails.cache.delete('lookups:index')
  rescue NotImplementedError
    Rails.cache.clear
  end

  def catch_database_errors(action, exceptions:, not_found: false, passthrough: false)
    Success(yield)
  rescue *exceptions => failure
    repository_failure(action, failure, not_found:, passthrough:)
  end

  def repository_failure(action, failure, not_found: false, passthrough: false)
    Rails.logger.error "[employee_repository] ##{action} #{failure.message}"

    return Failure(type: :not_found, message: 'Employee not found') if not_found && failure.is_a?(ActiveRecord::RecordNotFound)
    return Failure(record_failure(failure)) if passthrough

    Failure(::Dry::Monads::UnwrapError.new(failure.message))
  end

  def record_failure(failure)
    return { type: :validation_error, errors: failure.record.errors.to_hash(true) } if failure.respond_to?(:record)

    { type: :internal_error, message: failure.message }
  end
      end
    end
  end
end
