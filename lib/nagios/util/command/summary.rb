require 'nagios/util/log'
require 'nagios/util/status'
require 'json'

module Nagios::Util::Command
  class Summary
    STATUS_PATH = '/cgi-bin/status.cgi'

    DEFAULTS = {
      :'status-dat' => '/var/log/nagios/status.dat',
      :status => ['critical', 'warning', 'unknown'],
      :format => 'plain'
    }

    def initialize(options)
      @logger          = Nagios::Util::Log.logger
      @logger.debug "options: #{options.inspect}"

      config = if options[:file].nil?
                 options
               else
                 #TODO defaults valuce cannot be used as overwritten value
                 json = JSON.parse(File.read(options[:file]))
                 json.merge(options) do |k, json_val, opt_val|
                   opt_val == DEFAULTS[k.to_sym] ? json_val : opt_val
                 end.reduce({}) do |h,(k,v)|
                   h[k.to_sym] = v
                   h
                 end
               end

      @logger.debug "config: #{config.inspect}"

      @status_dat_path = config[:'status-dat']

      @filters= {
        :status   => config[:status] ? config[:status].map(&:to_sym) : nil,
        :attempt  => config[:attempt].to_i,
        :ignoredowntime => config[:ignoredowntime],
        :ignorehost     => config[:ignorehost],
        :ignoreservice  => config[:ignoreservice]
      }

      @format = config[:format].to_sym
    end

    def run
      status = Nagios::Util::Status.parse_status_dat(@status_dat_path)
      puts status.summary(@format, @filters , $stdout.tty?)
    end
  end
end
