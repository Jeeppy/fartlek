# frozen_string_literal: true

require "rails_helper"

RSpec.describe Analytics::VolumeComparison do
  let(:user) { create(:user) }

  describe "#call" do
    it "returns current and previous period data" do
      create(:activity, user: user, performed_at: Time.current, distance_meters: 10_000)
      result = described_class.new(user, period: :month).call
      expect(result[:current][:distance_km]).to eq(10.0)
      expect(result[:current][:count]).to eq(1)
    end

    it "calculates delta percentages" do
      create(:activity, user: user, performed_at: Time.current, distance_meters: 20_000)
      create(:activity, user: user, performed_at: 1.year.ago, distance_meters: 10_000)
      result = described_class.new(user, period: :month).call
      expect(result[:delta][:distance_km]).to eq(100.0)
    end

    it "handles zero previous gracefully" do
      create(:activity, user: user, performed_at: Time.current, distance_meters: 10_000)
      result = described_class.new(user, period: :month).call
      expect(result[:delta][:distance_km]).to eq(0)
    end
  end
end
