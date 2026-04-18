require 'capybara/rspec'
require 'selenium/webdriver'

Capybara.default_max_wait_time = 5

frontend_url = ENV['FRONTEND_URL']&.chomp('/')

if frontend_url.present?
  Capybara.configure do |config|
    config.run_server = false
    config.app_host = frontend_url
    config.default_host = frontend_url
  end
end

Capybara.register_driver :selenium_chrome do |app|
  options = Selenium::WebDriver::Chrome::Options.new
  options.add_argument('--window-size=1400,1400')

  Capybara::Selenium::Driver.new(
    app,
    browser: :chrome,
    options: options
  )
end

Capybara.register_driver :selenium_chrome_headless do |app|
  options = Selenium::WebDriver::Chrome::Options.new
  options.add_argument('--headless=new')
  options.add_argument('--disable-gpu')
  options.add_argument('--no-sandbox')
  options.add_argument('--disable-dev-shm-usage')
  options.add_argument('--window-size=1400,1400')
  options.add_argument('--log-level=3')

  Capybara::Selenium::Driver.new(
    app,
    browser: :chrome,
    options: options
  )
end

Capybara.default_driver = :rack_test
Capybara.javascript_driver = :selenium_chrome_headless
