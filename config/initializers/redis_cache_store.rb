if ENV["REDIS_URL"].present?
  Rails.application.config.cache_store = :redis_cache_store, {
    url: ENV["REDIS_URL"],
    reconnect_attempts: 1,
    pool_size: Integer(ENV.fetch("RAILS_MAX_THREADS", 5))
  }
end
