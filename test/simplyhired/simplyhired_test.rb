require 'helper'

describe Simplyhired do

    describe "version number" do
    	it 'should have a version' do
    		Simplyhired::VERSION.wont_be_nil	 
    	end
    end
    describe "configuration" do
    	it "should provide appropriate error" do 
    		Simplyhired.configure do |config|
            	# config.pshid = "49755"
    			config.jbd = "mysite.jobamatic.com"
            end

            sh = Simplyhired::Client.new('50.19.85.132')
            jobs =  sh.search_jobs(["Rails", "Ajax"], nil, "New York", "NY")
            assert sh.error == 'define pshid in a configuration file'
    		Simplyhired.configure do |config|
            	config.pshid = nil
    			config.jbd = nil
            end
    	end
    end
    describe "search for jobs" do
        before(:each) do
            Simplyhired.configure do |config|
                config.pshid = "49511"
                config.jbd = "subdomain.jobamatic.com"
            end
        end
        after(:each) do
            Simplyhired.configure do |config|
                config.pshid = nil
                config.jbd = nil
            end
        end
    	it "should find jobs" do

            stub_request(:get, /api.simplyhired.com.*pn-1.*/).with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).to_return(:status => 200, :body => File.new('test/pn-1.xml'), :headers => {})
            stub_request(:get, /api.simplyhired.com.*pn-2.*/).with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).to_return(:status => 200, :body => File.new('test/pn-2.xml'), :headers => {})
            stub_request(:get, /api.simplyhired.com.*pn-3.*/).with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).to_return(:status => 200, :body => File.new('test/pn-3.xml'), :headers => {})

            sh = Simplyhired::Client.new('50.19.85.132')
            jobs =  sh.search_jobs(["Rails", "Ajax"], nil, "New York", "NY", distance: 10, days: 30)

            assert sh.total_jobs_found == 70

            assert jobs[0].title == 'Senior Web Developer (Ruby/Rails/Javascript)'
            assert jobs[0].company == 'Namtek'
            assert jobs[0].location == 'New York, NY'
            assert jobs[0].source == 'Dice'
            assert jobs[0].date_posted == "2014-01-14T01:06:41Z"

            jobs = sh.next
            assert jobs[0].title == 'Backend Engineer'

            jobs = sh.next
            assert jobs[0].title == 'Innovation Engineer - Lamp/Web/Mobile'

            jobs = sh.next
            jobs.must_be_nil

    	end

        it "should find jobs with all keywords" do

            stub_request(:get, /api.simplyhired.com.*pn-1.*/).with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).to_return(:status => 200, :body => File.new('test/pn-1.xml'), :headers => {})

            sh = Simplyhired::Client.new('50.19.85.132')
            jobs =  sh.search_jobs(["Rails", "Ajax"], nil, "New York", "NY", distance: 10, days: 30)
            assert sh.total_jobs_found == 70

            stub_request(:get, /api.simplyhired.com.*pn-1.*/).with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).to_return(:status => 200, :body => File.new('test/phrase.xml'), :headers => {})
            jobs =  sh.search_jobs(["Rails", "Ajax"], nil, "New York", "NY", query_type: :PHRASE, distance: 10, days: 30)
            assert sh.total_jobs_found == 1

        end

        it "should return error from simplyhired" do

            stub_request(:get, /api.simplyhired.com.*pn-4.*/).with(:headers => {'Accept'=>'*/*', 'Accept-Encoding'=>'gzip;q=1.0,deflate;q=0.6,identity;q=0.3', 'User-Agent'=>'Ruby'}).to_return(:status => 200, :body => File.new('test/pn-4.xml'), :headers => {})

            sh = Simplyhired::Client.new('50.19.85.132')
            jobs =  sh.search_jobs(["Rails", "Ajax"], nil, "New York", "NY", query_type: :PHRASE, distance: 10, days: 30, page: 4)
            assert sh.error == 'noresults'

        end
    end
end