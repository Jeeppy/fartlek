# frozen_string_literal: true

require "rails_helper"

RSpec.describe WeeklyJournal do
  subject(:journal) { build(:weekly_journal) }

  describe "associations" do
    it { is_expected.to belong_to(:user) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:week_start_date) }
    it { is_expected.to validate_inclusion_of(:pleasure).in_range(1..5).allow_nil }
    it { is_expected.to validate_inclusion_of(:difficulty).in_range(1..5).allow_nil }
    it { is_expected.to validate_inclusion_of(:fatigue).in_range(1..5).allow_nil }

    context "with uniqueness scoped to user" do
      subject { create(:weekly_journal) }

      it { is_expected.to validate_uniqueness_of(:week_start_date).scoped_to(:user_id) }
    end

    context "when week_start_date is not a monday" do
      before { journal.week_start_date = Date.new(2026, 4, 29) } # mercredi

      it "is invalid" do
        expect(journal).not_to be_valid
        expect(journal.errors[:week_start_date]).to be_present
      end
    end
  end
end
