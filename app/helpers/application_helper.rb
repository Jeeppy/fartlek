# frozen_string_literal: true

module ApplicationHelper
  include Pagy::Frontend

  def nav_link(text, path, **)
    is_active = current_page?(path)
    css = if is_active
            "inline-flex items-center border-b-2 border-indigo-400 px-2 pt-1 text-sm font-medium text-gray-100"
          else
            "inline-flex items-center border-b-2 border-transparent px-2 pt-1 text-sm font-medium text-gray-400 hover:border-gray-600 hover:text-gray-200"
          end

    link_to(text, path, class: css, **)
  end

  def pagy_dark_nav(pagy)
    return "" if pagy.pages <= 1

    html = +""
    html << '<nav class="flex justify-center gap-1">'

    if pagy.prev
      html << link_to("←", url_for(page: pagy.prev),
                      class: "inline-flex items-center justify-center min-w-9 px-3 py-2 text-sm rounded-lg text-gray-400 bg-gray-900 ring-1 ring-gray-800 hover:bg-gray-800")
    end

    pagy.series.each do |item|
      case item
      when Integer
        html << link_to(item, url_for(page: item),
                        class: "inline-flex items-center justify-center min-w-9 px-3 py-2 text-sm rounded-lg text-gray-400 bg-gray-900 ring-1 ring-gray-800 hover:bg-gray-800")
      when String
        html << content_tag(:span, item,
                            class: "inline-flex items-center justify-center min-w-9 px-3 py-2 text-sm rounded-lg text-white bg-indigo-600 ring-1 ring-indigo-600 font-semibold")
      when :gap
        html << content_tag(:span, "…",
                            class: "inline-flex items-center justify-center min-w-9 px-3 py-2 text-sm text-gray-600")
      end
    end

    if pagy.next
      html << link_to("→", url_for(page: pagy.next),
                      class: "inline-flex items-center justify-center min-w-9 px-3 py-2 text-sm rounded-lg text-gray-400 bg-gray-900 ring-1 ring-gray-800 hover:bg-gray-800")
    end

    html << "</nav>"
    html.html_safe
  end

  def format_duration(seconds)
    return "0h00" unless seconds&.positive?

    hours = seconds / 3600
    minutes = (seconds % 3600) / 60
    format("%<h>dh%<m>02d", h: hours, m: minutes)
  end
end
