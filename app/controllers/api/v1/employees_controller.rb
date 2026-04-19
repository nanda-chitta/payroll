class Api::V1::EmployeesController < Api::V1::BaseController
  before_action :load_employee_services

  def index
    result = @employee_service.employee_search(params:)

    if result.success?
      employees = result.value!
      paginated_employees = paginate_records(employees)

      render json: {
        employees: paginated_employees.map { |employee| ::Api::V1::EmployeeSerializer.new(employee).serializable_hash },
        meta: {
          page: page_num,
          per_page: per_page_num,
          total: employees.count
        }
      }
    else
      normalized_error(params[:action], result)
    end
  end

  def show
    render_result(@employee_service.employee_show(id: params[:id])) do |employee|
      { employee: serialize_employee(employee) }
    end
  end

  def create
    render_result(@employee_service.employee_upsert(params: employee_params), success_status: :created) do |employee|
      { employee: serialize_employee(employee) }
    end
  end

  def update
    employee_result = @employee_service.employee_show(id: params[:id])
    return render_domain_failure(employee_result.failure) if employee_result.failure?

    render_result(@employee_service.employee_upsert(employee: employee_result.value!, params: employee_params)) do |updated_employee|
      { employee: serialize_employee(updated_employee) }
    end
  end

  def destroy
    result = @employee_service.employee_destroy(id: params[:id])

    result.success? ? head(:no_content) : render_domain_failure(result.failure)
  end

  private

  def employee_params
    params.require(:employee).permit(
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
      :job_title_id,
      :line1,
      :line2,
      :city,
      :state,
      :postal_code,
      :country,
      :salary_amount,
      :currency,
      :pay_frequency
    )
  end

  def paginate_records(records)
    offset = (page_num - 1) * per_page_num

    if records.respond_to?(:offset)
      records.offset(offset).limit(per_page_num)
    else
      records.slice(offset, per_page_num) || []
    end
  end

  def serialize_employee(employee)
    ::Api::V1::EmployeeSerializer.new(employee).serializable_hash
  end

  def load_employee_services
    @employee_service = AppContainer['employee_management.app_services.employee_service']
  end
end
