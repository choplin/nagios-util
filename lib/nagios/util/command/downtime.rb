require 'nagios/util/nagios_cmd'
require 'nagios/util/log'
require 'thor'

module Nagios::Util::Command
  class Downtime < Thor
    class_option :duration, :type => :numeric, :banner => 'HOURS', :aliases => ['-d'], :default => 2
    class_option :author, :type => :string, :default => ENV['USER']
    class_option :comment, :type => :string, :default => "maintenace by #{ENV['USER']}"
    class_option :cmdpath, :type => :string, :banner => 'PATH', :default => '/var/spool/nagios/cmd/nagios.cmd'

    desc 'host HOSTNAME', 'set downtime for host'
    def host(hostname)
      duration = options[:duration] * 60 * 60
      cmd = Nagios::Util::NagiosCmd.schedule_host_downtime(hostname, duration, options[:author], options[:comment])
      File.open(options[:cmdpath], 'w') {|f| f.write cmd}
      logger.info "set schedule downtime for #{hostname}"
    end

    desc 'service HOSTNAME SERVICE_DESCRIPTION', 'set downtime for service'
    def service(hostname, service)
      duration = options[:duration] * 60 * 60
      cmd = Nagios::Util::NagiosCmd.schedule_svc_downtime(hostname, service, duration, options[:author], options[:comment])
      File.open(options[:cmdpath], 'w') {|f| f.write cmd}
      logger.info "set schedule downtime for #{service}@#{hostname}"
    end

    private

    def logger
      @logger ||= Nagios::Util::Log.logger
    end
  end
end
