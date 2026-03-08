# frozen_string_literal: true

require "faraday"
require "json"

module Enkimail
  class Client
    DEFAULT_BASE_URL = "https://api.enkimail.com"

    attr_reader :api_key, :base_url

    def initialize(api_key, base_url: nil)
      @api_key = api_key
      @base_url = (base_url || DEFAULT_BASE_URL).chomp("/")
    end

    def deliver(mail)
      response = connection.post("/api/v1/transactional_emails") do |req|
        req.body = build_payload(mail)
      end

      handle_response(response)
    rescue Faraday::Error => e
      raise Error, "Enkimail Connection Error: #{e.message}"
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
      payload = {
        from: (mail.from || []).join(", "),
        to: (mail.to || []).join(", "),
        cc: (mail.cc || []).join(", "),
        bcc: (mail.bcc || []).join(", "),
        subject: mail.subject,
        attachments: build_attachments(mail)
      }

      if mail.multipart?
        payload[:body] = mail.text_part&.body&.decoded
        payload[:html_body] = mail.html_part&.body&.decoded
      else
        if mail.content_type =~ /html/
          payload[:html_body] = mail.body&.decoded
        else
          payload[:body] = mail.body&.decoded
        end
      end

      # Clean up nil values
      payload.compact
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
      return response if response.success?

      begin
        error_info = JSON.parse(response.body)
        error_message = error_info["error"] || error_info["errors"] || "Unknown API error"
      rescue JSON::ParserError
        error_message = "HTTP #{response.status}: #{response.body[0..100]}"
      end

      raise Error, "Enkimail API Error (#{response.status}): #{error_message}"
    end
  end
end
