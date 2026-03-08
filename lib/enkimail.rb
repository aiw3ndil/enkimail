# frozen_string_literal: true

require_relative "enkimail/version"
require_relative "enkimail/client"
require_relative "enkimail/delivery_method"

module Enkimail
  class Error < StandardError; end

  # Rails integration
  if defined?(ActionMailer)
    ActionMailer::Base.add_delivery_method :enkimail, Enkimail::DeliveryMethod
  end
end
