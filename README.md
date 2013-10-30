# Nagios::Util

A command line tools for Nagios

**CAUTION: WIP version**

## Installation

Add this line to your application's Gemfile:

    gem 'nagios-util'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install nagios-util

## Available Command


### Help

    nagios-util help [COMMAND]

### Status

Output current status.

    nagios-util status [options]

#### available options

|name|type|description|default|
|:-----|------|------|------|
| --status-dat | string | Path to the Nagios\'s status.dat file | /var/log/nagios/status.dat |
| --status | array[enum] | List of statuses which you want to show | ['critical', 'warning', 'unknown'] |
| --attempt | int | A threshold for a number of attempt. Only status with an attempt which is higher than or equals to the number specified by this parameter  will appear. | 3 |
| --ignoredowntime | boolean | Specifies whether downtimed servcies/hosts are  ignored | true |
| --ignorehost | array[string] | List of regular expressions for a hostname which you want to ignore ||
| --ignoreservice | array[string] | List of service names which you want to ignore. ||
| --format | enum | Output format. available: 'plain' 'simple' 'json' 'html' | plain |
| -f --file | string | Spefiies a json file path which contains other parameters. Other parameters take prior over a value specified by this file. ||

### Downtime

Set a scheduled dontime for a specified host or a service.

#### Host Downtime

    nagios-util host HOSTNAME [options]

#### Servcie Downtime

    nagios-util service HOSTNAME SERVCIE [options]

#### available options

|name|type|description|default|
|:-----|------|------|------|
| -d --duration | int | a duration of a downtime | 2 |
| --author | string | an author of a downtime | ENV['USER'] |
| --comment | string | a comment for a downtime | "maintenace by #{ENV['USER']}" |
| --cmdpath | string | a path to nagios.cmd | /var/spool/nagios/cmd/nagios.cmd |

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
