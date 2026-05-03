# frozen_string_literal: true

class ActivitiesController < ApplicationController
  before_action :set_activity, only: [:show, :edit, :update, :destroy, :update_rpe]

  def index
    @pagy, @activities = pagy(current_user.activities.chronological)
  end

  def show; end

  def new
    @activity = current_user.activities.build(performed_at: Time.current)
  end

  def edit; end

  def create
    @activity = current_user.activities.build(activity_params)

    if @activity.save
      redirect_to @activity, notice: "Activité créée."
    else
      render :new, status: :unprocessable_content
    end
  end

  def update
    if @activity.update(activity_params)
      redirect_to @activity, notice: "Activité mise à jour."
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @activity.destroy
    redirect_to activities_path, notice: "Activité supprimée.", status: :see_other
  end

  def update_rpe
    if @activity.update(rpe: params[:rpe])
      head :ok
    else
      head :unprocessable_content
    end
  end

  private

  def set_activity
    @activity = current_user.activities.find(params[:id])
  end

  def activity_params
    params.require(:activity).permit(
      :sport, :title, :performed_at, :duration_seconds,
      :distance_meters, :elevation_gain_meters,
      :average_heart_rate, :max_heart_rate,
      :average_pace_seconds_per_km, :calories,
      :rpe, :feeling, :notes,
      :average_cadence, :average_power,
      :equipment_id
    )
  end
end
