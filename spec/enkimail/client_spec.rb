# frozen_string_literal: true

require "spec_helper"

RSpec.describe Enkimail::Client do
  let(:api_key) { "test_api_key" }
  let(:client) { described_class.new(api_key) }
  let(:mail) do
    Mail.new do
      from    "Sender Name <sender@example.com>"
      to      "Recipient Name <recipient@example.com>"
      subject "Test Subject"
      body    "Hello world"
      
      add_file filename: "test.txt", content: "test content"
    end
  end

  describe "#deliver" do
    let(:endpoint) { "https://api.enkimail.com/api/v1/transactional_emails" }

    before do
      stub_request(:post, endpoint)
        .with(
          headers: {
            "Authorization" => "Bearer #{api_key}",
            "Content-Type" => "application/json"
          }
        )
        .to_return(status: 200, body: { status: "success" }.to_json)
    end

    it "sends the correct payload to the API" do
      client.deliver(mail)

      expect(a_request(:post, endpoint).with { |req|
        payload = JSON.parse(req.body)
        expect(payload["from"]).to eq("Sender Name <sender@example.com>")
        expect(payload["to"]).to eq("Recipient Name <recipient@example.com>")
        expect(payload["subject"]).to eq("Test Subject")
        expect(payload["text"]).to eq("Hello world")
        expect(payload["attachments"]).to be_an(Array)
        expect(payload["attachments"].first["name"]).to eq("test.txt")
        expect(payload["attachments"].first["content"]).to eq([ "test content" ].pack("m0"))
        expect(payload["attachments"].first["content_type"]).to eq("text/plain")
      }).to have_been_made.once
    end

    it "handles API errors correctly" do
      stub_request(:post, endpoint).to_return(
        status: 401,
        body: { error: "Invalid API Key" }.to_json
      )

      expect {
        client.deliver(mail)
      }.to raise_error(Enkimail::Error, /Invalid API Key/)
    end
  end
end
