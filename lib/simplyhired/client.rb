require 'rest-client'
require 'simplyhired/job'

module Simplyhired
  class Client
    attr_reader :query_type, :location, :jobs, :current_page, :page_size, :error, :keywords, :zip, :city, :state, :distance, :days

    def initialize(ip)
      config_values = Simplyhired.config_values

      @pshid = config_values[:pshid]
      @auth = config_values[:auth]
      @ip = ip
      @base_uri = 'http://api.simplyhired.com/a/jobs-api/jsonp'
    end

    def search_jobs(kw, z, c, s, options = {})
      unless @pshid
        @error = 'define pshid in a configuration file'
        return nil
      end
      unless @auth
        @error = 'define auth in a configuration file'
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
      case @query_type
      when :AND
        kw = @keywords.join('+AND+')
      when :PHRASE
        kw = '"' + @keywords.join('+') + '"'
      else
        kw = @keywords.join('+')
      end


      qd = @days > 0 ? "/fdb-#{@days}" : ""

      # @uri = sh_prefix + kw + "/l-#{@location}" + "/mi-#{@distance}" + qd +"/ws-#{@page_size}" + "/pn-#{p}" + @credentials

      # @uri = URI.escape @uri

      # http://api.simplyhired.com/a/jobs-api/jsonp/q-ruby+san+francisco?pshid=120144&ssty=2&cflg=r&auth=ff3d787b6181b64f96ef6cebd464d13d457d592c.120144&clip=190.191.111.116
      begin
        result = RestClient.get("#{@base_uri}/q-#{kw}", { params: { pshid: @pshid, ssty: 2, cflg: 'r', auth: @auth, clip: @ip } })
        result = result.gsub('sh_cb(', '').gsub(');', '')

        @jobs = JSON.parse result
      rescue Exception => e
        @error = "SimlyHired Error - " + e.to_s
        @jobs = nil
        @total_count = 0
        @accessible_count = 0
      end
    end
  end
end