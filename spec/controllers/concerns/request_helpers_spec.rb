require 'rails_helper'

RSpec.describe RequestHelpers do
  subject(:controller) { klass.new }

  let(:klass) do
    Class.new do
      include RequestHelpers

      attr_accessor :request, :params, :performed_state
      attr_reader :errors

      def initialize
        @errors = []
        @performed_state = false
      end

      def render_error(**kwargs)
        @errors << kwargs
      end

      def performed?
        performed_state
      end

      def force_json_format_public
        force_json_format
      end

      def ensure_json_content_type_public
        ensure_json_content_type
      end

      def transform_params_to_snake_case_public
        transform_params_to_snake_case
      end

      def invalid_json_public
        invalid_json
      end

      def route_not_found_public
        route_not_found
      end

      def handle_record_not_found_public(exception)
        handle_record_not_found(exception)
      end

      def render_forbidden_public
        render_forbidden
      end

      def handle_unexpected_error_public(error)
        handle_unexpected_error(error)
      end

      def normalized_error_public(action, result)
        normalized_error(action, result)
      end

      def self.name
        'RequestHelpersSpecController'
      end
    end
  end

  def request_double(**overrides)
    double(
      :format => nil,
      :"format=" => nil,
      :get? => false,
      :head? => false,
      :options? => false,
      :content_length => 10,
      :content_mime_type => double(:json? => false, :to_s => 'text/plain'),
      **overrides
    )
  end

  it 'forces JSON format' do
    request = request_double
    controller.request = request

    controller.force_json_format_public

    expect(request).to have_received(:format=).with(:json)
  end

  it 'skips content-type validation for GET, HEAD, OPTIONS, empty, JSON, and multipart requests' do
    [
      request_double(get?: true),
      request_double(head?: true),
      request_double(options?: true),
      request_double(content_length: 0),
      request_double(content_mime_type: double(:json? => true, :to_s => 'application/json')),
      request_double(content_mime_type: double(:json? => false, :to_s => 'multipart/form-data')),
    ].each do |request|
      controller.request = request

      expect(controller.ensure_json_content_type_public).to be_nil
    end

    expect(controller.errors).to be_empty
  end

  it 'renders unsupported media type for invalid content types' do
    controller.request = request_double

    controller.ensure_json_content_type_public

    expect(controller.errors.last).to eq(
      status_code: 415,
      error_code: :unsupported_media_type,
      error_msg: 'Content-Type must be application/json'
    )
  end

  it 'treats a missing content mime type as unsupported' do
    controller.request = request_double(content_mime_type: nil)

    controller.ensure_json_content_type_public

    expect(controller.errors.last).to eq(
      status_code: 415,
      error_code: :unsupported_media_type,
      error_msg: 'Content-Type must be application/json'
    )
  end

  it 'transforms params to snake case when present' do
    params = ActionController::Parameters.new('jobTitleId' => 7, 'postalCode' => '560001')
    controller.params = params

    controller.transform_params_to_snake_case_public

    expect(controller.params.to_unsafe_h).to eq('job_title_id' => 7, 'postal_code' => '560001')
  end

  it 'leaves blank params unchanged' do
    controller.params = ActionController::Parameters.new

    expect(controller.transform_params_to_snake_case_public).to be_nil
  end

  it 'renders invalid json, route not found, and forbidden errors' do
    controller.invalid_json_public
    controller.route_not_found_public
    controller.render_forbidden_public

    expect(controller.errors).to include(
      { status_code: 400, error_code: :bad_request, error_msg: 'Invalid JSON payload' },
      { status_code: 404, error_code: :not_found, error_msg: 'Page not found' },
      { status_code: 409, error_code: :forbidden, error_msg: 'You are not authorized to perform this action' }
    )
  end

  it 'renders record not found and logs the exception message' do
    allow(Rails.logger).to receive(:info)

    controller.handle_record_not_found_public(StandardError.new('missing record'))

    expect(Rails.logger).to have_received(:info).with('missing record')
    expect(controller.errors.last).to eq(
      status_code: 404,
      error_code: :record_not_found,
      error_msg: 'missing record'
    )
  end

  it 'renders unexpected errors and logs the backtrace unless already performed' do
    allow(Rails.logger).to receive(:error)
    error = StandardError.new('boom')
    error.set_backtrace(['line 1', 'line 2'])

    controller.handle_unexpected_error_public(error)

    expect(Rails.logger).to have_received(:error).with('[500] StandardError: boom')
    expect(Rails.logger).to have_received(:error).with("line 1\nline 2")
    expect(controller.errors.last).to eq(
      status_code: 500,
      error_code: :internal_server_error,
      error_msg: 'Something went wrong. Please try again later.'
    )

    controller.performed_state = true
    expect(controller.handle_unexpected_error_public(StandardError.new('skip'))).to be_nil

    controller.performed_state = false
    allow(Rails.logger).to receive(:error)
    controller.handle_unexpected_error_public(StandardError.new('no backtrace'))
    expect(Rails.logger).to have_received(:error).with('[500] StandardError: no backtrace')
  end

  it 'normalizes error variants to HTTP responses' do
    allow(Rails.logger).to receive(:warn)

    schema_result_class = Class.new
    stub_const('Dry::Schema::Result', schema_result_class)
    schema_result = schema_result_class.new

    [
      ['create', double(failure: schema_result), 422, :unprocessable_entity, 'Invalid Params'],
      ['create', double(failure: :bad_request), 400, :bad_request, 'Invalid Params'],
      ['show', double(failure: :resource_not_found), 404, :not_found, 'Record not found'],
      ['show', double(failure: :forbidden), 403, :forbidden, 'Record not found'],
      ['create', double(failure: Commons::FailureConstant::RecordInvalid.new), 422, :unprocessable_entity, 'Invalid data'],
      ['create', double(failure: :anything_else), 500, :unknown_error, 'Internal server error'],
    ].each do |action, result, status_code, error_code, error_msg|
      controller.normalized_error_public(action, result)

      expect(controller.errors.last).to eq(
        status_code:,
        error_code:,
        error_msg:
      )
    end

    expect(Rails.logger).to have_received(:warn).at_least(:once)
  end
end
