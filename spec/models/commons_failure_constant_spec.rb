require 'rails_helper'

RSpec.describe Commons::FailureConstant do
  it 'stores base key, message, and extras' do
    error = described_class.new(key: :base_error, message: 'boom', extras: { source: 'test' })

    expect(error.key).to eq(:base_error)
    expect(error.message).to eq('boom')
    expect(error.extras).to eq(source: 'test')
  end

  it 'initializes the predefined failure constants with the expected keys' do
    expect(Commons::FailureConstant::UpdateForbiddenError.new.key).to eq(:update_forbidden_error)
    expect(Commons::FailureConstant::SaveError.new.key).to eq(:save_error)
    expect(Commons::FailureConstant::UpdateError.new(extras: { id: 1 }).extras).to eq(id: 1)
    expect(Commons::FailureConstant::RecordNotFound.new.key).to eq(:record_not_found)
    expect(Commons::FailureConstant::RecordInvalid.new.key).to eq(:record_invalid)
    expect(Commons::FailureConstant::InvalidParameter.new.key).to eq(:invalid_parameter)
    expect(Commons::FailureConstant::InvalidArgument.new.key).to eq(:invalid_argument)
    expect(Commons::FailureConstant::InvalidResource.new.key).to eq(:invalid_resource)
    expect(Commons::FailureConstant::InvalidPayload.new.key).to eq(:invalid_payload)
    expect(Commons::FailureConstant::TransitionForbiddenError.new.key).to eq(:transition_forbidden_error)
    expect(Commons::FailureConstant::StatusTransitionError.new.key).to eq(:status_transition_error)
    expect(Commons::FailureConstant::InvalidRole.new(extras: { role: 'guest' }).extras).to eq(role: 'guest')
  end
end
