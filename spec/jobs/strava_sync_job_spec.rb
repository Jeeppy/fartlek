# frozen_string_literal: true

require "rails_helper"

RSpec.describe StravaSyncJob do
  describe "#perform" do
    context "with valid user and credential" do
      let(:user) do
        user = create(:user)
        create(:strava_credential, user: user)

        user
      end

      it "calls Strava::SyncService" do
        service = instance_double(Strava::SyncService, call: true)
        allow(Strava::SyncService).to receive(:new).with(user).and_return(service)

        described_class.new.perform(user.id)
        expect(service).to have_received(:call)
      end
    end

    context "when user has no Strava credential" do
      let(:user) { create(:user) }

      it "does nothing when user has no Strava credential" do
        expect { described_class.new.perform(user.id) }.not_to raise_error
      end
    end
  end
end
