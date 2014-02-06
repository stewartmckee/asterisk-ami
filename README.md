# Asterisk::Ami

Asterisk Websocket to AMI proxy.

## Installation

Add this line to your application's Gemfile:

    gem 'asterisk-ami'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install asterisk-ami

## Usage

Run the ami proxy from the command line with the following command changing the ami_* parameters with your access details for asterisk.

    $ bundle exec asterisk-ami localhost 8088 ami_user ami_password ami_host

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
