require 'helper'

describe Simplyhired do

	it 'should have a version' do
		Simplyhired::VERSION.wont_be_nil	 
	end

	it "should provide appropriate error" do 
		Simplyhired.configure do |config|
        	# config.pshid = "49755"
			config.jbd = "mysite.jobamatic.com"
        end

        sh = Simplyhired::Client.new('50.19.85.132')
        jobs =  sh.search_jobs(["Rails", "Ajax"], nil, "New York", "NY", 10, 30)
        assert sh.error == 'define pshid in a configuration file'
		Simplyhired.configure do |config|
        	config.pshid = nil
			config.jbd = nil
        end
	end


	it "should find jobs" do

        stub_request(:get, /api.simplyhired.com.*pn-1.*/).with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).to_return(:status => 200, :body => File.new('test/pn-1.xml'), :headers => {})
        stub_request(:get, /api.simplyhired.com.*pn-2.*/).with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).to_return(:status => 200, :body => File.new('test/pn-2.xml'), :headers => {})
        stub_request(:get, /api.simplyhired.com.*pn-3.*/).with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).to_return(:status => 200, :body => File.new('test/pn-3.xml'), :headers => {})

        Simplyhired.configure do |config|
        config.pshid = "49544"
        	config.jbd = "subdomain.jobamatic.com"
        end

        sh = Simplyhired::Client.new('50.19.85.132')
        jobs =  sh.search_jobs(["Rails", "Ajax"], nil, "New York", "NY", 10, 30)

        puts sh.error
        puts sh.total_jobs_found

        assert sh.total_jobs_found == 59

        assert jobs[0].title == 'Senior Software Engineer - Ruby on Rails'
        assert jobs[0].company == 'Secondmarket'
        assert jobs[0].location == 'New York, NY'
        assert jobs[0].source == 'TheLadders.com'

        assert jobs[0].date_posted == "2014-01-06T05:07:41Z"

        jobs = sh.next
        assert jobs[0].title == 'Front End Web Developer'

        jobs = sh.next
        assert jobs[0].title == 'Consultant - .Net/SQL Programmer'

        jobs = sh.next
        jobs.must_be_nil

        Simplyhired.configure do |config|
        	config.pshid = nil
        	config.jbd = nil
        end
	end
end