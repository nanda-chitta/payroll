require 'rails_helper'

RSpec.describe 'seed data files' do
  it 'includes first and last name sources for employee generation' do
    first_names = Rails.root.join('db/seed_data/first_names.txt').readlines(chomp: true)
    last_names = Rails.root.join('db/seed_data/last_names.txt').readlines(chomp: true)

    expect(first_names.reject(&:blank?).size).to be >= 20
    expect(last_names.reject(&:blank?).size).to be >= 20
  end
end
