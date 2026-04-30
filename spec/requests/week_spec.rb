# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Weeks" do
  let(:user) { create(:user) }

  before { login_as user }

  describe "GET /weeks/:date" do
    it "renders the week view" do
      get week_path(date: Date.current.beginning_of_week)
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Semaine du")
    end

    it "shows summary by sport" do
      create(:activity, user: user, sport: :running,
                        performed_at: Date.current.beginning_of_week.to_time + 10.hours)
      create(:activity, :cycling, user: user,
                                  performed_at: Date.current.beginning_of_week.to_time + 14.hours)
      get week_path(date: Date.current.beginning_of_week)
      expect(response.body).to include("Course à pied")
      expect(response.body).to include("Vélo")
    end

    it "shows rest days" do
      get week_path(date: Date.current.beginning_of_week)
      expect(response.body).to include("Repos")
    end
  end
end
