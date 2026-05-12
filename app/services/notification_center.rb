# frozen_string_literal: true

# Generates contextual notifications from user data.
class NotificationCenter
  def initialize(user)
    @user = user
  end

  def call
    [
      *equipment_warnings,
      *today_sessions,
      *recent_activities,
      *upcoming_competitions
    ].compact
  end

  private

  def equipment_warnings
    @user.equipments.active.filter_map do |eq|
      next unless eq.usage_percent&.>= 80

      {
        type: :warning,
        icon: "👟",
        title: "#{eq.name} approche de la fin",
        body: "#{eq.usage_percent}% d'usure — #{eq.total_distance_km} km",
        link: equipment_path(eq)
      }
    end
  end

  def today_sessions
    sessions = @user.planned_sessions.for_date(Date.current).where(completed: false)
    sessions.map do |session|
      {
        type: :info,
        icon: session.sport_icon,
        title: "Séance aujourd'hui",
        body: "#{session.title} — #{session.target_duration_formatted}",
        link: planned_session_path(session)
      }
    end
  end

  def recent_activities
    activity = @user.activities.chronological.first
    return [] unless activity && activity.performed_at >= 24.hours.ago && !activity.analyzed?

    [{
      type: :success,
      icon: activity.sport_icon,
      title: "Nouvelle activité importée",
      body: activity.title.presence || activity.sport.humanize,
      link: activity_path(activity)
    }]
  end

  def upcoming_competitions
    comp = @user.competitions.upcoming.first
    return [] unless comp && comp.days_until <= 14

    [{
      type: :info,
      icon: "🏁",
      title: "#{comp.name} dans #{comp.days_until} jours",
      body: comp.date.strftime("%d/%m/%Y"),
      link: competition_path(comp)
    }]
  end

  def equipment_path(eq)
    Rails.application.routes.url_helpers.equipment_path(eq)
  end

  def planned_session_path(session)
    Rails.application.routes.url_helpers.planned_session_path(session)
  end

  def activity_path(activity)
    Rails.application.routes.url_helpers.activity_path(activity)
  end

  def competition_path(comp)
    Rails.application.routes.url_helpers.competition_path(comp)
  end
end
