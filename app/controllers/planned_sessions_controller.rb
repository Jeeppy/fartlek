# frozen_string_literal: true

class PlannedSessionsController < ApplicationController
  before_action :set_session, only: [:show, :edit, :update, :destroy, :complete]

  def show
    render layout: false
  end

  def new
    @planned_session = current_user.planned_sessions.build(
      date: params[:date] || Date.current,
      sport: :running
    )
  end

  def edit; end

  def create
    @planned_session = current_user.planned_sessions.build(session_params)

    if @planned_session.save
      redirect_to week_path(date: @planned_session.date.beginning_of_week), notice: "Séance planifiée."
    else
      render :new, status: :unprocessable_content
    end
  end

  def update
    if @planned_session.update(session_params)
      redirect_to week_path(date: @planned_session.date.beginning_of_week), notice: "Séance mise à jour."
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    week = @planned_session.date.beginning_of_week
    @planned_session.destroy
    redirect_to week_path(date: week), notice: "Séance supprimée.", status: :see_other
  end

  def complete
    @planned_session.update!(completed: true)
    redirect_to week_path(date: @planned_session.date.beginning_of_week), notice: "Séance marquée comme faite."
  end

  private

  def set_session
    @planned_session = current_user.planned_sessions.find(params[:id])
  end

  def session_params
    params.require(:planned_session).permit(
      :date, :sport, :title, :description,
      :target_duration_seconds, :target_distance_meters,
      :target_pace_seconds_per_km, :target_rpe
    )
  end
end
