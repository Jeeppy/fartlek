# frozen_string_literal: true

module ActivityTagsHelper
  TAG_GROUPS = {
    "Endurance" => ["Endurance fondamentale", "Endurance active", "Sortie longue", "Récupération"],
    "Intensité" => ["Fractionné", "VMA", "Seuil", "Allure spécifique", "Fartlek"],
    "Autre" => ["Côtes", "PPG", "Test"]
  }.freeze

  def grouped_tags(tags)
    TAG_GROUPS.map do |group_name, tag_names|
      group_tags = tags.select { |t| tag_names.include?(t.name) }
      [group_name, group_tags]
    end.reject { |_, t| t.empty? }
  end
end
