hosts = %w[DEV_DOMAIN PROD_DOMAIN FRONTEND_URL]
  .flat_map { |key| ENV.fetch(key, '').split(',') }
  .map(&:strip)
  .reject(&:blank?)

if hosts.any?
  Rails.application.config.middleware.insert_before 0, Rack::Cors do
    allow do
      origins(*hosts)

      resource '*',
               headers: :any,
               methods: %i[get post options delete put patch head]
    end
  end
end
