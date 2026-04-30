# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Activities" do
  let(:user) { create(:user) }

  before { login_as user }

  describe "GET /activities" do
    it "lists user activities" do
      create(:activity, user: user, title: "Mon footing")
      get activities_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Mon footing")
    end

    it "does not show other users activities" do
      other = create(:user)
      create(:activity, user: other, title: "Pas le mien")
      get activities_path
      expect(response.body).not_to include("Pas le mien")
    end
  end

  describe "GET /activities/new" do
    it "renders the form" do
      get new_activity_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Nouvelle activité")
    end
  end

  describe "POST /activities" do
    let(:valid_params) do
      {
        activity: {
          sport: "running",
          title: "Footing",
          performed_at: Time.current,
          duration_seconds: 3600,
          distance_meters: 10_000
        }
      }
    end

    context "with valid params" do
      it "creates an activity and redirects" do
        expect do
          post activities_path, params: valid_params
        end.to change(Activity, :count).by(1)

        expect(response).to redirect_to(activity_path(Activity.last))
      end
    end

    context "with invalid params" do
      it "does not create and re-renders form" do
        expect do
          post activities_path, params: { activity: { sport: "", performed_at: "" } }
        end.not_to change(Activity, :count)

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe "GET /activities/:id" do
    it "shows the activity" do
      activity = create(:activity, user: user, title: "Tempo run")
      get activity_path(activity)
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Tempo run")
    end

    it "returns 404 for other users activity" do
      other_activity = create(:activity, user: create(:user))
      get activity_path(other_activity)
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "PATCH /activities/:id" do
    let(:activity) { create(:activity, user: user, title: "Old title") }

    it "updates the activity" do
      patch activity_path(activity), params: { activity: { title: "New title" } }
      expect(response).to redirect_to(activity_path(activity))
      expect(activity.reload.title).to eq("New title")
    end
  end

  describe "DELETE /activities/:id" do
    it "destroys the activity" do
      activity = create(:activity, user: user)
      expect do
        delete activity_path(activity)
      end.to change(Activity, :count).by(-1)

      expect(response).to redirect_to(activities_path)
    end
  end

  describe "PATCH /activities/:id/update_rpe" do
    it "updates the RPE" do
      activity = create(:activity, user: user, rpe: nil)
      patch update_rpe_activity_path(activity), params: { rpe: 7 }
      expect(response).to have_http_status(:ok)
      expect(activity.reload.rpe).to eq(7)
    end
  end
end
