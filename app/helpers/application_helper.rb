# frozen_string_literal: true

module ApplicationHelper
  include Pagy::Frontend

  def nav_link(text, path)
    active = current_page?(path) ||
             (text == "Planning" && request.path.include?("week")) ||
             (text == "Calendrier" && request.path.include?("calendar"))

    base = "px-3 py-1.5 rounded-lg text-sm font-medium transition"
    classes = if active
                "#{base} bg-gray-800 text-indigo-400"
              else
                "#{base} text-gray-400 hover:text-gray-200 hover:bg-gray-800"
              end

    link_to text, path, class: classes
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

  def render_markdown(text)
    return "" if text.blank?

    renderer = Redcarpet::Render::HTML.new(hard_wrap: true)
    markdown = Redcarpet::Markdown.new(renderer,
                                       autolink: true,
                                       tables: true,
                                       fenced_code_blocks: true,
                                       lax_spacing: true)
    sanitize(markdown.render(text))
  end
end
