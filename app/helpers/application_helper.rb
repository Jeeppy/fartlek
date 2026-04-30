# frozen_string_literal: true

module ApplicationHelper
  def nav_link(text, path, **)
    is_active = current_page?(path)
    css = if is_active
            "inline-flex items-center border-b-2 border-indigo-400 px-1 pt-1 text-sm font-medium text-gray-100"
          else
            "inline-flex items-center border-b-2 border-transparent px-1 pt-1 text-sm font-medium text-gray-400 hover:border-gray-600 hover:text-gray-200"
          end

    link_to(text, path, class: css, **)
  end
end
