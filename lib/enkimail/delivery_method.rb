# frozen_string_literal: true

require_relative "client"

module Enkimail
  class DeliveryMethod
    attr_accessor :settings

    def initialize(settings)
      @settings = settings
    end

    def deliver!(mail)
      validate_settings!
      client = Client.new(settings[:api_key], base_url: settings[:base_url])
      client.deliver(mail)
    end

    private

    def validate_settings!
      raise Error, "Enkimail API Key is missing. Please set config.action_mailer.enkimail_settings = { api_key: '...' }" if settings[:api_key].nil? || settings[:api_key].empty?
    end
  end
end
