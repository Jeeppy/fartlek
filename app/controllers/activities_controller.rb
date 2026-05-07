# frozen_string_literal: true

class ActivitiesController < ApplicationController
  before_action :set_activity, only: [:show, :edit, :update, :destroy, :update_rpe, :export_json, :show]
  def index
    @pagy, @activities = pagy(current_user.activities.includes(:activity_tags, :equipment).chronological)
  end

  def show
    @prev_activity = current_user.activities
                                 .where(performed_at: ...@activity.performed_at)
                                 .order(performed_at: :desc)
                                 .first
    @next_activity = current_user.activities
                                 .where("performed_at > ?", @activity.performed_at)
                                 .order(performed_at: :asc)
                                 .first
  end

  def new
    @activity = current_user.activities.build(performed_at: Time.current)
  end

  def edit; end

  def create
    @activity = current_user.activities.build(activity_params)

    if @activity.save
      link_planned_session
      redirect_to @activity, notice: "Activité créée."
    else
      render :new, status: :unprocessable_content
    end
  end

  def update
    if @activity.update(activity_params)
      link_planned_session
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

  def export_json
    data = Export::ActivityJsonExporter.new(@activity).call
    send_data data.to_json,
              filename: "activity_#{@activity.performed_at.to_date}.json",
              type: :json
  end

  private

  def set_activity
    @activity = current_user.activities.find(params[:id])
  end

  def activity_params
    params.expect(
      activity: [:sport, :title, :rpe, :notes, :equipment_id,
                 { activity_tag_ids: [] }]
    )
  end

  def link_planned_session
    planned_id = params[:planned_session_id]

    # Délier l'ancienne si changement
    @activity.planned_session&.update!(activity: nil, completed: false)

    return if planned_id.blank?

    planned = current_user.planned_sessions.find(planned_id)
    planned.update!(activity: @activity, completed: true)
    return unless @activity.title.blank? || @activity.title == @activity.strava_data&.dig("name")

    @activity.update!(title: planned.title)
  end
end
