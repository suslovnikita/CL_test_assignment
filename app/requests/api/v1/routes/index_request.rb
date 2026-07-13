# frozen_string_literal: true

module Api
  module V1
    module Routes
      class IndexRequest < ApplicationRequest
        attribute :carrier, :string
        attribute :origin_iata, :string
        attribute :destination_iata, :string
        attribute :departure_from, :date
        attribute :departure_to, :date

        validates :origin_iata, :destination_iata, iata: true
        validate :validate_required_attributes
        validate :validate_departure_from_date
        validate :validate_departure_to_date
        validate :validate_departure_range

        private

        def missing_attributes
          attribute_names.select { |attribute| raw_attribute(attribute).blank? }
        end

        def validate_required_attributes
          missing_attributes.each { |attribute| errors.add(attribute, :blank) }
        end

        def validate_departure_from_date
          errors.add(:departure_from) if invalid_date?(:departure_from)
        end

        def validate_departure_to_date
          errors.add(:departure_to) if invalid_date?(:departure_to)
        end

        def validate_departure_range
          return if departure_from.blank? || departure_to.blank?

          errors.add(:departure_to, :greater_than_or_equal_to, count: :departure_from) if departure_from > departure_to
        end

        def invalid_date?(attribute)
          raw_attribute(attribute).present? && public_send(attribute).blank?
        end
      end
    end
  end
end
