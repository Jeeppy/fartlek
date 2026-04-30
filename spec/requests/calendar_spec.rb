# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Calendar" do
  let(:user) { create(:user) }

  before { login_as user }

  describe "GET /calendar" do
    it "renders the current month" do
      get calendar_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include(I18n.l(Date.current, format: "%B %Y").capitalize)
    end
  end

  describe "GET /calendar/:year/:month" do
    it "renders the specified month" do
      get month_calendar_path(2026, 1)
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Janvier 2026")
    end

    it "shows activities for the month" do
      create(:activity, user: user, title: "Run janvier",
                        performed_at: Time.zone.local(2026, 1, 15, 10, 0))
      get month_calendar_path(2026, 1)
      expect(response.body).to include("🏃")
    end
  end
end
