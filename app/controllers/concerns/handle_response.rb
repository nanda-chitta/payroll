module HandleResponse
  # {
  #   "status": xxx,
  #   "message": "optional message",
  #   "data": { ... }
  # }
  def render_success(status_code: 200, data: nil, message: nil)
    render_response(
      status_code: status_code,
      data: data,
      message: message
    )
  end

  # {
  #   "status": xxx,
  #   "error": { "code": "invalid_xxx", "message": "something went wrong" }
  # }
  def render_error(status_code:, error_code:, error_msg:)
    render_response(
      status_code: status_code,
      error_hash: { code: error_code, message: error_msg }
    )
  end

  private

  def render_response(status_code:, data: nil, message: nil, error_hash: nil)
    resp_json = { status: status_code }.yield_self do |j|
      j.merge!(message: message) if message.present?
      j.merge!(data: data) if data.present?
      j.merge!(error: error_hash) if error_hash.present?
      j
    end

    render json: resp_json, status: status_code
  end
end
