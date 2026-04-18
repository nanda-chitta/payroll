class Api::V1::BaseController < ApplicationController
  include Dry::Monads::Result::Mixin
  include HandleResponse
  include RequestHelpers

  before_action :force_json_format
  before_action :ensure_json_content_type
  before_action :transform_params_to_snake_case

  rescue_from ActionDispatch::Http::Parameters::ParseError, with: :invalid_json
  rescue_from ActiveRecord::RecordNotFound, with: :handle_record_not_found
  rescue_from ActionController::RoutingError, with: :route_not_found
  rescue_from StandardError, with: :handle_unexpected_error

  protected

  def per_page_num
    params[:per_page].to_i.positive? ? params[:per_page].to_i : PER_PAGE
  end

  def page_num
    params[:page].to_i.positive? ? params[:page].to_i : PAGE
  end
end
