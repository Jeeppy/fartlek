# frozen_string_literal: true

module Strava
  class WebhooksController < ApplicationController
    skip_before_action :authenticate_user!
    skip_before_action :verify_authenticity_token, only: [:create]

    def verify
      challenge = params["hub.challenge"]
      if challenge
        render json: { "hub.challenge": challenge }
      else
        head :bad_request
      end
    end

    def create
      object_type = params[:object_type]
      aspect_type = params[:aspect_type]
      object_id = params[:object_id]
      owner_id = params[:owner_id]

      if object_type == "activity" && aspect_type == "create"
        credential = StravaCredential.find_by(strava_athlete_id: owner_id)
        StravaActivityImportJob.perform_later(credential.user_id, object_id) if credential
      end
      head :ok
    end
  end
end
