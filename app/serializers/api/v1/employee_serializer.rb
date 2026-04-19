class Api::V1::EmployeeSerializer < Api::V1::BaseSerializer
  attributes :id, :employee_code, :first_name, :middle_name, :last_name, :full_name, :email,
             :date_of_birth, :hire_date, :termination_date, :employment_type, :status,
             :department, :job_title, :country, :address, :salary, :created_at, :updated_at

  def full_name
    object.full_name
  end

  def country
    object.current_address&.country
  end

  def department
    return nil if object.department.blank?

    {
      id: object.department.id,
      name: object.department.name,
      code: object.department.code
    }
  end

  def job_title
    return nil if object.job_title.blank?

    {
      id: object.job_title.id,
      name: object.job_title.name,
      code: object.job_title.code
    }
  end

  def address
    address = object.current_address
    return nil if address.blank?

    ::Api::V1::EmployeeAddressSerializer.new(address).serializable_hash
  end

  def salary
    salary = object.current_salary
    return nil if salary.blank?

    ::Api::V1::EmployeeSalarySerializer.new(salary).serializable_hash
  end
end
