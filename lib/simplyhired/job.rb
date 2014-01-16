module Simplyhired
	class Job
		attr_reader :title, :company, :date_posted, :excerpt, :location, :source, :details_url, :details
		def initialize(jhash)
			encoding_options = {
				invalid: :replace,		# Replace invalid byte sequences
				undef: :replace,		# Replace anything not defined in ASCII
				replace:  '',			# Use a blank for those replacements
				universal_newline: true # Always break lines with \n
			}
			
			@title = jhash[:title] && jhash[:title].encode(Encoding.find('ASCII'), encoding_options).gsub("&amp;", "&")
			@excerpt = jhash[:excerpt]
			@location = jhash[:location]
			@company = jhash[:company] && jhash[:company].encode(Encoding.find('ASCII'), encoding_options).gsub("&amp;", "&")
			@source = jhash[:source]
			@details_url = jhash["source:url"]
			@date_posted = jhash[:date_posted]
		end
	end	
end