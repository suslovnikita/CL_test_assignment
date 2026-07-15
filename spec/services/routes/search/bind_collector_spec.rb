# frozen_string_literal: true

require "rails_helper"

RSpec.describe Routes::Search::BindCollector do
  describe "#add" do
    it "reuses a placeholder for the same bind" do
      collector = described_class.new
      type = Segment.type_for_attribute("airline")

      first_placeholder = collector.add("s1_airline", "S7", type:)
      second_placeholder = collector.add("s1_airline", "S7", type:)

      expect(second_placeholder).to eq(first_placeholder)
      expect(collector.query_attributes.size).to eq(1)
    end

    it "raises when the same bind name has different attributes" do
      collector = described_class.new
      type = Segment.type_for_attribute("airline")
      collector.add("s1_airline", "S7", type:)

      expect do
        collector.add("s1_airline", "SU", type:)
      end.to raise_error(ArgumentError, 'Bind "s1_airline" is already registered with different attributes')
    end
  end
end
