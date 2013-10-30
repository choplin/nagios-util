require 'nagios/util/log'
require 'nagios/util/formatter'

module Nagios::Util
  class Status
    STATES = {
      0 => :ok,
      1 => :warning,
      2 => :critical,
      3 => :unknown
    }

    def initialize(sections)
      @sections = sections
      @logger = Nagios::Util::Log.logger
      @logger.debug("sections: #{@sections.keys.inspect}")
    end

    def dump
      @sections.values.map do |list|
        list.map {|s| s.dump}.join("\n")
      end.join("\n")
    end

    def summary(format, filters, colorize)
      service_statuses = filter_statues(@sections[:servicestatus], filters).map do |s|
        s.with_extra_attrs(:is_downtime => is_service_downtime?(s), :status => STATES[s.current_state.to_i])
      end

      formatter = Nagios::Util::Formatter.new(format, colorize)
      formatter.format(service_statuses)
    end

    def method_missing(name)
      if @sections.has_key?(name)
        @sections.fetch(name.to_sym)
      else
        super
      end
    end

    def respond_to_missing?(symbol, include_private)
      @sections.has_key?(symbol)
    end

    # TODO: skip sections using filters
    def self.parse_status_dat(path)
      logger = Nagios::Util::Log.logger
      logger.debug "parse #{path} start"

      sections = Hash.new {|h,k| h[k] = []}

      open(path) do |f|
        type = nil
        attrs_str = []
        f.each_line do |line|
          line.chomp!
          if line.end_with?("{")
            type = line.chomp('{').strip.to_sym
            attrs_str = []
          elsif line.end_with?("}")
            s = Section.new(type, attrs_str.join("\n"))
            sections[type].push(s)
          else
            attrs_str.push(line)
          end
        end
      end
      logger.debug "parse #{path} finished"
      self.new(sections)
    end

    private

    def filter_statues(statuses, filters)
      ret = statuses
      @logger.debug("a number of statuses: #{ret.size}")

      if filters[:status]
        ret = ret.select {|s| filters[:status].include?(STATES[s.current_state.to_i])}
      end
      @logger.debug("a number of statuses filterd with status: #{ret.size}")

      if filters[:attempt]
        ret = ret.select {|s| s.current_attempt.to_i >= filters[:attempt]}
      end
      @logger.debug("a number of statuses filterd with attempt: #{ret.size}")

      if filters[:ignoredowntime]
        ret = ret.select {|s| not is_service_downtime?(s)}
      end
      @logger.debug("a number of statuses filterd with downtime: #{ret.size}")

      if filters[:ignorehost]
        ret = ret.select {|s| filters[:ignorehost].all? {|h| s.host_name !~ /#{h}/}}
      end
      @logger.debug("a number of statuses filterd with host: #{ret.size}")

      if filters[:ignoreservice]
        ret = ret.select {|s| not filters[:ignoreservice].include?(s.service_description)}
      end
      @logger.debug("a number of statuses filterd with service: #{ret.size}")

      ret
    end

    def is_service_downtime?(service)
      service_downtimes = @sections[:servicedowntime]
      host_downtimes = @sections[:hostdowntime]

      is_sd = service_downtimes.any? do |d|
        d.host_name == service.host_name && d.service_description == service.service_description
      end
      is_hd = host_downtimes.any? do |d|
        d.host_name == service.host_name
      end

      is_sd || is_hd
    end

    public

    class Section
      attr_reader :type, :attrs

      def initialize(type, attrs_arg)
        @type = type
        if attrs_arg.class == Hash
          @attrs = attrs_arg
        elsif attrs_arg.class == String
          @attrs_str = attrs_arg
        end
      end

      def method_missing(name)
        if attrs.has_key?(name)
          attrs.fetch(name.to_sym)
        else
          super
        end
      end

      def respond_to_missing?(symbol, include_private)
        attrs.has_key?(symbol)
      end

      def dump
        str = "#{@type} {\n"
        str += attrs.map{|k,v| "\t#{k}=#{v}"}.join("\n")
        str += "\n\t}\n"
        str
      end

      def ==(other)
        attrs == other.attrs
      end

      def to_hash
        attrs
      end

      def with_extra_attrs(extra)
        self.class.new(@type, attrs.merge(extra))
      end

      def attrs
        @attrs || parse(@attrs_str)
      end

      private

      def parse(str)
        ret = {}
        str.each_line do |line|
          k,v = line.strip.split('=',2)
          ret[k.to_sym] = v
        end
        ret
      end
    end
  end
end
