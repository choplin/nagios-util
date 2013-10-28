require 'logger'

module Nagios::Util
  module Log
    DEFAULT_LOG_LEVEL = Logger::WARN

    def self.logger
      @logger ||= create_logger
    end

    def self.set_loglevel(level)
      logger.level = level
    end

    private

    def self.create_logger
      logger = Logger.new(STDOUT)
      logger.level = DEFAULT_LOG_LEVEL
      logger
    end
  end
end
