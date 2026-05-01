# frozen_string_literal: true

require "rails_helper"

RSpec.describe HeartRateZone do
  subject(:zone) { build(:heart_rate_zone) }

  describe "associations" do
    it { is_expected.to belong_to(:user) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:zone_number) }
    it { is_expected.to validate_inclusion_of(:zone_number).in_range(1..5) }
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:min_bpm) }
    it { is_expected.to validate_numericality_of(:min_bpm).is_greater_than(0) }
    it { is_expected.to validate_presence_of(:max_bpm) }
    it { is_expected.to validate_numericality_of(:max_bpm).is_greater_than(0) }

    context "when max_bpm <= min_bpm" do
      before { zone.max_bpm = zone.min_bpm }

      it "is invalid" do
        expect(zone).not_to be_valid
        expect(zone.errors[:max_bpm]).to be_present
      end
    end

    context "with uniqueness scoped to user" do
      subject { create(:heart_rate_zone) }

      it { is_expected.to validate_uniqueness_of(:zone_number).scoped_to(:user_id) }
    end
  end

  describe ".generate_defaults" do
    let(:user) { create(:user, date_of_birth: 30.years.ago.to_date) }

    it "creates 5 zones" do
      expect { described_class.generate_defaults(user) }.to change(described_class, :count).by(5)
    end

    it "does not duplicate existing zones" do
      described_class.generate_defaults(user)
      expect { described_class.generate_defaults(user) }.not_to change(described_class, :count)
    end
  end
end
