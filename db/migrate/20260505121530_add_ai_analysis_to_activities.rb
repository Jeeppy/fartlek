# frozen_string_literal: true

class AddAiAnalysisToActivities < ActiveRecord::Migration[8.1]
  def change
    add_column :activities, :ai_analysis, :text
    add_column :activities, :ai_analyzed_at, :datetime
  end
end
