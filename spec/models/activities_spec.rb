# frozen_string_literal: true

require "rails_helper"

RSpec.describe Activity do
  subject(:activity) { build(:activity) }

  # ─── Associations ─────────────────────────────────────
  describe "associations" do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to have_many(:activity_laps).dependent(:destroy) }
  end

  # ─── Enums ────────────────────────────────────────────
  describe "enums" do
    it { is_expected.to define_enum_for(:sport).with_values(running: 0, cycling: 1, walking: 2, swimming: 3, ppg: 4) }
    it { is_expected.to define_enum_for(:feeling).with_values(terrible: 0, bad: 1, ok: 2, good: 3, great: 4) }
  end

  # ─── Validations ──────────────────────────────────────
  describe "validations" do
    it { is_expected.to validate_presence_of(:sport) }
    it { is_expected.to validate_presence_of(:performed_at) }
    it { is_expected.to validate_inclusion_of(:rpe).in_range(1..10).allow_nil }
    it { is_expected.to validate_numericality_of(:duration_seconds).is_greater_than(0).allow_nil }
    it { is_expected.to validate_numericality_of(:distance_meters).is_greater_than(0).allow_nil }

    context "with strava_id uniqueness" do
      subject { create(:activity, :with_strava) }

      it { is_expected.to validate_uniqueness_of(:strava_id).allow_nil }
    end
  end

  # ─── Scopes ───────────────────────────────────────────
  describe "scopes" do
    let(:user) { create(:user) }

    describe ".chronological" do
      it "orders by performed_at desc" do
        old = create(:activity, user: user, performed_at: 2.days.ago)
        recent = create(:activity, user: user, performed_at: 1.hour.ago)
        expect(described_class.chronological).to eq([recent, old])
      end
    end

    describe ".by_sport" do
      it "filters by sport" do
        run = create(:activity, user: user, sport: :running)
        create(:activity, :cycling, user: user)
        expect(described_class.by_sport(:running)).to eq([run])
      end
    end

    describe ".for_week" do
      it "returns activities within the given week" do
        this_week = create(:activity, user: user, performed_at: Time.current)
        create(:activity, user: user, performed_at: 2.weeks.ago)
        expect(described_class.for_week(Date.current)).to eq([this_week])
      end
    end

    describe ".for_month" do
      it "returns activities within the given month" do
        this_month = create(:activity, user: user, performed_at: Time.current)
        create(:activity, user: user, performed_at: 2.months.ago)
        expect(described_class.for_month(Date.current)).to eq([this_month])
      end
    end
  end

  # ─── Instance methods ─────────────────────────────────
  describe "#distance_km" do
    it "converts meters to km" do
      expect(activity.distance_km).to eq(10.0)
    end

    it "returns nil when distance_meters is nil" do
      activity.distance_meters = nil
      expect(activity.distance_km).to be_nil
    end
  end

  describe "#duration_formatted" do
    it "formats with hours" do
      activity.duration_seconds = 3661
      expect(activity.duration_formatted).to eq("1h01")
    end

    it "formats without hours" do
      activity.duration_seconds = 1830
      expect(activity.duration_formatted).to eq("30:30")
    end

    it "returns nil when duration_seconds is nil" do
      activity.duration_seconds = nil
      expect(activity.duration_formatted).to be_nil
    end
  end

  describe "#pace_formatted" do
    it "formats pace as min:sec /km" do
      activity.average_pace_seconds_per_km = 330
      expect(activity.pace_formatted).to eq("5:30 /km")
    end

    it "returns nil when pace is nil" do
      activity.average_pace_seconds_per_km = nil
      expect(activity.pace_formatted).to be_nil
    end
  end

  describe "#sport_icon" do
    it "returns emoji for each sport" do
      expect(build(:activity, sport: :running).sport_icon).to eq("🏃")
      expect(build(:activity, sport: :cycling).sport_icon).to eq("🚴")
      expect(build(:activity, sport: :ppg).sport_icon).to eq("💪")
    end
  end

  describe "#from_strava?" do
    it "returns true when strava_id is present" do
      expect(build(:activity, :with_strava)).to be_from_strava
    end

    it "returns false when strava_id is nil" do
      expect(activity).not_to be_from_strava
    end
  end
end
