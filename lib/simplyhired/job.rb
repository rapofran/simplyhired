module Simplyhired
	class Job
		attr_reader :title, :company, :date_posted, :excerpt, :location, :source, :details_url, :details
		def initialize(jhash)
			@title = jhash[:title]
			@excerpt = jhash[:excerpt]
			@location = jhash[:location]
			if jhash[:company]
				  encoding_options = {
				    invalid: :replace,		# Replace invalid byte sequences
				    undef: :replace,		# Replace anything not defined in ASCII
				    replace:  '',			# Use a blank for those replacements
				    universal_newline: true # Always break lines with \n
				  }
				name = jhash[:company].encode Encoding.find('ASCII'), encoding_options
				@company = name.gsub("&amp;", "&")
			end
			@source = jhash[:source]
			@details_url = jhash["source:url"]
			@date_posted = jhash[:date_posted]
		end
	end	
end