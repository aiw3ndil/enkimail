# frozen_string_literal: true

require "spec_helper"

RSpec.describe Enkimail::DeliveryMethod do
  let(:settings) { { api_key: "abc_123" } }
  let(:delivery_method) { described_class.new(settings) }
  let(:mail) { Mail.new }

  describe "#deliver!" do
    it "initializes the client and calls deliver" do
      client_double = instance_double(Enkimail::Client)
      expect(Enkimail::Client).to receive(:new).with("abc_123", base_url: nil).and_return(client_double)
      expect(client_double).to receive(:deliver).with(mail)

      delivery_method.deliver!(mail)
    end

    it "raises error if api_key is missing" do
      bad_delivery = described_class.new({})
      expect {
        bad_delivery.deliver!(mail)
      }.to raise_error(Enkimail::Error, /API Key is missing/)
    end
  end
end
