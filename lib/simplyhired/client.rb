require 'open-uri'
require "ox"
require 'simplyhired/job'
module Simplyhired
	class Client
		attr_reader :query_type, :location, :jobs, :current_page, :page_size, :error, :keywords, :zip, :city, :state, :distance, :days

		def initialize(ip)
			config_values = Simplyhired.config_values
			@pshid = config_values[:pshid]
			@jbd = config_values[:jbd]
			@credentials = "?pshid=#{@pshid}&ssty=2&cflg=r&jbd=#{@jbd}&clip=#{ip}"
		end

		def search_jobs(kw, z, c, s, options = {})
			unless @pshid
				@error = 'define pshid in a configuration file'
				return nil
			end
			unless @jbd
				@error = 'define jbd in a configuration file'
				return nil
			end
			@query_type = options[:query_type] || :OR
			@zip = z
			@city = c && c.split.join('+')
			@state = s && s.split.join('+')
			@page_size = options[:ws] || 25
			@distance = options[:distance] || 10
			@days = options[:days] || 0

			@keywords = kw

			@location = (@zip && !@zip.empty?) ? @zip : "#{@city},#{@state}"
			@current_page = options[:page] || 1

			@uri = ""
			@jobs = nil
			search @current_page
			@jobs
		end
		def next
			if @current_page * @page_size < @accessible_count.to_i
				@current_page += 1
				search @current_page
			else
				@jobs = nil
			end
			@jobs
		end
		def total_jobs_found
			@accessible_count || 0
		end


	  private

		def search(p = 1)
			sh_prefix = 'http://api.simplyhired.com/a/jobs-api/xml-v2/q-'

			case @query_type
			when :AND
				kw = @keywords.join('+AND+')
			when :PHRASE
				kw = '"' + @keywords.join('+') + '"'
			else
				kw = @keywords.join('+')
			end


			qd = @days > 0 ? "/fdb-#{@days}" : ""

			@uri = sh_prefix + kw + "/l-#{@location}" + "/mi-#{@distance}" + qd +"/ws-#{@page_size}" + "/pn-#{p}" + @credentials

			@uri = URI.escape @uri

			# puts @uri

			handler = Handler.new
			begin
				io = open @uri
				Ox.sax_parse(handler, io)
				if handler.error
					@jobs = nil
					@error = handler.error
				else
					@jobs = handler.jobs
					@total_count = handler.total
					@accessible_count = handler.accessible_count.to_i
				end
			rescue Exception => e
				@error = "SimlyHired Error - " + e.to_s
				@jobs = nil
				@total_count = 0
				@accessible_count = 0
			end
		end

		class Handler < Ox::Sax
		  JOB_ATTR = [:tr, :tv, :jt, :src, :cn, :e, :loc, :dp]
		  JOB_XML_ATTR_MAP = {jt: :title, src: :source, cn: :company, e: :excerpt, loc: :location, dp: :date_posted}

		  attr_reader :jobs, :total, :accessible_count, :error

		  def start_element(name)
		    @job = {} if name == :r
		    @jobs = Array.new if @jobs.nil?
		    @current_node = name
		  end

		  def value(val)
		    return unless JOB_ATTR.include?(@current_node)
		    if @current_node == :tr
		      @total = val.as_s
		    elsif @current_node == :tv
		      @accessible_count = val.as_s
		    else
		      @job[JOB_XML_ATTR_MAP[@current_node]] = val.as_s
		    end
		  end

		  def attr(name, val)
		  	if @current_node == :error
		  		@error = val if name == :type
		  		return
		  	end
		    return unless JOB_ATTR.include?(@current_node)
		    @job["#{JOB_XML_ATTR_MAP[@current_node]}:#{name}"] = val
		  end

		  def end_element(name)
		    return unless name == :r
		    j = Job.new @job
		    @jobs.push j
		  end
		end

	end
end