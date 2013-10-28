module Nagios
  module Util
    module Command
      command_dir = File.join(File.dirname(__FILE__), 'command')
      pattern = "#{command_dir}/*"
      Dir.glob(pattern) do |f|
        require File.join('nagios/util/command', File.basename(f, '.rb'))
      end
    end
  end
end
