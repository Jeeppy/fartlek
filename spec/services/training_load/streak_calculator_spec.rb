# frozen_string_literal: true

require "rails_helper"

RSpec.describe Analytics::StreakCalculator do
  let(:user) { create(:user) }

  describe "#call" do
    it "returns 0 when no activities" do
      expect(described_class.new(user).call).to eq(0)
    end

    it "returns 1 when activity today only" do
      create(:activity, user: user, performed_at: Time.current)
      expect(described_class.new(user).call).to eq(1)
    end

    it "counts consecutive days" do
      create(:activity, user: user, performed_at: Time.current)
      create(:activity, user: user, performed_at: 1.day.ago)
      create(:activity, user: user, performed_at: 2.days.ago)
      expect(described_class.new(user).call).to eq(3)
    end

    it "breaks streak on gap" do
      create(:activity, user: user, performed_at: Time.current)
      create(:activity, user: user, performed_at: 2.days.ago)
      expect(described_class.new(user).call).to eq(1)
    end

    it "starts from yesterday if no activity today" do
      create(:activity, user: user, performed_at: 1.day.ago)
      create(:activity, user: user, performed_at: 2.days.ago)
      expect(described_class.new(user).call).to eq(2)
    end
  end
end
