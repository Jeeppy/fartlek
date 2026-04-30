# frozen_string_literal: true

require "rails_helper"

RSpec.describe User do
  subject(:user) { build(:user) }

  # ─── Devise ───────────────────────────────────────────
  describe "devise modules" do
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_uniqueness_of(:email).case_insensitive }
    it { is_expected.to validate_presence_of(:password) }
  end

  # ─── Validations ──────────────────────────────────────
  describe "validations" do
    it { is_expected.to validate_presence_of(:first_name) }
    it { is_expected.to validate_length_of(:first_name).is_at_most(50) }
    it { is_expected.to validate_presence_of(:last_name) }
    it { is_expected.to validate_length_of(:last_name).is_at_most(50) }
    it { is_expected.to validate_presence_of(:gender) }
    it { is_expected.to validate_presence_of(:date_of_birth) }
    it { is_expected.to define_enum_for(:gender).with_values(male: 0, female: 1, other: 2) }

    context "when date_of_birth is in the future" do
      before { user.date_of_birth = 1.day.from_now.to_date }

      it "is invalid" do
        expect(user).not_to be_valid
        expect(user.errors[:date_of_birth]).to be_present
      end
    end

    context "when date_of_birth is today" do
      before { user.date_of_birth = Date.current }

      it { is_expected.not_to be_valid }
    end

    context "when date_of_birth is in the past" do
      before { user.date_of_birth = 25.years.ago.to_date }

      it { is_expected.to be_valid }
    end
  end

  # ─── Instance methods ─────────────────────────────────
  describe "#full_name" do
    it "returns first and last name" do
      user = build(:user, first_name: "Jean", last_name: "Dupont")
      expect(user.full_name).to eq("Jean Dupont")
    end
  end

  describe "#age" do
    it "calculates age from date of birth" do
      user = build(:user, date_of_birth: 30.years.ago.to_date)
      expect(user.age).to eq(30)
    end

    it "returns nil when date_of_birth is nil" do
      user.date_of_birth = nil
      expect(user.age).to be_nil
    end
  end

  describe "#admin?" do
    it "returns false by default" do
      expect(user).not_to be_admin
    end

    it "returns true for admin users" do
      expect(build(:user, :admin)).to be_admin
    end
  end
end
