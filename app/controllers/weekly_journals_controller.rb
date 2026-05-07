# frozen_string_literal: true

class WeeklyJournalsController < ApplicationController
  before_action :set_journal, only: [:show, :edit, :update]

  def index
    @pagy, @journals = pagy(current_user.weekly_journals.chronological)
  end

  def show; end

  def new
    week = params[:week]&.to_date || Date.current.beginning_of_week
    @journal = current_user.weekly_journals.find_or_initialize_by(week_start_date: week)
  end

  def edit; end

  def create
    @journal = current_user.weekly_journals.build(journal_params)

    if @journal.save
      redirect_to week_path(date: @journal.week_start_date), notice: "Bilan enregistré."
    else
      render :new, status: :unprocessable_content
    end
  end

  def update
    if @journal.update(journal_params)
      redirect_to week_path(date: @journal.week_start_date), notice: "Bilan mis à jour."
    else
      render :edit, status: :unprocessable_content
    end
  end

  private

  def set_journal
    @journal = current_user.weekly_journals.find_by!(week_start_date: params[:week])
  end

  def journal_params
    params.expect(weekly_journal: [:week_start_date, :pleasure, :difficulty, :fatigue, :comment])
  end
end
