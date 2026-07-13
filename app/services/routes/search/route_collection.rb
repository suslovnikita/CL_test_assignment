# frozen_string_literal: true

require "set"

module Routes
  class Search
    # @api private
    class RouteCollection
      # @return [void]
      def initialize
        @routes = []
        @seen_segment_ids = Set.new
      end

      # @param route [Route]
      # @return [void]
      def add(route)
        # Одна и та же цепочка сегментов может прийти через разные разрешенные схемы, поэтому убираем дубли.
        segment_ids = route.segments.map(&:id)
        return unless seen_segment_ids.add?(segment_ids)

        routes << route
        nil
      end

      # @return [Array<Route>]
      def to_a
        routes.sort { |left, right| compare_routes(left, right) }
      end

      private

      attr_reader :routes, :seen_segment_ids

      def compare_routes(left, right)
        # nonzero? пропускает равные критерии и дает перейти к следующему правилу сортировки.
        (left.departure_time <=> right.departure_time).nonzero? ||
          compare_segments(left.segments, right.segments).nonzero? ||
          (left.arrival_time <=> right.arrival_time).nonzero? ||
          left.segments.length <=> right.segments.length
      end

      def compare_segments(left_segments, right_segments)
        # При одинаковом вылете маршрута сравниваем пересадки по времени вылета каждого плеча.
        left_segments.each_with_index do |left_segment, index|
          right_segment = right_segments[index]
          return 1 unless right_segment

          comparison = left_segment.std <=> right_segment.std
          return comparison if comparison.nonzero?
        end

        left_segments.length <=> right_segments.length
      end
    end
  end
end
