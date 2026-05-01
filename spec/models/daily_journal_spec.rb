# frozen_string_literal: true

require "rails_helper"

RSpec.describe DailyJournal do
  subject(:journal) { build(:daily_journal) }

  describe "associations" do
    it { is_expected.to belong_to(:user) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:date) }
    it { is_expected.to validate_inclusion_of(:mood).in_range(1..5).allow_nil }
    it { is_expected.to validate_inclusion_of(:sleep_quality).in_range(1..5).allow_nil }
    it { is_expected.to validate_inclusion_of(:fatigue).in_range(1..5).allow_nil }
    it { is_expected.to validate_inclusion_of(:soreness).in_range(1..5).allow_nil }

    context "with uniqueness scoped to user" do
      subject { create(:daily_journal) }

      it { is_expected.to validate_uniqueness_of(:date).scoped_to(:user_id) }
    end
  end

  describe "#mood_emoji" do
    it "returns emoji for mood" do
      journal.mood = 5
      expect(journal.mood_emoji).to eq("😄")
    end

    it "returns nil for nil mood" do
      journal.mood = nil
      expect(journal.mood_emoji).to be_nil
    end
  end
end
