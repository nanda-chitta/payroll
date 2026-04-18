class EmployeeManagement::AppServices::Validators::EmployeeParam
  include Dry::Monads::Result::Mixin
  include Dry::Monads::Do.for(:call)

  def call(params)
    valid_params = yield validate_params(params)

    Success(valid_params[:employee])
  end

  private

  def validate_params(params)
    result = schema.call(params)
    result.success? ? Success(result.to_h) : Failure(result)
  end

  def schema
    ::Dry::Schema.Params do
      required(:employee).hash do
        required(:status).filled(:string, included_in?: STATUSES)
        optional(:note).maybe(:string)
      end
    end
  end
end
