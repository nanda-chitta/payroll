Elasticsearch::Model.client = Elasticsearch::Client.new(
  url: ENV.fetch('ELASTICSEARCH_URL', 'http://localhost:9200'),
  log: ENV['ELASTICSEARCH_LOG'] == 'true',
  transport_options: {
    headers: { 'x-elastic-product-origin' => 'elasticsearch' }
  }
)
