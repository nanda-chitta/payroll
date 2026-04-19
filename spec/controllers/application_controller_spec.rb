require 'rails_helper'

RSpec.describe ApplicationController do
  subject(:controller) { controller_class.new }

  let(:controller_class) do
    Class.new(described_class) do
      attr_reader :render_args

      def render(**kwargs)
        @render_args = kwargs
      end

      def render_result_public(result, success_status: :ok, &block)
        render_result(result, success_status:, &block)
      end

      def render_domain_failure_public(failure)
        render_domain_failure(failure)
      end

      def render_not_found_public
        render_not_found
      end
    end
  end

  it 'renders successful results' do
    result = Dry::Monads::Success({ id: 1 })

    controller.render_result_public(result) { |value| { employee: value } }

    expect(controller.render_args).to eq(json: { employee: { id: 1 } }, status: :ok)
  end

  it 'renders failed results through the domain failure handler' do
    result = Dry::Monads::Failure(type: :not_found, message: 'missing')

    controller.render_result_public(result) { raise 'should not run' }

    expect(controller.render_args).to eq(json: { error: 'missing' }, status: :not_found)
  end

  it 'renders validation failures' do
    controller.render_domain_failure_public(type: :validation_error, errors: { email: ['taken'] })

    expect(controller.render_args).to eq(json: { errors: { email: ['taken'] } }, status: :unprocessable_content)
  end

  it 'renders unexpected failures as internal server errors' do
    allow(Rails.logger).to receive(:error)

    controller.render_domain_failure_public(type: :internal_error, message: 'boom')

    expect(Rails.logger).to have_received(:error).with(/Domain failure:/)
    expect(controller.render_args).to eq(json: { error: 'Something went wrong' }, status: :internal_server_error)
  end

  it 'renders record not found' do
    controller.render_not_found_public

    expect(controller.render_args).to eq(json: { error: 'Record not found' }, status: :not_found)
  end
end
