class AddCadenceAndPowerToActivityLaps < ActiveRecord::Migration[8.1]
  def change
    add_column :activity_laps, :average_cadence, :integer
    add_column :activity_laps, :average_power, :integer
  end
end
