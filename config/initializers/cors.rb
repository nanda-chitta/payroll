hosts = [
  *ENV.fetch('DEV_DOMAIN').split(','),
  *ENV.fetch('PROD_DOMAIN').split(',')
].reject(&:blank?)

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins(*hosts)

    resource '*',
             headers: :any,
             methods: %i[get post options delete put patch head]
  end
end
