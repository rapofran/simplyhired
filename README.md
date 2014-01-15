# Simplyhired

TODO: Write a gem description

## Installation

Add this line to your application's Gemfile:

    gem 'simplyhired'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install simplyhired

## Usage

First you need to register with simplyhired as a publisher to use this gem. 
Go to http://www.simplyhired.com/a/publishers/overview

On simplyhired site; register, sign in and click on XML API tab. There you will find all your credentials. Make a note of pshid and jbd parameters.

create a config file and define these parameters:

in config/initializers/simplyhired.rb

    Simplyhired.configure do |config|
    	config.pshid = "your pshid here"
    	config.jbd = "your jbd here"
    end

Get jobs:

sh = Simplyhired::Client.new(ip_address) # "192.168.1.1"
jobs = sh.search_jobs(query_type, ["ruby", "ajax"], nil, "New York", 'NY', 15, 30)

## Contributing

1. Fork it ( http://github.com/<my-github-username>/simplyhired/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
