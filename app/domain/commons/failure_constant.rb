class Commons::FailureConstant < RuntimeError
  attr_reader :key, :extras

  def initialize(key: nil, message: nil, extras: {})
    @key = key
    @extras = extras
    super(message)
  end

  class UpdateForbiddenError < Commons::FailureConstant
    def initialize
      super(key: :update_forbidden_error)
    end
  end

  class SaveError < Commons::FailureConstant
    def initialize
      super(key: :save_error)
    end
  end

  class UpdateError < Commons::FailureConstant
    def initialize(extras: {})
      super(key: :update_error, extras: extras)
    end
  end

  class RecordNotFound < Commons::FailureConstant
    def initialize(extras: {})
      super(key: :record_not_found, extras: extras)
    end
  end

  class RecordInvalid < Commons::FailureConstant
    def initialize(extras: {})
      super(key: :record_invalid, extras: extras)
    end
  end

  class InvalidParameter < Commons::FailureConstant
    def initialize(extras: {})
      super(key: :invalid_parameter, extras: extras)
    end
  end

  class InvalidArgument < Commons::FailureConstant
    def initialize(extras: {})
      super(key: :invalid_argument, extras: extras)
    end
  end

  class InvalidResource < Commons::FailureConstant
    def initialize(extras: {})
      super(key: :invalid_resource, extras: extras)
    end
  end

  class InvalidPayload < Commons::FailureConstant
    def initialize(extras: {})
      super(key: :invalid_payload, extras: extras)
    end
  end

  class TransitionForbiddenError < Commons::FailureConstant
    def initialize
      super(key: :transition_forbidden_error)
    end
  end

  class StatusTransitionError < Commons::FailureConstant
    def initialize
      super(key: :status_transition_error)
    end
  end

  class UpdateForbiddenError < Commons::FailureConstant
    def initialize
      super(key: :update_forbidden_error)
    end
  end

  class InvalidRole < Commons::FailureConstant
    def initialize(extras: {})
      super(key: :invalid_role, extras: extras)
    end
  end
end
