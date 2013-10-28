module Nagios::Util
  module NagiosCmd
    def self.schedule_host_downtime(host, duration, author, comment)
      now = Time.now.to_i
      format('SCHEDULE_HOST_DOWNTIME', [host, now, now + duration, 1, 0, duration, author, comment])
    end

    def self.schedule_svc_downtime(host, service, duration, author, comment)
      now = Time.now.to_i
      format('SCHEDULE_SVC_DOWNTIME', [host, service, now, now + duration, 1, 0, duration, author, comment])
    end

    private

    def self.format(command, options)
      "[#{Time.now.to_i}] #{command};#{options.join(';')}\n"
    end
  end
end
