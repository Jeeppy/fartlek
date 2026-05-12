# frozen_string_literal: true

class UserMetricsController < ApplicationController
  before_action :set_metric, only: [:edit, :update, :destroy]

  def index
    @metric_type = params[:type] || "weight"
    @metrics = current_user.user_metrics.by_type(@metric_type).chronological
    @latest = current_user.user_metrics.by_type(@metric_type).recent_first.first
  end

  def new
    @metric = current_user.user_metrics.build(
      recorded_on: Date.current,
      metric_type: params[:type] || "weight"
    )
    @metric.unit = UserMetric.default_unit(@metric.metric_type)
  end

  def edit; end

  def create
    @metric = current_user.user_metrics.build(metric_params)
    @metric.unit ||= UserMetric.default_unit(@metric.metric_type)

    if @metric.save
      redirect_to user_metrics_path(type: @metric.metric_type), notice: t("notices.user_metrics.created")
    else
      render :new, status: :unprocessable_content
    end
  end

  def update
    if @metric.update(metric_params)
      redirect_to user_metrics_path(type: @metric.metric_type), notice: t("notices.user_metrics.updated")
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    type = @metric.metric_type
    @metric.destroy
    redirect_to user_metrics_path(type: type), notice: t("notices.user_metrics.destroyed"), status: :see_other
  end

  private

  def set_metric
    @metric = current_user.user_metrics.find(params[:id])
  end

  def metric_params
    params.expect(user_metric: [:recorded_on, :metric_type, :value, :unit, :notes])
  end
end
