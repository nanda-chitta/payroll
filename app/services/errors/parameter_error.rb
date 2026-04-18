class Errors::ParameterError < RuntimeError
  attr_reader :message

  def initialize(key)
    @message = key
  end
end
