# frozen_string_literal: true

require "faraday"
require "json"

module Enkimail
  class Client
    DEFAULT_BASE_URL = "https://api.enkimail.com"

    attr_reader :api_key, :base_url

    def initialize(api_key, base_url: nil)
      @api_key = api_key
      @base_url = base_url || DEFAULT_BASE_URL
    end

    def deliver(mail)
      response = connection.post("/api/v1/transactional_emails") do |req|
        req.body = build_payload(mail).to_json
      end

      handle_response(response)
    end

    private

    def connection
      @connection ||= Faraday.new(url: base_url) do |conn|
        conn.request :json
        conn.headers["Authorization"] = "Bearer #{api_key}"
        conn.headers["Content-Type"] = "application/json"
        conn.adapter Faraday.default_adapter
      end
    end

    def build_payload(mail)
      {
        from: mail.from&.first,
        to: mail.to,
        cc: mail.cc,
        bcc: mail.bcc,
        subject: mail.subject,
        text: mail.text_part&.body&.decoded || (mail.multipart? ? nil : mail.body&.decoded),
        html: mail.html_part&.body&.decoded,
        attachments: build_attachments(mail)
      }.compact
    end

    def build_attachments(mail)
      return nil unless mail.attachments.any?

      mail.attachments.map do |attachment|
        {
          name: attachment.filename,
          content: [attachment.body.decoded].pack("m0"), # Base64
          content_type: attachment.content_type.split(";").first
        }
      end
    end

    def handle_response(response)
      unless response.success?
        error_message = JSON.parse(response.body)["error"] rescue "Unknown API error"
        raise Error, "Enkimail API Error (#{response.status}): #{error_message}"
      end
      response
    end
  end
end
