# frozen_string_literal: true

FactoryBot.define do
  factory :segment do
    airline { "S7" }
    sequence(:segment_number) { |index| "S7-#{index}" }
    origin_iata { "AAA" }
    destination_iata { "BBB" }
    std { Time.utc(2024, 1, 1, 0) }
    sta { Time.utc(2024, 1, 1, 2) }
  end
end
