# frozen_string_literal: true

module Ai
  class BaseService
    API_URL = "https://api.anthropic.com/v1/messages"
    MODEL = "claude-sonnet-4-20250514"

    class ApiError < StandardError; end

    def initialize
      # Base initializer for subclasses
    end

    private

    def call_api(system:, messages:, max_tokens: 2000)
      response = connection.post do |req|
        req.body = {
          model: MODEL,
          system: system,
          messages: messages,
          max_tokens: max_tokens
        }.to_json
      end

      parsed = JSON.parse(response.body)

      raise ApiError, "Claude API #{response.status}: #{parsed['error']&.dig('message')}" unless response.status == 200

      parsed.dig("content", 0, "text")
    end

    def load_prompt(name)
      Rails.root.join("config", "prompts", "#{name}.md").read
    end

    def connection
      @connection ||= Faraday.new(url: API_URL) do |f|
        f.headers["x-api-key"] = ENV.fetch("ANTHROPIC_API_KEY")
        f.headers["anthropic-version"] = "2023-06-01"
        f.headers["content-type"] = "application/json"
      end
    end
  end
end
