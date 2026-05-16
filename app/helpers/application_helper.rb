# frozen_string_literal: true

module ApplicationHelper
  include Pagy::Frontend

  PAGE_LINK_CLASS = "inline-flex items-center justify-center min-w-9 px-3 py-2 " \
                    "text-sm rounded-lg text-gray-400 bg-gray-900 ring-1 ring-gray-800 hover:bg-gray-800"
  ACTIVE_PAGE_CLASS = "inline-flex items-center justify-center min-w-9 px-3 py-2 " \
                      "text-sm rounded-lg text-white bg-indigo-600 ring-1 ring-indigo-600 font-semibold"

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
    content_tag(:nav, class: "flex items-center gap-1") do
      safe_join([
                  build_prev_link(pagy),
                  *pagy.series.map { |item| build_page_item(item) },
                  build_next_link(pagy)
                ])
    end
  end

  def format_duration(seconds)
    return "0h00" unless seconds&.positive?

    hours = seconds / 3600
    minutes = (seconds % 3600) / 60
    format("%<h>dh%<m>02d", h: hours, m: minutes)
  end

  def render_markdown(text)
    return "" if text.blank?

    # Ajoute une ligne vide avant les listes si nécessaire
    processed = text.gsub(/([^\n])\n(\s*[-*+])/, "\\1\n\n\\2")

    renderer = Redcarpet::Render::HTML.new(hard_wrap: true)
    markdown = Redcarpet::Markdown.new(renderer,
                                       autolink: true,
                                       tables: true,
                                       fenced_code_blocks: true,
                                       lax_spacing: true)
    sanitize(markdown.render(processed))
  end

  def notifications
    @notifications ||= NotificationCenter.new(current_user).call
  end

  private

  def build_prev_link(pagy)
    return unless pagy.prev

    link_to("←", url_for(page: pagy.prev), class: PAGE_LINK_CLASS)
  end

  def build_next_link(pagy)
    return unless pagy.next

    link_to("→", url_for(page: pagy.next), class: PAGE_LINK_CLASS)
  end

  def build_page_links(pagy)
    safe_join(pagy.series.map { |item| build_page_item(item) })
  end

  def build_page_item(item)
    case item
    when Integer
      link_to(item, url_for(page: item), class: PAGE_LINK_CLASS)
    when String
      content_tag(:span, item, class: ACTIVE_PAGE_CLASS)
    when :gap
      content_tag(:span, "…", class: PAGE_LINK_CLASS)
    else
      ""
    end
  end
end
