module Api
  module V1
    class EmployeesController < ApplicationController
      def index
        result = Employees::Search.call(params:)

        render json: {
          employees: result[:employees].map { |employee| serialize_employee(employee) },
          meta: result[:meta]
        }
      end

      def show
        render json: { employee: serialize_employee(employee) }
      end

      def create
        employee = Employees::Upsert.call(params: employee_params)

        render json: { employee: serialize_employee(employee) }, status: :created
      rescue ActiveRecord::RecordInvalid => e
        render_validation_errors(e.record)
      end

      def update
        updated_employee = Employees::Upsert.call(employee:, params: employee_params)

        render json: { employee: serialize_employee(updated_employee) }
      rescue ActiveRecord::RecordInvalid => e
        render_validation_errors(e.record)
      end

      def destroy
        employee.destroy!

        head :no_content
      end

      private

      def employee
        @employee ||= Employee.includes(:department, :job_title, :employee_addresses, :employee_salaries).find(params[:id])
      end

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

      def serialize_employee(employee)
        current_address = employee.current_address
        current_salary = employee.current_salary

        {
          id: employee.id,
          employee_code: employee.employee_code,
          first_name: employee.first_name,
          middle_name: employee.middle_name,
          last_name: employee.last_name,
          full_name: employee.full_name,
          email: employee.email,
          date_of_birth: employee.date_of_birth,
          hire_date: employee.hire_date,
          termination_date: employee.termination_date,
          employment_type: employee.employment_type,
          status: employee.status,
          department: serialize_department(employee.department),
          job_title: serialize_job_title(employee.job_title),
          country: current_address&.country,
          address: serialize_address(current_address),
          salary: serialize_salary(current_salary),
          created_at: employee.created_at,
          updated_at: employee.updated_at
        }
      end

      def serialize_department(department)
        return nil if department.blank?

        { id: department.id, name: department.name, code: department.code }
      end

      def serialize_job_title(job_title)
        return nil if job_title.blank?

        { id: job_title.id, name: job_title.name, code: job_title.code }
      end

      def serialize_address(address)
        return nil if address.blank?

        {
          id: address.id,
          address_type: address.address_type,
          line1: address.line1,
          line2: address.line2,
          city: address.city,
          state: address.state,
          postal_code: address.postal_code,
          country: address.country,
          primary_address: address.primary_address
        }
      end

      def serialize_salary(salary)
        return nil if salary.blank?

        {
          id: salary.id,
          amount: salary.amount.to_s,
          currency: salary.currency,
          pay_frequency: salary.pay_frequency,
          effective_from: salary.effective_from,
          effective_to: salary.effective_to
        }
      end

      def render_validation_errors(record)
        render json: { errors: record.errors.to_hash(true) }, status: :unprocessable_content
      end
    end
  end
end
