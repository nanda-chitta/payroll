RSpec.configure do |config|
  config.before(:each, type: :system) do |example|
    driven_by :selenium_chrome_headless
  end
end
