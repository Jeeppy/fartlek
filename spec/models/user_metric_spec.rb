# frozen_string_literal: true

require "rails_helper"

RSpec.describe UserMetric do
  subject(:metric) { build(:user_metric) }

  describe "associations" do
    it { is_expected.to belong_to(:user) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:recorded_on) }
    it { is_expected.to validate_presence_of(:metric_type) }
    it { is_expected.to validate_presence_of(:value) }
    it { is_expected.to validate_numericality_of(:value).is_greater_than(0) }
    it { is_expected.to validate_presence_of(:unit) }

    it do
      expect(subject).to define_enum_for(:metric_type)
        .with_values(weight: 0, resting_hr: 1, vma_test: 2, vo2max: 3, body_fat: 4)
    end
  end

  describe "scopes" do
    let(:user) { create(:user) }

    describe ".by_type" do
      it "filters by metric type" do
        weight = create(:user_metric, user: user, metric_type: :weight)
        create(:user_metric, :resting_hr, user: user, recorded_on: 1.day.ago)
        expect(described_class.by_type(:weight)).to eq([weight])
      end
    end

    describe ".chronological" do
      it "orders by date ascending" do
        old = create(:user_metric, user: user, recorded_on: 1.week.ago)
        recent = create(:user_metric, user: user, recorded_on: Date.current)
        expect(described_class.chronological).to eq([old, recent])
      end
    end
  end

  describe ".default_unit" do
    it "returns kg for weight" do
      expect(described_class.default_unit(:weight)).to eq("kg")
    end

    it "returns bpm for resting_hr" do
      expect(described_class.default_unit(:resting_hr)).to eq("bpm")
    end
  end
end
