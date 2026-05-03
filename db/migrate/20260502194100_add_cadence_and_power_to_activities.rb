class AddCadenceAndPowerToActivities < ActiveRecord::Migration[8.1]
  def change
    add_column :activities, :average_cadence, :integer
    add_column :activities, :average_power, :integer
  end
end
