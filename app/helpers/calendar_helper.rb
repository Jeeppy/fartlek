# frozen_string_literal: true

module CalendarHelper
  def day_intensity(activities)
    return :rest if activities.empty?

    tags = activities.flat_map { |a| a.activity_tags.map(&:name) }
    if tags.any? { |t| ["Seuil", "VMA", "Fractionné"].include?(t) }
      :hard
    elsif tags.any? { |t| ["Endurance fondamentale", "Récupération", "Sortie longue"].include?(t) }
      :easy
    else
      :moderate
    end
  end

  def intensity_dot(intensity)
    case intensity
    when :hard then "bg-red-500"
    when :moderate then "bg-orange-500"
    when :easy then "bg-green-500"
    else "bg-gray-600"
    end
  end

  def cell_classes(in_month, today, intensity, phase)
    classes = []

    if today
      classes << "bg-gray-800 ring-1 ring-indigo-500"
    elsif !in_month
      classes << "bg-gray-950 opacity-40"
    elsif phase
      classes << "ring-1 ring-gray-800"
      classes << "bg-gray-900"
    else
      classes << "bg-gray-900 ring-1 ring-gray-800"
    end

    # Bordure gauche intensité
    case intensity
    when :hard
      classes << "border-l-2 border-l-red-500"
    when :moderate
      classes << "border-l-2 border-l-orange-500"
    when :easy
      classes << "border-l-2 border-l-green-500"
    end

    classes.join(" ")
  end

  def activity_text_color(activity)
    tags = activity.activity_tags.map(&:name)
    if tags.any? { |t| ["Seuil", "VMA", "Fractionné"].include?(t) }
      "text-red-300"
    elsif tags.any? { |t| ["Sortie longue"].include?(t) }
      "text-blue-300"
    elsif tags.any? { |t| ["Endurance fondamentale", "Récupération"].include?(t) }
      "text-green-300"
    else
      "text-gray-300"
    end
  end
end
