# frozen_string_literal: true

module Ai
  class PlanningsController < ApplicationController
    def show
      @conversation = current_conversation
    end

    def create
      planner = ::Ai::WeekPlanner.new(current_user)

      begin
        planner.call(message: params[:message])
      rescue ::Ai::BaseService::ApiError => e
        flash[:alert] = "Erreur API : #{e.message}"
      end

      redirect_to ai_planning_path
    end

    def destroy
      current_conversation&.destroy
      redirect_to ai_planning_path, notice: t("notices.ai.conversation_reset")
    end

    private

    def current_conversation
      current_user.ai_conversations.find_by(
        conversation_type: :planning,
        week_start_date: Date.current.next_week
      )
    end
  end
end
