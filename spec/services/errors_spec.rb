require 'rails_helper'

RSpec.describe 'Errors' do
  it 'stores message and extras for base and derived errors' do
    base_error = Errors::BaseError.new(message: 'boom', extras: { field: 'email' })
    forbidden_error = Errors::ForbiddenError.new(:forbidden, extras: { role: 'guest' })

    expect(base_error).to be_a(RuntimeError)
    expect(base_error.message).to eq('boom')
    expect(base_error.extras).to eq(field: 'email')

    expect(forbidden_error).to be_a(RuntimeError)
    expect(forbidden_error.message).to eq(:forbidden)
    expect(forbidden_error.extras).to eq(role: 'guest')
  end

  it 'stores message keys for the simple error classes' do
    {
      Errors::BadRequestError => :bad_request,
      Errors::ConflictError => :conflict,
      Errors::InternalServerError => :internal_server_error,
      Errors::NotFoundError => :not_found,
      Errors::NotModifiedError => :not_modified,
      Errors::ParameterError => :parameter_error,
      Errors::UnprocessableEntityError => :unprocessable_entity,
    }.each do |klass, key|
      error = klass.new(key)

      expect(error).to be_a(RuntimeError)
      expect(error.message).to eq(key)
    end
  end
end
