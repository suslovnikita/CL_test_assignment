# frozen_string_literal: true

module Api
  module V1
    class RoutesController < ApplicationController
      def index
        return render_bad_request(index_request) if index_request.invalid?

        render json: index_use_case.map { |route| presenter.call(route) }
      end

      private

      def index_use_case
        ::Routes::Search.new.call(
          carrier: index_request.carrier,
          origin_iata: index_request.origin_iata,
          destination_iata: index_request.destination_iata,
          departure_from: index_request.departure_from,
          departure_to: index_request.departure_to
        )
      end

      def index_request
        @index_request ||= Api::V1::Routes::IndexRequest.new(**params.to_unsafe_h)
      end

      def presenter
        @presenter ||= Api::V1::Routes::RoutePresenter.new
      end
    end
  end
end
