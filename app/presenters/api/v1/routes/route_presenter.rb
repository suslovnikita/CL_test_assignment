# frozen_string_literal: true

require_relative "segment_presenter"

module Api
  module V1
    module Routes
      # @api private
      class RoutePresenter
        # @param segment_presenter [#call]
        def initialize(segment_presenter: SegmentPresenter.new)
          @segment_presenter = segment_presenter
        end

        # @param route [Route]
        # @return [Hash]
        def call(route)
          {
            origin_iata: route.origin_iata,
            destination_iata: route.destination_iata,
            departure_time: route.departure_time.utc.iso8601(3),
            arrival_time: route.arrival_time.utc.iso8601(3),
            segments: route.segments.map { |segment| segment_presenter.call(segment) }
          }
        end

        private

        attr_reader :segment_presenter
      end
    end
  end
end
