# frozen_string_literal: true

class IataValidator < ActiveModel::EachValidator
  IATA_FORMAT = /\A[A-Z]{3}\z/

  def validate_each(record, attribute, value)
    return if value.blank? || IATA_FORMAT.match?(value)

    record.errors.add(attribute, :invalid)
  end
end
