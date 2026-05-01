# frozen_string_literal: true

require "rails_helper"

RSpec.describe "WeeklyJournals" do
  let(:user) { create(:user) }

  before { login_as user }

  describe "GET /weekly_journals" do
    it "renders the index" do
      get weekly_journals_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /weekly_journals" do
    it "creates a journal" do
      expect do
        post weekly_journals_path, params: {
          weekly_journal: { week_start_date: Date.current.beginning_of_week, pleasure: 4, difficulty: 3, fatigue: 2 }
        }
      end.to change(WeeklyJournal, :count).by(1)
    end
  end

  describe "GET /weekly_journals/:week" do
    it "shows the journal" do
      journal = create(:weekly_journal, user: user)
      get weekly_journal_path(week: journal.week_start_date)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "PATCH /weekly_journals/:week" do
    it "updates the journal" do
      journal = create(:weekly_journal, user: user)
      patch weekly_journal_path(week: journal.week_start_date), params: { weekly_journal: { pleasure: 5 } }
      expect(journal.reload.pleasure).to eq(5)
    end
  end
end
