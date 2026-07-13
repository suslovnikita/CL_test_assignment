# frozen_string_literal: true

require "json"
require "rails_helper"

RSpec.describe Routes::Search do
  JAN_1 = Date.new(2024, 1, 1)
  JAN_2 = Date.new(2024, 1, 2)
  JAN_3 = Date.new(2024, 1, 3)
  JAN_4 = Date.new(2024, 1, 4)
  JAN_5 = Date.new(2024, 1, 5)
  JAN_6 = Date.new(2024, 1, 6)

  describe "#call" do
    shared_examples "routes for date range" do |iata:, departure:|
      origin_iata = iata.fetch(:origin)
      destination_iata = iata.fetch(:destination)
      departure_from = departure.fetch(:from)
      departure_to = departure.fetch(:to)

      it "#{origin_iata} -> #{destination_iata} #{departure_from}..#{departure_to}" do
        routes = described_class.new.call(
          carrier: "S7",
          origin_iata:,
          destination_iata:,
          departure_from:,
          departure_to:
        )

        expect(present_routes(routes)).to eq(
          expected_routes(origin_iata, destination_iata, departure_from, departure_to)
        )
      end
    end

    context "UUS -> DME" do
      it_behaves_like "routes for date range", iata: { origin: "UUS", destination: "DME" }, departure: { from: JAN_1, to: JAN_1 }
      it_behaves_like "routes for date range", iata: { origin: "UUS", destination: "DME" }, departure: { from: JAN_2, to: JAN_2 }
      it_behaves_like "routes for date range", iata: { origin: "UUS", destination: "DME" }, departure: { from: JAN_3, to: JAN_3 }
      it_behaves_like "routes for date range", iata: { origin: "UUS", destination: "DME" }, departure: { from: JAN_4, to: JAN_4 }
      it_behaves_like "routes for date range", iata: { origin: "UUS", destination: "DME" }, departure: { from: JAN_5, to: JAN_5 }
      it_behaves_like "routes for date range", iata: { origin: "UUS", destination: "DME" }, departure: { from: JAN_6, to: JAN_6 }

      it_behaves_like "routes for date range", iata: { origin: "UUS", destination: "DME" }, departure: { from: JAN_1, to: JAN_2 }
      it_behaves_like "routes for date range", iata: { origin: "UUS", destination: "DME" }, departure: { from: JAN_1, to: JAN_3 }
      it_behaves_like "routes for date range", iata: { origin: "UUS", destination: "DME" }, departure: { from: JAN_1, to: JAN_4 }
      it_behaves_like "routes for date range", iata: { origin: "UUS", destination: "DME" }, departure: { from: JAN_1, to: JAN_5 }
      it_behaves_like "routes for date range", iata: { origin: "UUS", destination: "DME" }, departure: { from: JAN_1, to: JAN_6 }
      it_behaves_like "routes for date range", iata: { origin: "UUS", destination: "DME" }, departure: { from: JAN_2, to: JAN_3 }
      it_behaves_like "routes for date range", iata: { origin: "UUS", destination: "DME" }, departure: { from: JAN_2, to: JAN_4 }
      it_behaves_like "routes for date range", iata: { origin: "UUS", destination: "DME" }, departure: { from: JAN_2, to: JAN_5 }
      it_behaves_like "routes for date range", iata: { origin: "UUS", destination: "DME" }, departure: { from: JAN_2, to: JAN_6 }
      it_behaves_like "routes for date range", iata: { origin: "UUS", destination: "DME" }, departure: { from: JAN_3, to: JAN_4 }
      it_behaves_like "routes for date range", iata: { origin: "UUS", destination: "DME" }, departure: { from: JAN_3, to: JAN_5 }
      it_behaves_like "routes for date range", iata: { origin: "UUS", destination: "DME" }, departure: { from: JAN_3, to: JAN_6 }
      it_behaves_like "routes for date range", iata: { origin: "UUS", destination: "DME" }, departure: { from: JAN_4, to: JAN_5 }
      it_behaves_like "routes for date range", iata: { origin: "UUS", destination: "DME" }, departure: { from: JAN_4, to: JAN_6 }
      it_behaves_like "routes for date range", iata: { origin: "UUS", destination: "DME" }, departure: { from: JAN_5, to: JAN_6 }
    end

    context "UUS -> IKT" do
      it_behaves_like "routes for date range", iata: { origin: "UUS", destination: "IKT" }, departure: { from: JAN_1, to: JAN_1 }
      it_behaves_like "routes for date range", iata: { origin: "UUS", destination: "IKT" }, departure: { from: JAN_2, to: JAN_2 }
      it_behaves_like "routes for date range", iata: { origin: "UUS", destination: "IKT" }, departure: { from: JAN_3, to: JAN_3 }
      it_behaves_like "routes for date range", iata: { origin: "UUS", destination: "IKT" }, departure: { from: JAN_4, to: JAN_4 }
      it_behaves_like "routes for date range", iata: { origin: "UUS", destination: "IKT" }, departure: { from: JAN_5, to: JAN_5 }
      it_behaves_like "routes for date range", iata: { origin: "UUS", destination: "IKT" }, departure: { from: JAN_6, to: JAN_6 }

      it_behaves_like "routes for date range", iata: { origin: "UUS", destination: "IKT" }, departure: { from: JAN_1, to: JAN_2 }
      it_behaves_like "routes for date range", iata: { origin: "UUS", destination: "IKT" }, departure: { from: JAN_1, to: JAN_3 }
      it_behaves_like "routes for date range", iata: { origin: "UUS", destination: "IKT" }, departure: { from: JAN_1, to: JAN_4 }
      it_behaves_like "routes for date range", iata: { origin: "UUS", destination: "IKT" }, departure: { from: JAN_1, to: JAN_5 }
      it_behaves_like "routes for date range", iata: { origin: "UUS", destination: "IKT" }, departure: { from: JAN_1, to: JAN_6 }
      it_behaves_like "routes for date range", iata: { origin: "UUS", destination: "IKT" }, departure: { from: JAN_2, to: JAN_3 }
      it_behaves_like "routes for date range", iata: { origin: "UUS", destination: "IKT" }, departure: { from: JAN_2, to: JAN_4 }
      it_behaves_like "routes for date range", iata: { origin: "UUS", destination: "IKT" }, departure: { from: JAN_2, to: JAN_5 }
      it_behaves_like "routes for date range", iata: { origin: "UUS", destination: "IKT" }, departure: { from: JAN_2, to: JAN_6 }
      it_behaves_like "routes for date range", iata: { origin: "UUS", destination: "IKT" }, departure: { from: JAN_3, to: JAN_4 }
      it_behaves_like "routes for date range", iata: { origin: "UUS", destination: "IKT" }, departure: { from: JAN_3, to: JAN_5 }
      it_behaves_like "routes for date range", iata: { origin: "UUS", destination: "IKT" }, departure: { from: JAN_3, to: JAN_6 }
      it_behaves_like "routes for date range", iata: { origin: "UUS", destination: "IKT" }, departure: { from: JAN_4, to: JAN_5 }
      it_behaves_like "routes for date range", iata: { origin: "UUS", destination: "IKT" }, departure: { from: JAN_4, to: JAN_6 }
      it_behaves_like "routes for date range", iata: { origin: "UUS", destination: "IKT" }, departure: { from: JAN_5, to: JAN_6 }
    end

    context "UUS -> NOZ" do
      it_behaves_like "routes for date range", iata: { origin: "UUS", destination: "NOZ" }, departure: { from: JAN_1, to: JAN_1 }
      it_behaves_like "routes for date range", iata: { origin: "UUS", destination: "NOZ" }, departure: { from: JAN_2, to: JAN_2 }
      it_behaves_like "routes for date range", iata: { origin: "UUS", destination: "NOZ" }, departure: { from: JAN_3, to: JAN_3 }
      it_behaves_like "routes for date range", iata: { origin: "UUS", destination: "NOZ" }, departure: { from: JAN_4, to: JAN_4 }
      it_behaves_like "routes for date range", iata: { origin: "UUS", destination: "NOZ" }, departure: { from: JAN_5, to: JAN_5 }
      it_behaves_like "routes for date range", iata: { origin: "UUS", destination: "NOZ" }, departure: { from: JAN_6, to: JAN_6 }

      it_behaves_like "routes for date range", iata: { origin: "UUS", destination: "NOZ" }, departure: { from: JAN_1, to: JAN_2 }
      it_behaves_like "routes for date range", iata: { origin: "UUS", destination: "NOZ" }, departure: { from: JAN_1, to: JAN_3 }
      it_behaves_like "routes for date range", iata: { origin: "UUS", destination: "NOZ" }, departure: { from: JAN_1, to: JAN_4 }
      it_behaves_like "routes for date range", iata: { origin: "UUS", destination: "NOZ" }, departure: { from: JAN_1, to: JAN_5 }
      it_behaves_like "routes for date range", iata: { origin: "UUS", destination: "NOZ" }, departure: { from: JAN_1, to: JAN_6 }
      it_behaves_like "routes for date range", iata: { origin: "UUS", destination: "NOZ" }, departure: { from: JAN_2, to: JAN_3 }
      it_behaves_like "routes for date range", iata: { origin: "UUS", destination: "NOZ" }, departure: { from: JAN_2, to: JAN_4 }
      it_behaves_like "routes for date range", iata: { origin: "UUS", destination: "NOZ" }, departure: { from: JAN_2, to: JAN_5 }
      it_behaves_like "routes for date range", iata: { origin: "UUS", destination: "NOZ" }, departure: { from: JAN_2, to: JAN_6 }
      it_behaves_like "routes for date range", iata: { origin: "UUS", destination: "NOZ" }, departure: { from: JAN_3, to: JAN_4 }
      it_behaves_like "routes for date range", iata: { origin: "UUS", destination: "NOZ" }, departure: { from: JAN_3, to: JAN_5 }
      it_behaves_like "routes for date range", iata: { origin: "UUS", destination: "NOZ" }, departure: { from: JAN_3, to: JAN_6 }
      it_behaves_like "routes for date range", iata: { origin: "UUS", destination: "NOZ" }, departure: { from: JAN_4, to: JAN_5 }
      it_behaves_like "routes for date range", iata: { origin: "UUS", destination: "NOZ" }, departure: { from: JAN_4, to: JAN_6 }
      it_behaves_like "routes for date range", iata: { origin: "UUS", destination: "NOZ" }, departure: { from: JAN_5, to: JAN_6 }
    end

    it "returns an empty array when the route is not permitted" do
      expect(
        described_class.new.call(
          carrier: "S7",
          origin_iata: "UUS",
          destination_iata: "ZZZ",
          departure_from: Date.new(2024, 1, 1),
          departure_to: Date.new(2024, 1, 7)
        )
      ).to eq([])
    end

    it "returns an empty array when the carrier has no segments or permitted routes" do
      expect(
        described_class.new.call(
          carrier: "SU",
          origin_iata: "UUS",
          destination_iata: "DME",
          departure_from: Date.new(2024, 1, 1),
          departure_to: Date.new(2024, 1, 7)
        )
      ).to eq([])
    end

    it "supports replacing route search collaborators" do
      departure_time = Time.utc(2024, 1, 1, 10)
      arrival_time = Time.utc(2024, 1, 1, 12)
      segment = instance_double(
        Segment,
        id: 1,
        origin_iata: "UUS",
        destination_iata: "DME",
        std: departure_time,
        sta: arrival_time
      )

      routes = described_class.new(
        permitted_route_legs: ->(carrier:, origin_iata:, destination_iata:) { [ [ [ origin_iata, destination_iata ] ] ] },
        route_query: ->(carrier:, legs_group:, departure_window:) { [ [ segment ] ] }
      ).call(
        carrier: "S7",
        origin_iata: "UUS",
        destination_iata: "DME",
        departure_from: JAN_1,
        departure_to: JAN_1
      )

      expect(routes).to contain_exactly(
        have_attributes(
          origin_iata: "UUS",
          destination_iata: "DME",
          departure_time: departure_time,
          arrival_time: arrival_time,
          segments: [ segment ]
        )
      )
    end

    it "deduplicates routes built from the same segment chain" do
      departure_time = Time.utc(2024, 1, 1, 10)
      arrival_time = Time.utc(2024, 1, 1, 12)
      segment = instance_double(
        Segment,
        id: 1,
        origin_iata: "UUS",
        destination_iata: "DME",
        std: departure_time,
        sta: arrival_time
      )

      routes = described_class.new(
        permitted_route_legs: ->(carrier:, origin_iata:, destination_iata:) { [ [ [ origin_iata, destination_iata ] ] ] },
        route_query: ->(carrier:, legs_group:, departure_window:) { [ [ segment ], [ segment ] ] }
      ).call(
        carrier: "S7",
        origin_iata: "UUS",
        destination_iata: "DME",
        departure_from: JAN_1,
        departure_to: JAN_1
      )

      expect(routes.size).to eq(1)
    end

    it "includes transfer routes at the 8 and 48 hour connection boundaries" do
      create(
        :permitted_route,
        carrier: "ZZ",
        origin_iata: "AAA",
        destination_iata: "CCC",
        direct: false,
        transfer_iata_codes: [ "BBB" ]
      )

      create(
        :segment,
        airline: "ZZ",
        segment_number: "ZZ-1",
        origin_iata: "AAA",
        destination_iata: "BBB",
        std: Time.utc(2024, 1, 1, 0),
        sta: Time.utc(2024, 1, 1, 2)
      )
      create(
        :segment,
        airline: "ZZ",
        segment_number: "ZZ-8H",
        origin_iata: "BBB",
        destination_iata: "CCC",
        std: Time.utc(2024, 1, 1, 10),
        sta: Time.utc(2024, 1, 1, 12)
      )
      create(
        :segment,
        airline: "ZZ",
        segment_number: "ZZ-48H",
        origin_iata: "BBB",
        destination_iata: "CCC",
        std: Time.utc(2024, 1, 3, 2),
        sta: Time.utc(2024, 1, 3, 4)
      )

      routes = described_class.new.call(
        carrier: "ZZ",
        origin_iata: "AAA",
        destination_iata: "CCC",
        departure_from: JAN_1,
        departure_to: JAN_1
      )

      expect(routes.map { |route| route.segments.last.segment_number }).to contain_exactly("ZZ-8H", "ZZ-48H")
    end

    it "queries segments once per route length" do
      create(
        :permitted_route,
        carrier: "ZZ",
        origin_iata: "AAA",
        destination_iata: "CCC",
        direct: true,
        transfer_iata_codes: [ "BBB", "DDD", "EEEFFF" ]
      )

      query_count = 0
      subscriber = ActiveSupport::Notifications.subscribe("sql.active_record") do |_name, _start, _finish, _id, payload|
        query_count += 1 if payload[:name] == "Routes::Search::RouteQuery"
      end

      described_class.new.call(
        carrier: "ZZ",
        origin_iata: "AAA",
        destination_iata: "CCC",
        departure_from: JAN_1,
        departure_to: JAN_1
      )

      expect(query_count).to eq(3)
    ensure
      ActiveSupport::Notifications.unsubscribe(subscriber)
    end
  end

  def fixture_for(fixture_name, date)
    @fixture_for ||= {}
    fixture_path = Rails.root.join("spec/fixtures/routes/search/#{fixture_name}/#{date.iso8601}.json")

    @fixture_for[[ fixture_name, date ]] ||= JSON.parse(
      fixture_path.exist? ? fixture_path.read : "[]",
      symbolize_names: true
    )
  end

  def expected_routes(origin_iata, destination_iata, departure_from, departure_to)
    fixture_name = "#{origin_iata}_#{destination_iata}".downcase

    (departure_from..departure_to).flat_map do |date|
      fixture_for(fixture_name, date)
    end
  end

  def present_routes(routes)
    presenter = Api::V1::Routes::RoutePresenter.new

    routes.map { |route| presenter.call(route) }
  end
end
