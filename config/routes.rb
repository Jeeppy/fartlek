# frozen_string_literal: true

require "sidekiq/web"

Rails.application.routes.draw do
  devise_for :users, controllers: {
    sessions: "users/sessions",
    registrations: "users/registrations"
  }

  authenticate :user, ->(u) { u.admin? } do
    mount Sidekiq::Web => "/sidekiq"
  end

  resource :calendar, only: [:show], controller: "calendar" do
    get ":year/:month", action: :show, as: :month,
                        constraints: { year: /\d{4}/, month: /\d{1,2}/ }
  end
  resources :weeks, only: [:show], param: :date, controller: "weeks"
  resources :equipment

  namespace :strava do
    get "callback", to: "callbacks#create"
    post "webhooks", to: "webhooks#create"
    get "webhooks", to: "webhooks#verify", as: :webhooks_verify
  end

  namespace :settings do
    resource :profile, only: [:show, :edit, :update]
    resources :heart_rate_zones, only: [:index, :update, :edit]
    resources :pace_zones, only: [:index, :update, :edit]
    resource :strava, only: [:show, :destroy], controller: "strava" do
      post :sync
    end
    post "heart_rate_zones/generate", to: "heart_rate_zones#generate", as: :generate_heart_rate_zones
    post "pace_zones/generate", to: "pace_zones#generate", as: :generate_pace_zones
  end

  resources :user_metrics
  resources :daily_journals, param: :date
  resources :weekly_journals, param: :week

  resources :activities do
    member do
      patch :update_rpe
    end
  end

  get "up" => "rails/health#show", as: :rails_health_check

  authenticated :user do
    root "dashboard#show", as: :authenticated_root
  end

  devise_scope :user do
    root to: "devise/sessions#new"
  end
end
