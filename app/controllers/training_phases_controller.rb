# frozen_string_literal: true

class TrainingPhasesController < ApplicationController
  before_action :set_phase, only: [:edit, :update, :destroy]

  def index
    @phases = current_user.training_phases.ordered
  end

  def new
    @phase = current_user.training_phases.build
  end

  def edit; end

  def create
    @phase = current_user.training_phases.build(phase_params)

    if @phase.save
      redirect_to training_phases_path, notice: "Phase créée."
    else
      render :new, status: :unprocessable_content
    end
  end

  def update
    if @phase.update(phase_params)
      redirect_to training_phases_path, notice: "Phase mise à jour."
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @phase.destroy
    redirect_to training_phases_path, notice: "Phase supprimée.", status: :see_other
  end

  private

  def set_phase
    @phase = current_user.training_phases.find(params[:id])
  end

  def phase_params
    params.expect(
      training_phase: [:name, :start_date, :end_date, :phase_type, :color, :description, :competition_id]
    )
  end
end
