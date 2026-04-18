class Errors::ForbiddenError < RuntimeError
  attr_reader :message, :extras

  def initialize(key, extras: {})
    @message = key
    @extras = extras
  end
end
