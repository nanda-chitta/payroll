module Employees
  class Upsert
    def self.call(params:, employee: nil)
      new(params:, employee:).call
    end

    def initialize(params:, employee: nil)
      @params = params
      @employee = employee || Employee.new
    end

    def call
      Employee.transaction do
        employee.update!(employee_attributes)
        upsert_primary_address!
        upsert_current_salary!
        employee.reload
      end
    end

    private

    attr_reader :params, :employee

    def employee_attributes
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

    def upsert_primary_address!
      address = employee.employee_addresses.primary.first || employee.employee_addresses.build(primary_address: true)
      address.update!(address_attributes)
    end

    def address_attributes
      {
        address_type: 'home',
        line1: params[:line1].presence || 'Not provided',
        line2: params[:line2],
        city: params[:city].presence || 'Not provided',
        state: params[:state],
        postal_code: params[:postal_code].presence || '000000',
        country: params[:country],
        primary_address: true
      }
    end

    def upsert_current_salary!
      salary = employee.current_salary || employee.employee_salaries.build(effective_from: Date.current)
      salary.update!(salary_attributes)
    end

    def salary_attributes
      {
        amount: params[:salary_amount],
        currency: params[:currency].presence || 'USD',
        pay_frequency: params[:pay_frequency].presence || 'monthly',
        effective_from: employee.hire_date || Date.current
      }
    end
  end
end
