# frozen_string_literal: true

class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?

  private

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up,
                                      keys: [:first_name, :last_name, :gender, :date_of_birth])
    devise_parameter_sanitizer.permit(:account_update,
                                      keys: [:first_name, :last_name, :gender, :date_of_birth, :time_zone])
  end
end
