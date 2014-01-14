require 'helper'

describe 'configuration' do 
	after do
	Simplyhired.reset
	end

	describe '.configure' do
	  it "should set the pshid" do
	    Simplyhired.configure do |config|
	      config.send("pshid=", 'keyvalueset')
	      Simplyhired.send('pshid').must_equal 'keyvalueset'
	    end
	  end
	end

	describe '.pshid' do
		it 'should raise an exception' do 
			assert Simplyhired.pshid.must_be_nil
    	end
	end
end