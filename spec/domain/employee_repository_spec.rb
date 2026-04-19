require 'rails_helper'

RSpec.describe EmployeeManagement::Infrastructures::Repos::EmployeeRepository do
  subject(:repository) { described_class.new }

  describe '#search_data' do
    it 'returns the base scope when the query is blank and not a hash' do
      scope = double('scope')
      allow(repository).to receive(:base_scope).and_return(scope)

      result = repository.search_data(query: '', sort: 'created_at', direction: 'desc')

      expect(result).to be_success
      expect(result.value!).to eq(scope)
    end

    it 'routes non-blank string queries through text search caching' do
      scope = double('scope')
      searched_scope = double('searched_scope')
      cached_scope = double('cached_scope')
      allow(repository).to receive(:base_scope).and_return(scope)
      allow(repository).to receive(:apply_text_search).with(scope, 'maya').and_return(searched_scope)
      allow(repository).to receive(:cached_scope).and_return(cached_scope)

      result = repository.search_data(query: 'maya', sort: 'created_at', direction: 'desc')

      expect(result).to be_success
      expect(result.value!).to eq(cached_scope)
      expect(repository).to have_received(:cached_scope).with(searched_scope, 'created_at', 'desc', query: 'maya')
    end

    it 'normalizes ActionController parameters into filter hashes' do
      scope = double('scope')
      filtered_scope = double('filtered_scope')
      cached_scope = double('cached_scope')
      params = ActionController::Parameters.new(status: 'active')
      allow(repository).to receive(:base_scope).and_return(scope)
      allow(repository).to receive(:apply_filters).and_return(filtered_scope)
      allow(repository).to receive(:cached_scope).and_return(cached_scope)

      result = repository.search_data(query: params, sort: 'created_at', direction: 'desc')

      expect(result).to be_success
      expect(result.value!).to eq(cached_scope)
      expect(repository).to have_received(:apply_filters).with(scope, status: 'active')
    end
  end

  describe '#expire_employee_cache' do
    it 'falls back to clearing the cache when delete_matched is unsupported' do
      cache = instance_double(ActiveSupport::Cache::Store)
      allow(Rails).to receive(:cache).and_return(cache)
      allow(cache).to receive(:delete_matched).with('employees:*').and_raise(NotImplementedError)
      allow(cache).to receive(:clear)

      repository.send(:expire_employee_cache)

      expect(cache).to have_received(:clear)
    end
  end

  describe '#ordered_scope' do
    it 'falls back to created_at desc for invalid sort inputs and allows asc' do
      scope = class_double(Employee).as_stubbed_const
      allow(scope).to receive(:order)

      repository.send(:ordered_scope, scope, 'invalid', 'sideways')
      repository.send(:ordered_scope, scope, 'employee_code', 'asc')

      expect(scope).to have_received(:order).with('created_at' => 'desc')
      expect(scope).to have_received(:order).with('employee_code' => 'asc')
    end
  end

  describe '#cached_scope' do
    it 'returns none when the cached ids are blank' do
      scope = double('scope')
      ordered = double('ordered', distinct: double('distinct'))
      allow(repository).to receive(:ordered_scope).and_return(ordered)
      allow(Rails.cache).to receive(:fetch).and_return([])
      allow(Employee).to receive(:none).and_return(:none_scope)

      expect(repository.send(:cached_scope, scope, 'created_at', 'desc', {})).to eq(:none_scope)
    end
  end

  describe '#apply_filters' do
    it 'applies each supported filter when present' do
      scope = double('scope')
      status_scope = double('status_scope')
      country_scope = double('country_scope')
      role_scope = double('role_scope')
      search_scope = double('search_scope')
      allow(scope).to receive(:where).with(status: 'active').and_return(status_scope)
      allow(status_scope).to receive(:where).with(employee_addresses: { country: 'India' }).and_return(country_scope)
      allow(country_scope).to receive(:where).with(job_title_id: 5).and_return(role_scope)
      allow(repository).to receive(:apply_text_search).with(role_scope, 'maya').and_return(search_scope)

      result = repository.send(:apply_filters, scope, { status: 'active', country: 'India', job_title_id: 5, query: 'maya' })

      expect(result).to eq(search_scope)
    end

    it 'returns the scope unchanged when no supported filters are present' do
      scope = double('scope')

      expect(repository.send(:apply_filters, scope, {})).to eq(scope)
    end
  end

  describe '#apply_text_search' do
    it 'uses elasticsearch ids when they are present' do
      scope = double('scope')
      filtered_scope = double('filtered_scope')
      allow(repository).to receive(:elasticsearch_ids).with('maya').and_return([1, 2])
      allow(scope).to receive(:where).with(id: [1, 2]).and_return(filtered_scope)

      expect(repository.send(:apply_text_search, scope, 'maya')).to eq(filtered_scope)
    end
  end

  describe '#catch_database_errors' do
    it 'delegates handled exceptions to repository_failure' do
      failure = ActiveRecord::StatementInvalid.new('db error')
      expected = Dry::Monads::Failure(:failed)
      allow(repository).to receive(:repository_failure).with(:fetch_data, failure, not_found: false, passthrough: false).and_return(expected)

      result = repository.send(:catch_database_errors, :fetch_data, exceptions: [ActiveRecord::StatementInvalid]) do
        raise failure
      end

      expect(result).to eq(expected)
    end
  end

  describe '#repository_failure' do
    it 'returns not found failures for missing records' do
      allow(Rails.logger).to receive(:error)

      result = repository.send(:repository_failure, :find_data, ActiveRecord::RecordNotFound.new('missing'), not_found: true, passthrough: false)

      expect(result).to eq(Dry::Monads::Failure(type: :not_found, message: 'Employee not found'))
    end

    it 'returns record failures for passthrough errors' do
      allow(Rails.logger).to receive(:error)
      record = build(:employee, email: nil)
      record.validate
      failure = ActiveRecord::RecordInvalid.new(record)

      result = repository.send(:repository_failure, :upsert_data, failure, not_found: false, passthrough: true)

      expect(result).to eq(Dry::Monads::Failure(type: :validation_error, errors: record.errors.to_hash(true)))
    end

    it 'wraps unhandled failures in an unwrap error' do
      allow(Rails.logger).to receive(:error)

      result = repository.send(:repository_failure, :fetch_data, ActiveRecord::StatementInvalid.new('db error'), not_found: false, passthrough: false)

      expect(result).to be_failure
      expect(result.failure).to be_a(Dry::Monads::UnwrapError)
      expect(result.failure.message).to include('db error')
    end
  end

  describe '#record_failure' do
    it 'returns internal errors when the failure has no record' do
      failure = StandardError.new('boom')

      expect(repository.send(:record_failure, failure)).to eq(type: :internal_error, message: 'boom')
    end
  end
end
