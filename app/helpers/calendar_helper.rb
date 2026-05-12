# frozen_string_literal: true

module CalendarHelper
  QUALITY_TAGS = ["Seuil", "VMA", "Fractionné"].freeze
  EASY_TAGS = ["Endurance fondamentale", "Récupération", "Sortie longue"].freeze
  LONG_TAGS = ["Sortie longue"].freeze

  def day_intensity(activities)
    return :rest if activities.empty?

    tags = activities.flat_map { |act| act.activity_tags.map(&:name) }
    classify_intensity(tags)
  end

  def intensity_dot(intensity)
    { hard: "bg-red-500", moderate: "bg-orange-500", easy: "bg-green-500" }.fetch(intensity, "bg-gray-600")
  end

  def activity_text_color(activity)
    tags = activity.activity_tags.map(&:name)
    classify_tag_color(tags)
  end

  private

  def classify_intensity(tags)
    if tags.any? { |t| QUALITY_TAGS.include?(t) }
      :hard
    elsif tags.any? { |t| EASY_TAGS.include?(t) }
      :easy
    else
      :moderate
    end
  end

  def classify_tag_color(tags)
    if tags.any? { |t| QUALITY_TAGS.include?(t) }
      "text-red-300"
    elsif tags.any? { |t| LONG_TAGS.include?(t) }
      "text-blue-300"
    elsif tags.any? { |t| ["Endurance fondamentale", "Récupération"].include?(t) }
      "text-green-300"
    else
      "text-gray-300"
    end
  end
end
