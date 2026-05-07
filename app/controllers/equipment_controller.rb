# frozen_string_literal: true

class EquipmentController < ApplicationController
  before_action :set_equipment, only: [:show, :edit, :update, :destroy]

  def index
    @active = current_user.equipments.active.ordered
    @retired = current_user.equipments.retired.ordered
  end

  def show; end

  def new
    @equipment = current_user.equipments.build
  end

  def edit; end

  def create
    @equipment = current_user.equipments.build(equipment_params)

    if @equipment.save
      redirect_to equipment_index_path, notice: "Équipement ajouté."
    else
      render :new, status: :unprocessable_content
    end
  end

  def update
    if @equipment.update(equipment_params)
      redirect_to equipment_index_path, notice: "Équipement mis à jour."
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    @equipment.destroy
    redirect_to equipment_index_path, notice: "Équipement supprimé.", status: :see_other
  end

  private

  def set_equipment
    @equipment = current_user.equipments.find(params[:id])
  end

  def equipment_params
    params.expect(equipment: [:name, :equipment_type, :brand, :model,
                              :purchase_date, :initial_distance_meters,
                              :max_distance_meters, :retired, :notes])
  end
end
