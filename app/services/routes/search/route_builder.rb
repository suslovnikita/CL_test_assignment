# frozen_string_literal: true

module Routes
  class Search
    Route = Data.define(
      :origin_iata,
      :destination_iata,
      :departure_time,
      :arrival_time,
      :segments
    )

    # @api private
    class RouteBuilder
      # @param legs [Array<Array<String>>]
      # @param segments [Array<Segment>]
      # @return [Route]
      def call(legs:, segments:)
        Route.new(
          origin_iata: legs.first.first,
          destination_iata: legs.last.last,
          departure_time: segments.first.std,
          arrival_time: segments.last.sta,
          segments: segments.freeze
        )
      end
    end
  end
end
