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
      method_option :url,
        :desc => 'Nagios url. This can include a schema(http|https), port(8080) and a path(/nagios).'
      method_option :param,
        :desc => 'Query parameter of status.cgi'
      method_option :user, :banner => 'USER:PASSWORD', :aliases => ['-u'],
        :desc => 'A credential for Web server authentication.'
      method_option :ignoredowntime, :type => :boolean,
        :desc => 'Specifies whether downtimed servcies/hosts are  ignored'
      method_option :ignorehost,     :type => :array, :banner => 'HOST1 HOST2',
        :desc => 'List of regular expressions for a hostname which you want to ignore'
      method_option :ignoreattempt,  :type => :array, :banner => '1/3 2/3',
        :desc => 'List of attempts which you want to ignore'
      method_option :ignoreservice,  :type => :array, :banner => '"foo" "bar"',
        :desc => 'List of service names which you want to ignore'
      method_option :format,  :type => :string, :enum => ['raw', 'simple', 'json']
        :desc => 'Output format'
      method_option :file,  :type => :string, :banner => 'PATH', :aliases => ['-f'],
        :desc => 'Spefiies a json file path which contains other parameters. This takes prior over ohter parameteres.'
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
