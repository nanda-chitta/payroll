class ApplicationController < ActionController::API
  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found

  private

  def render_result(result, success_status: :ok)
    if result.success?
      render json: yield(result.value!), status: success_status
    else
      render_domain_failure(result.failure)
    end
  end

  def render_not_found
    render json: { error: 'Record not found' }, status: :not_found
  end

  def render_domain_failure(failure)
    case failure[:type]
    when :validation_error
      render json: { errors: failure[:errors] }, status: :unprocessable_content
    when :not_found
      render json: { error: failure[:message] }, status: :not_found
    else
      Rails.logger.error("Domain failure: #{failure.inspect}")
      render json: { error: 'Something went wrong' }, status: :internal_server_error
    end
  end
end
