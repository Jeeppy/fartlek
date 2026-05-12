# frozen_string_literal: true

class ActivityTagsController < ApplicationController
  def index
    @tags = current_user.activity_tags.ordered
  end

  def generate
    ActivityTag.generate_defaults(current_user)
    redirect_to activity_tags_path, notice: t("notices.activity_tags.generated")
  end
end
