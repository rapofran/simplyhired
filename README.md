# Simplyhired

Wrapper for Simplyhired XML API.

## Installation

Add this line to your application's Gemfile:

    gem 'simplyhired'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install simplyhired

## Usage

First you need to register with simplyhired as a publisher.

create a config file and define these parameters:

in config/initializers/simplyhired.rb

    Simplyhired.configure do |config|
    	config.pshid = "your pshid here"
    	config.jbd = "your jbd here"
    end

Get jobs:

sh = Simplyhired::Client.new(ip_address) # "192.168.1.1"
jobs = sh.search_jobs(["ruby", "ajax"], nil, "New York", 'NY', distance: 15, days: 30)

search_jobs parameters:

keywords(array), zipcode, city, state, options

available options:

distance: in miles
days: specify 0 for posted anytime
ws: number of jobs per page
page: page number
query_type:  :OR | :AND | :PHRASE

1. Fork it ( http://github.com/murtyk/simplyhired/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
