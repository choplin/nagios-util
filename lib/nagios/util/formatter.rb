require 'term/ansicolor'
require 'terminal-table'
require 'erubis'

module Nagios::Util
  class Formatter
    include Term::ANSIColor

    def initialize(type, colorize)
      @type = type
      @colorize = colorize
    end

    def format(statuses)
      case @type
      when :plain
        format_as_plain(statuses)
      when :simple
        format_as_simple(statuses)
      when :json
        format_as_json(statuses)
      when :html
        format_as_html(statuses)
      end
    end

    private

    def format_as_plain(statuses)
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

      row_proc = lambda do |s|
        [
          s.host_name,
          s.service_description,
          s.status.to_s,
          Time.utc(s.last_check.to_i).to_s,
          duration_str(s.last_check.to_i - s.last_state_change.to_i),
          "#{s.max_attempts}/#{s.current_attempt}",
          s.plugin_output,
          s.is_downtime ? 'yes' : 'no'
        ]
      end

      table(statuses, cols, row_proc)
    end

    def format_as_simple(statuses)
      cols = %w(
        host
        service
        status
      )
      row_proc = lambda do |s|
        [
          s.host_name,
          s.service_description,
          s.status.to_s
        ]
      end

      table(statuses, cols, row_proc)
    end

    def format_as_json(statuses)
      JSON.dump(statuses.map(&:to_hash))
    end

    def format_as_html(statuses)
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

      rows = statuses.sort_by(&:host_name).map do |s|
        [
          s.host_name,
          s.service_description,
          s.status.to_s,
          Time.utc(s.last_check.to_i).to_s,
          duration_str(s.last_check.to_i - s.last_state_change.to_i),
          "#{s.max_attempts}/#{s.current_attempt}",
          s.plugin_output,
          s.is_downtime ? 'yes' : 'no'
        ]
      end

      template = <<-TEMPLATE
      <html>
        <head>
          <style type="text/css">
            table, td, th {
                border: 1px #2b2b2b solid;
                border-collapse: collapse;
            }
            td { padding: 2px 5px; }
          </style>
        </head>
        <body>
          <table>
            <thead>
              <tr>
                <% for c in cols %>
                <th><%= c %></th>
                <% end %>
              </tr>
            <thead>
            <tbody>
              <% for row in rows %>
              <tr>
                <% for e in row %>
                <td><%= e %></td>
                <% end %>
              </tr>
              <% end %>
            </tbody>
          </table>
        </body>
      </html>
      TEMPLATE

      Erubis::Eruby.new(template).result(:cols => cols, :rows => rows)
    end

    def table(statuses, cols, row_proc)
      rows = statuses.sort_by(&:host_name).map do |s|
        row = row_proc.call(s)
        if @colorize
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

    def duration_str(sec)
      day = sec / (60 * 60 * 24)
      sec = sec % (60 * 60 * 24)

      hour = sec / (60 * 60)
      sec = sec % (60 * 60)

      minute = sec / 60
      sec = sec % 60

      "#{day}d #{hour}h #{minute}m #{sec}s"
    end
  end
end
