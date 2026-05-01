# frozen_string_literal: true

require "rails_helper"

RSpec.describe "UserMetrics" do
  let(:user) { create(:user) }

  before { login_as user }

  describe "GET /user_metrics" do
    it "renders the index" do
      create(:user_metric, user: user)
      get user_metrics_path
      expect(response).to have_http_status(:ok)
    end

    it "filters by type" do
      create(:user_metric, user: user, metric_type: :weight)
      create(:user_metric, :resting_hr, user: user, recorded_on: 1.day.ago)
      get user_metrics_path(type: "resting_hr")
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("52")
    end
  end

  describe "POST /user_metrics" do
    it "creates a metric" do
      expect do
        post user_metrics_path, params: {
          user_metric: { metric_type: "weight", recorded_on: Date.current, value: 75.5, unit: "kg" }
        }
      end.to change(UserMetric, :count).by(1)

      expect(response).to redirect_to(user_metrics_path(type: "weight"))
    end
  end

  describe "PATCH /user_metrics/:id" do
    let(:metric) { create(:user_metric, user: user) }

    it "updates the metric" do
      patch user_metric_path(metric), params: { user_metric: { value: 74.0 } }
      expect(metric.reload.value).to eq(74.0)
    end
  end

  describe "DELETE /user_metrics/:id" do
    it "destroys the metric" do
      metric = create(:user_metric, user: user)
      expect do
        delete user_metric_path(metric)
      end.to change(UserMetric, :count).by(-1)
    end
  end
end
