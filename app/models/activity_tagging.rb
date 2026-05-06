# frozen_string_literal: true

class ActivityTagging < ApplicationRecord
  belongs_to :activity
  belongs_to :activity_tag

  validates :activity_tag_id, uniqueness: { scope: :activity_id }
end
