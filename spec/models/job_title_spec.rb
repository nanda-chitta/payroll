require 'rails_helper'

RSpec.describe JobTitle, type: :model do
  describe 'validations' do
    it 'requires a name and code' do
      job_title = described_class.new

      expect(job_title).not_to be_valid
      expect(job_title.errors[:name]).to be_present
      expect(job_title.errors[:code]).to be_present
    end
  end

  describe 'normalization' do
    it 'strips text fields and uppercases code' do
      job_title = build(:job_title, name: '  Engineer  ', code: ' eng ', description: '  Builds systems  ')

      job_title.validate

      expect(job_title.name).to eq('Engineer')
      expect(job_title.code).to eq('ENG')
      expect(job_title.description).to eq('Builds systems')
    end
  end
end
