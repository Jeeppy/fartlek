# frozen_string_literal: true

class CompetitionsController < ApplicationController
  before_action :set_competition, only: [:show, :edit, :update, :destroy]

  def index
    @upcoming = current_user.competitions.upcoming
    @past = current_user.competitions.past
  end

  def show; end

  def new
    @competition = current_user.competitions.build(date: Date.current)
  end

  def edit; end

  def create
    @competition = current_user.competitions.build(competition_params)

    if @competition.save
      redirect_to @competition, notice: t("notices.competitions.created")
    else
      render :new, status: :unprocessable_content
    end
  end

  def update
    if @competition.update(competition_params)
      redirect_to @competition, notice: t("notices.competitions.updated")
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @competition.destroy
    redirect_to competitions_path, notice: t("notices.competitions.destroyed"), status: :see_other
  end

  private

  def set_competition
    @competition = current_user.competitions.find(params[:id])
  end

  def competition_params
    params.expect(
      competition: [:name, :date, :priority, :sport, :location,
                    :target_distance_meters, :target_time_seconds, :target_pace_seconds_per_km,
                    :objectives, :notes,
                    :result_time_seconds, :result_pace_seconds_per_km, :result_position, :completed]
    )
  end
end
