module RequestHelpers
  private

  def force_json_format
    request.format = :json
  end

  def ensure_json_content_type
    return if request.get? || request.head? || request.options?
    return if request.content_length.to_i.zero?
    return if request.content_mime_type&.json?
    return if request.content_mime_type&.to_s == 'multipart/form-data'

    render_error(
      status_code: 415,
      error_code: :unsupported_media_type,
      error_msg: 'Content-Type must be application/json'
    ) and nil
  end

  def transform_params_to_snake_case
    return if params.blank?

    params.deep_transform_keys!(&:underscore)
  end

  def invalid_json
    render_error(
      status_code: 400,
      error_code: :bad_request,
      error_msg: 'Invalid JSON payload'
    )
  end

  def route_not_found
    render_error(
      status_code: 404,
      error_code: :not_found,
      error_msg: 'Page not found'
    )
  end

  def handle_record_not_found(exception)
    Rails.logger.info(exception.message)

    render_error(
      status_code: 404,
      error_code: :record_not_found,
      error_msg: exception.message
    )
  end

  def render_forbidden
    render_error(
      status_code: 409,
      error_code: :forbidden,
      error_msg: 'You are not authorized to perform this action'
    )
  end

  def handle_unexpected_error(error)
    return if performed?

    Rails.logger.error("[500] #{error.class}: #{error.message}")
    Rails.logger.error(error.backtrace.join("\n")) if error.backtrace

    render_error(
      status_code: 500,
      error_code: :internal_server_error,
      error_msg: 'Something went wrong. Please try again later.'
    )
  end


  def normalized_error(action, result)
    controller_label = self.class.name.underscore
    Rails.logger.warn("[API][V1][#{controller_label}] ##{action} #{result.failure}")

    case result.failure
    when Dry::Schema::Result
      render_error(status_code: 422, error_code: :unprocessable_entity, error_msg: 'Invalid Params')
    when :bad_request
      render_error(status_code: 400, error_code: :bad_request, error_msg: 'Invalid Params')
    when :resource_not_found, :not_found, ::Commons::FailureConstant::RecordNotFound
      render_error(status_code: 404, error_code: :not_found, error_msg: 'Record not found')
    when :forbidden
      render_error(status_code: 403, error_code: :forbidden, error_msg: 'Record not found')
    when ::Commons::FailureConstant::RecordInvalid
      render_error(status_code: 422, error_code: :unprocessable_entity, error_msg: 'Invalid data')
    else
      render_error(status_code: 500, error_code: :unknown_error, error_msg: 'Internal server error')
    end
  end
end
