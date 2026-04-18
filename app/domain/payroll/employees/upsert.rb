require 'dry/monads'

module Payroll
  module Employees
    class Upsert
      include Dry::Monads[:result]

      def call(params:, employee: nil)
        employee ||= Employee.new

        Employee.transaction do
          employee.update!(employee_attributes(params))
          upsert_primary_address!(employee, params)
          upsert_current_salary!(employee, params)

          Success(employee.reload)
        end
      rescue ActiveRecord::RecordInvalid => e
        Failure(type: :validation_error, errors: e.record.errors.to_hash(true))
      rescue ActiveRecord::RecordNotFound
        Failure(type: :not_found, message: 'Employee not found')
      rescue StandardError => e
        Failure(type: :internal_error, message: e.message)
      end

      private

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
        }
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
        }
      end
    end
  end
end
