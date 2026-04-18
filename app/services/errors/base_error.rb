class Errors::BaseError < RuntimeError
  attr_reader :message, :extras

  def initialize(message: nil, extras: {})
    @message = message
    @extras = extras
  end
end
