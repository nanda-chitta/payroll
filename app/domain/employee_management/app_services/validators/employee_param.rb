module EmployeeManagement
  module AppServices
    module Validators
      class EmployeeParam
  include Dry::Monads::Result::Mixin

  def call(params, partial: false)
    result = (partial ? update_schema : create_schema).call(normalized_params(params))

    result.success? ? Success(result.to_h) : Failure(result.errors.to_h)
  end

  private

  def normalized_params(params)
    hash = params.respond_to?(:to_unsafe_h) ? params.to_unsafe_h : params.to_h
    hash.deep_symbolize_keys
  end

  def create_schema
    ::Dry::Schema.Params do
      required(:employee_code).filled(:string, max_size?: 30)
      required(:first_name).filled(:string, max_size?: 100)
      optional(:middle_name).maybe(:string, max_size?: 100)
      required(:last_name).filled(:string, max_size?: 100)
      required(:email).filled(:string, max_size?: 255)
      optional(:date_of_birth).maybe(:date)
      required(:hire_date).filled(:date)
      optional(:termination_date).maybe(:date)
      required(:employment_type).filled(:string, included_in?: EMPLOYMENT_TYPES)
      required(:status).filled(:string, included_in?: STATUSES)
      required(:department_id).filled(:integer)
      required(:job_title_id).filled(:integer)
      optional(:line1).maybe(:string, max_size?: 255)
      optional(:line2).maybe(:string, max_size?: 255)
      optional(:city).maybe(:string, max_size?: 100)
      optional(:state).maybe(:string, max_size?: 100)
      optional(:postal_code).maybe(:string, max_size?: 30)
      required(:country).filled(:string, max_size?: 100)
      required(:salary_amount).filled(:decimal, gteq?: 0)
      optional(:currency).maybe(:string, size?: 3)
      optional(:pay_frequency).maybe(:string, included_in?: PAY_FREQUENCIES)
    end
  end

  def update_schema
    ::Dry::Schema.Params do
      optional(:employee_code).filled(:string, max_size?: 30)
      optional(:first_name).filled(:string, max_size?: 100)
      optional(:middle_name).maybe(:string, max_size?: 100)
      optional(:last_name).filled(:string, max_size?: 100)
      optional(:email).filled(:string, max_size?: 255)
      optional(:date_of_birth).maybe(:date)
      optional(:hire_date).filled(:date)
      optional(:termination_date).maybe(:date)
      optional(:employment_type).filled(:string, included_in?: EMPLOYMENT_TYPES)
      optional(:status).filled(:string, included_in?: STATUSES)
      optional(:department_id).filled(:integer)
      optional(:job_title_id).filled(:integer)
      optional(:line1).maybe(:string, max_size?: 255)
      optional(:line2).maybe(:string, max_size?: 255)
      optional(:city).maybe(:string, max_size?: 100)
      optional(:state).maybe(:string, max_size?: 100)
      optional(:postal_code).maybe(:string, max_size?: 30)
      optional(:country).filled(:string, max_size?: 100)
      optional(:salary_amount).filled(:decimal, gteq?: 0)
      optional(:currency).maybe(:string, size?: 3)
      optional(:pay_frequency).maybe(:string, included_in?: PAY_FREQUENCIES)
    end
  end
      end
    end
  end
end
