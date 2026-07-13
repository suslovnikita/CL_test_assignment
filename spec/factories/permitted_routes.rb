# frozen_string_literal: true

FactoryBot.define do
  factory :permitted_route do
    sequence(:carrier) { |index| "C#{index}" }
    origin_iata { "AAA" }
    destination_iata { "BBB" }
    direct { true }
    transfer_iata_codes { [] }
  end
end
