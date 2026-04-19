require 'rails_helper'

RSpec.describe 'Application base components' do
  it 'configures the application mailer defaults' do
    expect(ApplicationMailer.default[:from]).to eq('from@example.com')
    expect(ApplicationMailer._layout).to eq('mailer')
  end

  it 'inherits the framework base job class' do
    expect(ApplicationJob.superclass).to eq(ActiveJob::Base)
  end

  it 'formats timestamps in the base serializer' do
    record = Struct.new(:id, :created_at, :updated_at).new(
      10,
      Time.utc(2026, 4, 19, 10, 15, 30),
      Time.utc(2026, 4, 19, 11, 45, 50)
    )

    serializer = Api::V1::BaseSerializer.new(record)

    expect(serializer.send(:created_at)).to eq('2026-04-19 10:15:30')
    expect(serializer.send(:updated_at)).to eq('2026-04-19 11:45:50')
  end
end
