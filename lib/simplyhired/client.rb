require 'open-uri'
require "ox"
require 'simplyhired/job'
module Simplyhired
	class Client
		attr_reader :location, :jobs, :current_page, :page_size, :error, :keywords, :zip, :city, :state, :distance, :days
		SH_SITE = 'http://api.simplyhired.com/a/jobs-api/xml-v2/q-'

		def initialize(ip)
			config_values = Simplyhired.config_values
			@pshid = config_values[:pshid]
			@jbd = config_values[:jbd]
			@credentials = "?pshid=#{@pshid}&ssty=2&cflg=r&jbd=#{@jbd}&clip=#{ip}"
		end
		def search_jobs(kw, z, c, s, distance = 10, days = 0, page = 1, p = 25)
			unless @pshid
				@error = 'define pshid in a configuration file'
				return nil
			end
			unless @jbd
				@error = 'define jbd in a configuration file'
				return nil
			end

			@zip = z
			@city = c && c.sub(' ', '+')
			@state = s && s.sub(' ', '+')
			@page_size = p
			@distance = distance
			@days = days

			@keywords = kw[0]
			(1..kw.count).each {|k| @keywords += "+"+ kw[k].to_s} if kw.count > 1

			@location = (zip && !zip.empty?) ? zip : "#{@city},#{@state}"
			@current_page = page

			@url = ""
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

		def search(p = 0)

			p > 0 ? pn = "/pn-#{p}" : pn = ""

			@url = SH_SITE + @keywords + "/l-" + @location + "/mi-#{@distance}" + (@days > 0 ? "/fdb-#{@days}" : "") +"/ws-#{@page_size}" + pn + @credentials

			handler = Handler.new
			begin
				io = open @url
				Ox.sax_parse(handler, io)
				@jobs = handler.jobs
				@total_count = handler.total
				@accessible_count = handler.accessible_count.to_i
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

		  attr_reader :jobs, :total, :accessible_count

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