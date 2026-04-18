class EmployeeManagement::AppServices::EmployeeService
  include Dry::Monads::Result::Mixin
  include Dry::Monads::Do::All

  def initialize
    @employee_repo  = AppContainer['employee_management.infrastructures.repos.employee_repository']
    # @employee_param = AppContainer['employee_management.app_services.validators.employee_param']
    # @audit_logger = AppContainer['audit_management.app_services.logger_service']
    # @notification_publisher = AppContainer['notification_management.app_services.publisher_service']
  end

  def employee_search(params:)
    sort, direction = extract_sort_params(params)
    query = params[:q].presence || params[:query]

    employees = if query.present?
      yield @employee_repo.search_data(query: query, sort: sort, direction: direction)
    else
      yield @employee_repo.fetch_data(sort: sort, direction: direction)
    end

    Success(employees)
  end

  private

  def extract_sort_params(params)
    sort = params.dig(:sort) || 'created_at'
    direction = params.dig(:direction) || 'desc'
    [ sort, direction ]
  end
end
