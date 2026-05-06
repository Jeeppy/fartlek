class AddTargetRpeToPlannedSessions < ActiveRecord::Migration[8.1]
  def change
    add_column :planned_sessions, :target_rpe, :integer
  end
end
