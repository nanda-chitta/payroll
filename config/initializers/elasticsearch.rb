elasticsearch_url =
  ENV["ELASTICSEARCH_URL"].presence ||
  (ENV["ELASTICSEARCH_HOSTPORT"].present? ? "http://#{ENV.fetch('ELASTICSEARCH_HOSTPORT')}" : nil) ||
  "http://localhost:9200"

Elasticsearch::Model.client = Elasticsearch::Client.new(
  url: elasticsearch_url,
  log: ENV['ELASTICSEARCH_LOG'] == 'true',
  transport_options: {
    headers: { 'x-elastic-product-origin' => 'elasticsearch' }
  }
)
