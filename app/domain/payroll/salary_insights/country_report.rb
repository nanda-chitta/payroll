require 'dry/monads'

module Payroll
  module SalaryInsights
    class CountryReport
      include Dry::Monads[:result]

      def call(country:, job_title_id: nil)
        @country = country.presence
        @job_title_id = job_title_id.presence

        Success(Rails.cache.fetch(cache_key, expires_in: 10.minutes) { report })
      rescue StandardError => e
        Failure(type: :internal_error, message: e.message)
      end

      private

      attr_reader :country, :job_title_id

      def report
        {
          country: @country,
          selected_job_title_id: @job_title_id,
          country_salary: aggregate(country_scope),
          job_title_salary: aggregate(job_title_scope),
          headcount_by_job_title: headcount_by_job_title,
          salary_distribution: salary_distribution
        }
      end

      def cache_key
        [ 'salary_insights', country.presence || 'all', job_title_id.presence || 'all' ].join(':')
      end

      def base_scope
        Employee
          .joins(:employee_addresses, :employee_salaries)
          .where(employee_addresses: { primary_address: true })
          .where('employee_salaries.effective_from <= ?', Date.current)
          .where('employee_salaries.effective_to IS NULL OR employee_salaries.effective_to >= ?', Date.current)
      end

      def country_scope
        return base_scope if country.blank?

        base_scope.where(employee_addresses: { country: })
      end

      def job_title_scope
        return country_scope if job_title_id.blank?

        country_scope.where(job_title_id:)
      end

      def aggregate(scope)
        count, min, max, avg = scope.pick(
          Arel.sql('COUNT(DISTINCT employees.id)'),
          Arel.sql('MIN(employee_salaries.amount)'),
          Arel.sql('MAX(employee_salaries.amount)'),
          Arel.sql('AVG(employee_salaries.amount)')
        )

        {
          employee_count: count.to_i,
          minimum_salary: decimal_string(min),
          maximum_salary: decimal_string(max),
          average_salary: decimal_string(avg)
        }
      end

      def headcount_by_job_title
        country_scope
          .joins(:job_title)
          .group('job_titles.id', 'job_titles.name')
          .order(Arel.sql('COUNT(DISTINCT employees.id) DESC'))
          .limit(8)
          .count('DISTINCT employees.id')
          .map do |(job_title_id, name), count|
            { job_title_id:, name:, employee_count: count }
          end
      end

      def salary_distribution
        [
          [ '0-50k', 0, 50_000 ],
          [ '50k-100k', 50_000, 100_000 ],
          [ '100k-150k', 100_000, 150_000 ],
          [ '150k-200k', 150_000, 200_000 ],
          [ '200k+', 200_000, nil ]
        ].map do |label, lower, upper|
          scope = country_scope.where('employee_salaries.amount >= ?', lower)
          scope = scope.where('employee_salaries.amount < ?', upper) if upper.present?

          { label:, employee_count: scope.distinct.count(:id) }
        end
      end

      def decimal_string(value)
        return nil if value.blank?

        format('%.2f', value)
      end
    end
  end
end
