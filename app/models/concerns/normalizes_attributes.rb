module NormalizesAttributes
  extend ActiveSupport::Concern

  class_methods do
    def normalizes_attributes(*attributes, blank_to_nil: false, transform: nil)
      before_validation do
        attributes.each do |attribute|
          value = public_send(attribute)
          next unless value.respond_to?(:strip)

          normalized = value.strip
          normalized = normalized.presence if blank_to_nil
          normalized = normalized.public_send(transform) if normalized.present? && transform.present?

          public_send("#{attribute}=", normalized)
        end
      end
    end
  end
end
