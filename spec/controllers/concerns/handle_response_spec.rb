require 'rails_helper'

RSpec.describe HandleResponse do
  subject(:controller) { klass.new }

  let(:klass) do
    Class.new do
      include HandleResponse

      attr_reader :render_args

      def render(**kwargs)
        @render_args = kwargs
      end
    end
  end

  it 'renders success responses with optional message and data' do
    controller.render_success(status_code: 201, data: { id: 1 }, message: 'created')

    expect(controller.render_args).to eq(
      json: { status: 201, message: 'created', data: { id: 1 } },
      status: 201
    )
  end

  it 'renders success responses without optional keys' do
    controller.render_success

    expect(controller.render_args).to eq(json: { status: 200 }, status: 200)
  end

  it 'renders error responses' do
    controller.render_error(status_code: 422, error_code: :invalid, error_msg: 'bad data')

    expect(controller.render_args).to eq(
      json: { status: 422, error: { code: :invalid, message: 'bad data' } },
      status: 422
    )
  end
end
