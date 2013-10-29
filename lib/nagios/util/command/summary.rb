require 'nagios/util/log'
require 'nagios/util/status'
require 'uri'
require 'httpclient'
require 'json'

module Nagios::Util::Command
  class Summary
    STATUS_PATH = '/cgi-bin/status.cgi'

    DEFAULT_URL = 'http://localhost'
    DEFAULT_PARAM = {
      'host' => 'all',
      'servicestatustypes' => '28',
      'hoststatustypes' => '15'
    }

    DEFAULT_FORMAT = :plain

    def initialize(options)
      @logger          = Nagios::Util::Log.logger
      @logger.debug "options: #{options.inspect}"

      config = if options[:file].nil?
                 options
               else
                 json = JSON.parse(File.read(options[:file])).reduce({}) do |h,(k,v)|
                   h[k] = v
                   h
                 end
                 json.merge(options).reduce({}) do |h,(k,v)|
                   h[k.to_sym] = v
                   h
                 end
               end

      @logger.debug "config: #{config.inspect}"

      @url             = (config[:url] || DEFAULT_URL)
      @param           = param_string_to_hash(config[:param]) || DEFAULT_PARAM
      @user, @password = config[:user].split(':',2) if config[:user]
      @ignoredowntime  = config[:ignoredowntime]
      @ignorehost      = config[:ignorehost]
      @ignoreattempt   = config[:ignoreattempt]
      @ignoreservice   = config[:ignoreservice]
      @ignorestatus    = config[:ignorestatus] ? config[:ignorestatus].map(&:to_sym) : nil
      @format          = (config[:format] || DEFAULT_FORMAT).to_sym
    end

    def run
      client = HTTPClient.new
      client.ssl_config.verify_mode=nil
      if @user
        client.set_auth(@url, @user, @password)
      end

      #TODO suppress ssl message
      #     at depth 0 - 18: self signed certificate
      $stderr= File.open('/dev/null', "w")
      body = client.get_content(@url + STATUS_PATH, @param)
      $stderr = STDERR

      @logger.debug("status list: #{Nagios::Util::StatusList.from_html(body)}")
      statuses = filter_status(Nagios::Util::StatusList.from_html(body))
      @logger.debug("statuses: #{statuses}")

      $stdout.puts statuses.format_as(@format, $stdout.tty?)
    end

    private

    def filter_status(status_list)
      ret = status_list
      if @ignoredowntime
        ret = ret.select {|s|  not (@ignoredowntime && s.downtime)}
      end
      if @ignorehost
        ret = ret.select {|s| @ignorehost.all? {|h| s.host !~ /#{h}/}}
      end
      if @ignoreattempt
        ret = ret.select {|s| @ignoreattempt.all? {|a| s.attempt != a}}
      end
      if @ignoreservice
        ret = ret.select {|s| @ignoreservice.all? {|service| s.service != service}}
      end
      if @ignorestatus
        ret = ret.select {|s| @ignorestatus.all? {|st| s.status != st}}
      end
      ret
    end

    def param_string_to_hash(str)
      str.nil? ? nil : str.split('&').map{|kv| kv.split('=',2)}.reduce({}){|h,(k,v)| h[k] = v; h}
    end
  end
end
