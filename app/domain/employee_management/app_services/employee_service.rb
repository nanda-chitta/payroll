module EmployeeManagement
  module AppServices
    class EmployeeService
  include Dry::Monads::Result::Mixin
  include Dry::Monads::Do::All

  def initialize
    @employee_repo  = AppContainer['employee_management.infrastructures.repos.employee_repository']
    @employee_param = AppContainer['employee_management.app_services.validators.employee_param']
    # @audit_logger = AppContainer['audit_management.app_services.logger_service']
    # @notification_publisher = AppContainer['notification_management.app_services.publisher_service']
  end

  def employee_search(params:)
    sort, direction = extract_sort_params(params)
    filters = search_filters(params)

    employees = if filters.present?
      yield @employee_repo.search_data(query: filters, sort: sort, direction: direction)
    else
      yield @employee_repo.fetch_data(sort: sort, direction: direction)
    end

    Success(employees)
  end

  def employee_show(id:)
    employee = yield @employee_repo.find_data(id:)

    Success(employee)
  end

  def employee_upsert(employee: Employee.new, params:)
    valid_params = yield validate_employee_params(params, partial: employee.persisted?)
    saved_employee = yield @employee_repo.upsert_data(employee:, params: valid_params)

    Success(saved_employee)
  end

  def employee_destroy(id:)
    employee = yield @employee_repo.find_data(id:)
    yield @employee_repo.destroy_data(employee:)

    Success(true)
  end

  private

  def extract_sort_params(params)
    sort = params.dig(:sort) || 'created_at'
    direction = params.dig(:direction) || 'desc'
    [ sort, direction ]
  end

  def search_filters(params)
    {
      query: params[:q].presence || params[:query],
      status: params[:status],
      country: params[:country],
      job_title_id: params[:job_title_id]
    }.compact_blank
  end

  def validate_employee_params(params, partial:)
    result = @employee_param.call(params, partial:)
    return result if result.success?

    Failure(type: :validation_error, errors: result.failure)
  end
    end
  end
end
