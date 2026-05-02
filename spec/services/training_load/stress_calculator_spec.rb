# frozen_string_literal: true

require "rails_helper"

RSpec.describe TrainingLoad::StressCalculator do
  let(:user) { create(:user, gender: :male, date_of_birth: 30.years.ago.to_date) }
  let(:activity) { create(:activity, user: user, duration_seconds: 3600, average_heart_rate: 150) }

  describe "#call" do
    it "returns a TRIMP value" do
      result = described_class.new(activity, user).call
      expect(result).to be_a(Float)
      expect(result).to be > 0
    end

    it "returns nil without heart rate" do
      activity.average_heart_rate = nil
      expect(described_class.new(activity, user).call).to be_nil
    end

    it "returns nil without duration" do
      activity.duration_seconds = nil
      expect(described_class.new(activity, user).call).to be_nil
    end

    it "returns higher TRIMP for longer activities" do
      short = create(:activity, user: user, duration_seconds: 1800, average_heart_rate: 150)
      long = create(:activity, user: user, duration_seconds: 3600, average_heart_rate: 150)
      expect(described_class.new(long, user).call).to be > described_class.new(short, user).call
    end

    it "returns higher TRIMP for higher heart rate" do
      easy = create(:activity, user: user, duration_seconds: 3600, average_heart_rate: 120)
      hard = create(:activity, user: user, duration_seconds: 3600, average_heart_rate: 170)
      expect(described_class.new(hard, user).call).to be > described_class.new(easy, user).call
    end
  end
end
