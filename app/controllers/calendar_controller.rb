# frozen_string_literal: true

class CalendarController < ApplicationController
  def show
    @date = if params[:year] && params[:month]
              Date.new(params[:year].to_i, params[:month].to_i, 1)
            else
              Date.current
            end

    @activities = current_user.activities
                              .for_month(@date)
                              .group_by { |a| a.performed_at.to_date }

    @prev_month = @date - 1.month
    @next_month = @date + 1.month
  end
end
