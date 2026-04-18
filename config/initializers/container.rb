require 'dry/system/container'

class AppContainer < Dry::System::Container
  configure do |config|
    config.root = (Pathname.pwd + 'app')

    config.component_dirs.add 'domain'
  end
end

# AppContainer.register('payroll.employees.search') { Payroll::Employees::Search.new }
# AppContainer.register('payroll.employees.upsert') { Payroll::Employees::Upsert.new }
# AppContainer.register('payroll.employees.destroy') { Payroll::Employees::Destroy.new }
# AppContainer.register('payroll.salary_insights.country_report') { Payroll::SalaryInsights::CountryReport.new }

AppContainer.finalize! unless AppContainer.finalized?
