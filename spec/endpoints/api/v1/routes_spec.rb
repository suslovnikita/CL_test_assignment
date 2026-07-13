# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Api::V1::Routes", type: :request do
  describe "GET /api/v1/routes" do
    it "returns available routes" do
      get "/api/v1/routes", params: {
        carrier: "S7",
        origin_iata: "UUS",
        destination_iata: "DME",
        departure_from: "2024-01-05",
        departure_to: "2024-01-05"
      }

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body).to eq(
        JSON.parse(Rails.root.join("spec/fixtures/routes/search/uus_dme/2024-01-05.json").read)
      )
    end

    it "returns an empty array when no routes are found" do
      get "/api/v1/routes", params: {
        carrier: "S7",
        origin_iata: "UUS",
        destination_iata: "ZZZ",
        departure_from: "2024-01-01",
        departure_to: "2024-01-07"
      }

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body).to eq([])
    end

    it "ignores unexpected params" do
      get "/api/v1/routes", params: {
        carrier: "S7",
        origin_iata: "UUS",
        destination_iata: "DME",
        departure_from: "2024-01-05",
        departure_to: "2024-01-05",
        unexpected: "value"
      }

      expect(response).to have_http_status(:ok)
      expect(response.parsed_body).to eq(
        JSON.parse(Rails.root.join("spec/fixtures/routes/search/uus_dme/2024-01-05.json").read)
      )
    end

    it "returns an error when required params are missing" do
      get "/api/v1/routes", params: {
        carrier: "S7",
        origin_iata: "UUS",
        destination_iata: "DME",
        departure_from: "2024-01-01"
      }

      expect(response).to have_http_status(:bad_request)
      expect(response.parsed_body).to eq("error" => "Departure to can't be blank")
    end

    it "returns an error when dates are invalid" do
      get "/api/v1/routes", params: {
        carrier: "S7",
        origin_iata: "UUS",
        destination_iata: "DME",
        departure_from: "2024-99-01",
        departure_to: "2024-01-07"
      }

      expect(response).to have_http_status(:bad_request)
      expect(response.parsed_body).to eq("error" => "Departure from is invalid")
    end

    it "returns an error when departure dates range is invalid" do
      get "/api/v1/routes", params: {
        carrier: "S7",
        origin_iata: "UUS",
        destination_iata: "DME",
        departure_from: "2024-01-07",
        departure_to: "2024-01-01"
      }

      expect(response).to have_http_status(:bad_request)
      expect(response.parsed_body).to eq("error" => "Departure to must be greater than or equal to departure_from")
    end

    it "returns an error when IATA params are invalid" do
      get "/api/v1/routes", params: {
        carrier: "S7",
        origin_iata: "UU",
        destination_iata: "dme",
        departure_from: "2024-01-01",
        departure_to: "2024-01-07"
      }

      expect(response).to have_http_status(:bad_request)
      expect(response.parsed_body).to eq(
        "error" => "Origin iata is invalid and Destination iata is invalid"
      )
    end
  end
end
