# frozen_string_literal: true

class ApplicationRequest
  include ActiveModel::Model
  include ActiveModel::Attributes

  def initialize(attributes = nil, **keyword_attributes)
    attributes = attributes.to_h.merge(keyword_attributes)
    @raw_attributes = attributes.to_h.stringify_keys
    attributes = @raw_attributes.slice(*self.class.attribute_names)

    super(attributes)
  end

  private

  def raw_attribute(attribute)
    @raw_attributes[attribute.to_s]
  end
end
