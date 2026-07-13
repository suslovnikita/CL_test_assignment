# frozen_string_literal: true

require "set"

module Routes
  class Search
    # @api private
    class PermittedRouteLegs
      # @param permitted_route_model [#find_by]
      def initialize(permitted_route_model: PermittedRoute)
        @permitted_route_model = permitted_route_model
      end

      # @param carrier [String]
      # @param origin_iata [String]
      # @param destination_iata [String]
      # @return [Array<Array<Array<String>>>]
      def call(carrier:, origin_iata:, destination_iata:)
        permitted_route = permitted_route_model.find_by(carrier:, origin_iata:, destination_iata:)
        return [] unless permitted_route

        legs_for(permitted_route, origin_iata:, destination_iata:)
      end

      private

      attr_reader :permitted_route_model

      def legs_for(permitted_route, origin_iata:, destination_iata:)
        # Переводим запись permitted_routes в набор цепочек плеч, по которым дальше строится self-join.
        route_legs = Set.new
        route_legs << [ [ origin_iata, destination_iata ] ] if permitted_route.direct?

        permitted_route.transfer_iata_codes.each do |transfer_codes|
          route_legs << transfer_legs(origin_iata, transfer_codes, destination_iata)
        end

        route_legs.to_a
      end

      def transfer_legs(origin_iata, transfer_codes, destination_iata)
        legs = []
        previous_iata = origin_iata

        # Коды пересадок хранятся подряд строкой: "IKTDME" превращается в IKT -> DME.
        transfer_codes.scan(/.{3}/) do |transfer_iata|
          legs << [ previous_iata, transfer_iata ]
          previous_iata = transfer_iata
        end

        legs << [ previous_iata, destination_iata ]
      end
    end
  end
end
