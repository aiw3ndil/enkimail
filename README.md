# Enkimail Ruby Gem

[![Gem Version](https://badge.fury.io/rb/enkimail.svg)](https://badge.fury.io/rb/enkimail)

`enkimail` is the official gem for integrating [Enkimail](https://enkimail.com) transactional email service with Ruby on Rails. It allows you to send emails using Enkimail's infrastructure simply by configuring the ActionMailer `delivery_method`.

## Features

*   **Native Rails Integration:** Automatically registers as an ActionMailer delivery method.
*   **Multipart Support:** Automatically handles HTML and plain text email bodies.
*   **Attachments:** Built-in support for sending attachments (automatically Base64 encoded for the API).
*   **Flexible Configuration:** Allows defining a `base_url` for testing in development or staging environments.

## Installation

Add this line to your application's `Gemfile`:

```ruby
gem 'enkimail'
```

And then execute:

    $ bundle install

Or install it manually:

    $ gem install enkimail

## Prerequisites

Before using the gem, ensure that:
1.  **Verified Domain:** Your sending domain must be verified in the Enkimail dashboard.
2.  **Verified Sender:** The `from` email address you use must be a verified sender in your Enkimail account.

Emails sent from unverified domains or senders will be rejected by the API.

## Configuration in Rails

To use Enkimail as your email provider, edit your environment configuration file (e.g., `config/environments/production.rb`):

```ruby
Rails.application.configure do
  # ...
  config.action_mailer.delivery_method = :enkimail
  config.action_mailer.enkimail_settings = {
    api_key: ENV['ENKIMAIL_API_KEY']
  }

  # Optional: Configure a global 'from' address
  # This address MUST be a verified sender in your Enkimail dashboard.
  config.action_mailer.default_options = { from: 'no-reply@yourdomain.com' }
end
```

### Configuration Options

| Option | Description | Required |
| :--- | :--- | :--- |
| `api_key` | Your Enkimail API Key. | Yes |
| `base_url` | API base URL (defaults to `https://api.enkimail.com`). | No |

## Usage

You can set the `from` address globally in your `ApplicationMailer` or specifically in each mailer method. Remember that Enkimail requires the sender to be verified.

### Setting a Default Sender

```ruby
class ApplicationMailer < ActionMailer::Base
  default from: 'info@yourdomain.com'
  layout 'mailer'
end
```

### Overriding the Sender in a Specific Mailer

```ruby
class UserMailer < ApplicationMailer
  def welcome_email(user)
    @user = user
    mail(
      to: @user.email,
      subject: 'Welcome to Enkimail',
      from: 'onboarding@yourdomain.com' # Must be a verified sender
    )
  end
end
```

### Sending Attachments

The gem handles attachment processing automatically:

```ruby
def invoice_email(user, invoice_pdf)
  attachments['invoice.pdf'] = invoice_pdf
  mail(to: user.email, subject: 'Your Invoice')
end
```

## Local Development

If you are developing the Enkimail API locally and want to test the gem against your local Rails instance, you can configure the `base_url`:

```ruby
# config/environments/development.rb
config.action_mailer.delivery_method = :enkimail
config.action_mailer.enkimail_settings = {
  api_key: 'test_key',
  base_url: 'http://localhost:3000'
}
```

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
