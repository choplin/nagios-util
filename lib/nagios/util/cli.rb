require 'nagios/util/command'
require 'nagios/util/log'
require 'thor'
require 'logger'

module Nagios
  module Util
    class Cli < Thor
      class_option :help, :type => :boolean, :aliases => '-h', :desc => 'Help message.'
      class_option :'log-level', :type => :string, :desc => 'Set log level'

      desc 'summary', 'Output summary status'
      method_option :'status-dat', :type => :string, :default => '/var/log/nagios/status.dat',
        :desc => 'Path to the Nagios\'s status.dat file'
      method_option :status,  :type => :array, :enum => ['critical', 'warning', 'ok', 'unknown'], :default => ['critical', 'warning', 'unknown'],
        :desc => 'List of statuses which you want to show'
      method_option :'attempt',  :type => :numeric, :default => 3,
        :desc => 'A threshold for a number of attempt. Only status with an attempt which is higher than or equals to the number specified by this parameter  will appear.'
      method_option :ignoredowntime, :type => :boolean, :default => true,
        :desc => 'Specifies whether downtimed servcies/hosts are  ignored'
      method_option :ignorehost,     :type => :array, :banner => 'HOST1 HOST2',
        :desc => 'List of regular expressions for a hostname which you want to ignore'
      method_option :ignoreservice,  :type => :array, :banner => '"foo" "bar"',
        :desc => 'List of service names which you want to ignore'
      method_option :format,  :type => :string, :enum => ['plain', 'simple', 'json', 'html'], :default => 'plain',
        :desc => 'Output format'
      method_option :file,  :type => :string, :banner => 'PATH', :aliases => ['-f'],
        :desc => 'Spefiies a json file path which contains other parameters. Other parameters take prior over a value specified by this file.'
      def summary
        Command::Summary.new(options).run
      end

      desc 'downtime [COMMAND]', 'Set schedule downtime for specified host|service'
      subcommand 'downtime', Command::Downtime

      no_commands do
        def invoke_command(command, *args)
          prepare(command)
          super
        end

        def prepare(command)
          show_help(command) unless options[:help].nil?
          set_log_level unless options[:'log-level'].nil?
        end

        def show_help(command)
          Cli.command_help(shell, command.name)
          exit 0
        end

        def set_log_level
          case options[:'log-level'].upcase
          when 'FATAL' then
            Log.set_loglevel(Logger::FATAL)
          when 'ERROR' then
            Log.set_loglevel(Logger::ERROR)
          when 'WARN' then
            Log.set_loglevel(Logger::WARN)
          when 'DEBUG' then
            Log.set_loglevel(Logger::DEBUG)
          when 'INFO' then
            Log.set_loglevel(Logger::INFO)
          end
        end
      end
    end
  end
end
