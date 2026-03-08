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
      payload = {
        from: mail[:from]&.to_s,
        to: mail[:to]&.to_s,
        cc: mail[:cc]&.to_s,
        bcc: mail[:bcc]&.to_s,
        subject: mail.subject&.to_s,
        attachments: build_attachments(mail)
      }

      if mail.multipart?
        payload[:body] = mail.text_part&.decoded
        payload[:html_body] = mail.html_part&.decoded
      else
        if mail.content_type =~ /html/
          payload[:html_body] = mail.body.decoded
        else
          payload[:body] = mail.body.decoded
        end
      end

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
      unless response.success?
        error_message = JSON.parse(response.body)["error"] rescue "Unknown API error"
        raise Error, "Enkimail API Error (#{response.status}): #{error_message}"
      end
      response
    end
  end
end
