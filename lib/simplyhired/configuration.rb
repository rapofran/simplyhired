module Simplyhired
	module Configuration
		VALID_CONFIG_KEYS = [:pshid, :jbd]

		# Build accessor methods for every config option
		attr_accessor *VALID_CONFIG_KEYS

		# Make sure we have the default values set when we get 'extended'
		def self.extended(base)
		  base.reset
		end

		def reset
		  self.pshid = nil
		  self.jbd = nil
		end		

	    def configure
	      yield self
	    end

	    def config_values
	      Hash[ *VALID_CONFIG_KEYS.map { |key| [key, send(key)] }.flatten ]
	    end

	end
end