# frozen_string_literal: true

require_relative "search/permitted_route_legs"
require_relative "search/bind_collector"
require_relative "search/route_builder"
require_relative "search/route_collection"
require_relative "search/route_query"

module Routes
  class Search
    # @param permitted_route_legs [#call]
    # @param route_query [#call]
    # @param route_builder [#call]
    # @param route_collection [#new]
    def initialize(
      permitted_route_legs: PermittedRouteLegs.new,
      route_query: RouteQuery.new,
      route_builder: RouteBuilder.new,
      route_collection: RouteCollection
    )
      @permitted_route_legs = permitted_route_legs
      @route_query = route_query
      @route_builder = route_builder
      @route_collection = route_collection
    end

    # @param carrier [String]
    # @param origin_iata [String]
    # @param destination_iata [String]
    # @param departure_from [Date]
    # @param departure_to [Date]
    # @return [Array<Route>]
    def call(carrier:, origin_iata:, destination_iata:, departure_from:, departure_to:)
      # Сначала находим разрешенные схемы маршрута, а затем ищем фактические рейсы группами по количеству плеч.
      departure_window = departure_window_for(departure_from, departure_to)
      route_legs = permitted_route_legs.call(carrier:, origin_iata:, destination_iata:)
      return [] if route_legs.empty?

      build_result(route_legs, carrier:, departure_window:)
    end

    private

    attr_reader :permitted_route_legs, :route_query, :route_builder, :route_collection

    def departure_window_for(departure_from, departure_to)
      departure_from.to_time(:utc).beginning_of_day..departure_to.to_time(:utc).end_of_day
    end

    def build_result(route_legs, carrier:, departure_window:)
      routes = route_collection.new

      route_legs.group_by(&:length).each_value do |legs_group|
        # Цепочки с одинаковым количеством плеч можно покрыть одним SQL self-join.
        route_query.call(carrier:, legs_group:, departure_window:).each do |segments|
          routes.add(route_builder.call(legs: legs_for(segments), segments:))
        end
      end

      routes.to_a
    end

    def legs_for(segments)
      segments.map do |segment|
        [ segment.origin_iata, segment.destination_iata ]
      end
    end
  end
end
