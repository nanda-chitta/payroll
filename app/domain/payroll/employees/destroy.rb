require 'dry/monads'

module Payroll
  module Employees
    class Destroy
      include Dry::Monads[:result]

      def call(employee:)
        employee.destroy!

        Success()
      rescue ActiveRecord::RecordNotDestroyed => e
        Failure(type: :validation_error, errors: e.record.errors.to_hash(true))
      rescue StandardError => e
        Failure(type: :internal_error, message: e.message)
      end
    end
  end
end
