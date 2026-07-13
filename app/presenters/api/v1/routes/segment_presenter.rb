# frozen_string_literal: true

module Api
  module V1
    module Routes
      # @api private
      class SegmentPresenter
        # @param segment [Segment]
        # @return [Hash]
        def call(segment)
          {
            carrier: segment.airline,
            segment_number: segment.segment_number,
            origin_iata: segment.origin_iata,
            destination_iata: segment.destination_iata,
            std: segment.std.utc.iso8601(3),
            sta: segment.sta.utc.iso8601(3)
          }
        end
      end
    end
  end
end
