# frozen_string_literal: true

require "rails_helper"

RSpec.describe "DailyJournals" do
  let(:user) { create(:user) }

  before { login_as user }

  describe "GET /daily_journals" do
    it "renders the index" do
      get daily_journals_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /daily_journals/new" do
    it "renders the form" do
      get new_daily_journal_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /daily_journals" do
    it "creates a journal" do
      expect do
        post daily_journals_path, params: {
          daily_journal: { date: Date.current, mood: 4, sleep_quality: 4, sleep_hours: 7.5 }
        }
      end.to change(DailyJournal, :count).by(1)

      expect(response).to redirect_to(daily_journal_path(date: Date.current))
    end
  end

  describe "GET /daily_journals/:date" do
    it "shows the journal" do
      journal = create(:daily_journal, user: user)
      get daily_journal_path(date: journal.date)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "PATCH /daily_journals/:date" do
    it "updates the journal" do
      journal = create(:daily_journal, user: user)
      patch daily_journal_path(date: journal.date), params: { daily_journal: { mood: 5 } }
      expect(journal.reload.mood).to eq(5)
    end
  end
end
