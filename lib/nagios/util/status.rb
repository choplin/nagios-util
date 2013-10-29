require 'hpricot'
require 'term/ansicolor'
require 'terminal-table'
require 'erubis'

module Nagios::Util
  class Status
    attr_reader :host
    attr_reader :service
    attr_reader :status
    attr_reader :last_check
    attr_reader :duration
    attr_reader :attempt
    attr_reader :information
    attr_reader :downtime
    def initialize(host, service, status, last_check, duration, attempt, information, downtime)
      @host = host
      @service = service

      @status = if status.class == Symbol
                  status
                elsif status.class == String
                  if %w(CRITICAL WARNING UNKNOWN OK).include?(status)
                    status.downcase.to_sym
                  end
                end

      @last_check = last_check
      @duration = duration
      @attempt = attempt
      @information = information
      @downtime = downtime
    end

    def eql?(other)
      @host         == other.host &&
      @service      == other.service &&
      @status       == other.status &&
      @last_check   == other.last_check &&
      @duration     == other.duration &&
      @attempt      == other.attempt &&
      @information  == other.information &&
      @downtime     == other.downtime
    end

    def to_hash
      {
        :host      =>  @host,
        :service   =>  @service,
        :status    =>  @status,
        :last_chec =>  @last_check,
        :duration  =>  @duration,
        :attempt   =>  @attempt,
        :informati =>  @information,
        :downtime  =>  @downtime
      }
    end

    def array_with_fields(fields)
      fields.map do |f|
        val = self.instance_eval("@#{f}")
        if f == 'downtime'
          val = val ? 'downtime' : ''
        end
        val.to_s
      end
    end
  end

  class StatusList
    include Enumerable
    include Term::ANSIColor

    def initialize(statuses)
      @statuses = statuses
    end

    def length
      @statuses.length
    end

    alias :size :length

    def each
      @statuses.each{|s| yield s}
    end

    def select!
      @statuses.select!{|s| yield s}
    end

    def select
      self.class.new(@statuses.select{|s| yield s})
    end

    def format_as(type, colorize)
      case type
      when :plain
        format_as_plain(colorize)
      when :simple
        format_as_simple(colorize)
      when :json
        format_as_json
      when :html
        format_as_html
      end
    end

    def self.from_html(body)
      top = Hpricot body
      trs = top.search("//table[@class='status']//tr")

      statuses = []
      current_host = nil
      current_downtime = nil

      trs.each do |tr|
        tds = tr.children_of_type('td')
        next unless tds.length == 7

        host = tds[0].inner_text.strip
        if host.empty?
          host = current_host
        else
          current_host = host
          if tds[0].inner_html =~ /#comments/
            current_downtime = true
          else
            current_downtime = false
          end
        end

        service         = tds[1].inner_text.strip
        status          = tds[2].inner_text.strip
        last_check      = tds[3].inner_text.strip
        duration_str    = tds[4].inner_text.strip
        attempt         = tds[5].inner_text.strip
        information     = tds[6].inner_text.strip
        downtime        = current_downtime || tds[1].inner_html =~ /#comments/

        status = Status.new(
          host,
          service,
          status,
          last_check,
          str_to_duration(duration_str),
          attempt,
          information,
          downtime
        )
        statuses.push(status)
      end

      self.new(statuses)
    end

    private

    def self.str_to_duration(str)
      raise "invalid duration string #{str}" if str !~ /(\d+)d\s+(\d+)h\s+(\d+)m\s+(\d+)s/
      (($1.to_i * 24 + $2.to_i) * 60 + $3.to_i) * 60 + $4.to_i
    end

    def format_as_plain(colorize)
      cols = %w(
        host
        service
        status
        last_check
        duration
        attempt
        information
        downtime
      )
      table_with_columns(@statuses, cols, colorize)
    end

    def format_as_simple(colorize)
      cols = %w(
        host
        service
        status
      )
      table_with_columns(@statuses, cols, colorize)
    end

    def format_as_json
      JSON.dump(@statuses.map(&:to_hash))
    end

    def format_as_html
      cols = %w(
        host
        service
        status
        last_check
        duration
        attempt
        information
        downtime
      )

      rows = @statuses.sort_by(&:host).map do |s|
        row = s.array_with_fields(cols)
      end

      template = <<-TEMPLATE
      <table>
        <thead>
          <tr>
            <% for c in cols %>
            <td><%= c %></td>
            <% end %>
          </tr>
        <thead>
        <tbody>
          <% for row in rows %>
          <tr>
            <% for e in row %>
            <td><%= e %></td>
            <% end %>
          </tr
          <% end %>
        </tbody>
      <table>
      TEMPLATE

      Erubis::Eruby.new(template).result(:cols => cols, :rows => rows)
    end

    def table_with_columns(statuses, cols, colorize)
      rows = statuses.sort_by(&:host).map do |s|
        row = s.array_with_fields(cols)
        if colorize
          colorize_row(row, s.status)
        else
          row
        end
      end

      Terminal::Table.new :headings => cols, :rows => rows
    end

    def colorize_row(row, status)
      case status
      when :critical
        row.map{|e| red( bold(e) )}
      when :warning
        row.map{|e| yellow(e)}
      when :unknown
        row.map{|e| magenta(e)}
      else
        row
      end
    end
  end
end
