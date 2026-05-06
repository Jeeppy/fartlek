# frozen_string_literal: true

class ActivityTag < ApplicationRecord
  belongs_to :user
  has_many :activity_taggings, dependent: :destroy
  has_many :activities, through: :activity_taggings

  validates :name, presence: true, uniqueness: { scope: :user_id }

  scope :ordered, -> { order(:name) }

  DEFAULTS = [
    { name: "Endurance fondamentale", color: "#22C55E" },
    { name: "Endurance active", color: "#84CC16" },
    { name: "Seuil", color: "#EAB308" },
    { name: "Allure spécifique", color: "#F97316" },
    { name: "VMA", color: "#EF4444" },
    { name: "Sortie longue", color: "#3B82F6" },
    { name: "Récupération", color: "#06B6D4" },
    { name: "Fractionné", color: "#DC2626" },
    { name: "Côtes", color: "#A855F7" },
    { name: "Fartlek", color: "#8B5CF6" },
    { name: "PPG", color: "#78716C" },
    { name: "Test", color: "#EC4899" }
  ].freeze

  def self.generate_defaults(user)
    DEFAULTS.each do |default|
      user.activity_tags.find_or_create_by!(name: default[:name]) do |tag|
        tag.color = default[:color]
      end
    end
  end
end
