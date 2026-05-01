# frozen_string_literal: true

class DailyJournalsController < ApplicationController
  before_action :set_journal, only: [:show, :edit, :update]

  def index
    @pagy, @journals = pagy(current_user.daily_journals.chronological)
  end

  def show; end

  def new
    date = params[:date]&.to_date || Date.current
    @journal = current_user.daily_journals.find_or_initialize_by(date: date)
  end

  def edit; end

  def create
    @journal = current_user.daily_journals.build(journal_params)

    if @journal.save
      redirect_to daily_journal_path(date: @journal.date), notice: "Journal enregistré."
    else
      render :new, status: :unprocessable_content
    end
  end

  def update
    if @journal.update(journal_params)
      redirect_to daily_journal_path(date: @journal.date), notice: "Journal mis à jour."
    else
      render :edit, status: :unprocessable_content
    end
  end

  private

  def set_journal
    @journal = current_user.daily_journals.find_by!(date: params[:date])
  end

  def journal_params
    params.require(:daily_journal).permit(:date, :mood, :sleep_quality, :sleep_hours, :fatigue, :soreness, :comment)
  end
end
