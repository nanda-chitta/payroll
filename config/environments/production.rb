require "active_support/core_ext/integer/time"
require "digest"

Rails.application.configure do
  # Code is not reloaded between requests.
  config.enable_reloading = false

  # Eager load code on boot for better performance and memory savings.
  config.eager_load = true

  # Full error reports are disabled.
  config.consider_all_requests_local = false

  # Cache static files for far-future expiry since they are digest stamped.
  config.public_file_server.headers = {
    "cache-control" => "public, max-age=#{1.year.to_i}"
  }

  # Store uploaded files on the local file system.
  config.active_storage.service = :local

  # Force all access to the app over SSL.
  config.force_ssl = true

  # Do not require credentials/master.key for this deployment style.
  config.require_master_key = false

  # Stable secret key base for production.
  config.secret_key_base = ENV["SECRET_KEY_BASE"].presence ||
                           Digest::SHA256.hexdigest(
                             [
                               ENV["DATABASE_URL"],
                               ENV["REDIS_URL"],
                               ENV["RENDER_EXTERNAL_HOSTNAME"],
                               "payroll-production-secret"
                             ].compact.join(":")
                           )

  # Log to STDOUT
  config.log_tags = [:request_id]
  config.logger = ActiveSupport::TaggedLogging.logger(STDOUT)
  config.log_level = ENV.fetch("RAILS_LOG_LEVEL", "info")

  # Prevent health checks from cluttering logs.
  config.silence_healthcheck_path = "/up"

  # Don't log deprecations.
  config.active_support.report_deprecations = false

  # Prefer Render Key Value / Redis when configured, otherwise fall back to Solid Cache tables.
  if ENV["REDIS_URL"].present?
    config.cache_store = :redis_cache_store, {
      url: ENV.fetch("REDIS_URL"),
      namespace: "payroll:cache",
      expires_in: 1.hour
    }
  else
    config.cache_store = :solid_cache_store
  end

  # Prefer Redis-backed Sidekiq when available, otherwise use Solid Queue.
  if ENV["REDIS_URL"].present?
    config.active_job.queue_adapter = :sidekiq
  else
    config.active_job.queue_adapter = :solid_queue
    config.solid_queue.connects_to = { database: { writing: :queue } }
  end

  # Action Mailer host
  config.action_mailer.default_url_options = {
    host: ENV.fetch("APP_HOST", "localhost")
  }

  # Locale fallbacks
  config.i18n.fallbacks = true

  # Do not dump schema after migrations
  config.active_record.dump_schema_after_migration = false

  # Only use :id for inspections in production
  config.active_record.attributes_for_inspect = [:id]
end
