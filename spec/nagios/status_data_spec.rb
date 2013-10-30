require 'spec_helper'
require 'nagios/util/status_data'
require 'fileutils'

describe Nagios::Util::StatusData do
  before :all do
    @info = Nagios::Util::StatusData::Section.new(:info, {
      :created => '1383108828',
      :version => '3.2.3',
      :last_update_check => '1383076248',
      :update_available => '1',
      :last_version => '3.2.3',
      :new_version => '4.0.1'
    })

    @program_status = Nagios::Util::StatusData::Section.new(:programstatus, {
      :modified_host_attributes => '0',
      :modified_service_attributes => '0',
      :nagios_pid => '85031',
      :daemon_mode => '1',
      :program_start => '1383019577',
      :last_command_check => '1383108827',
      :last_log_rotation => '1383058800',
      :enable_notifications => '1',
      :active_service_checks_enabled => '1',
      :passive_service_checks_enabled => '1',
      :active_host_checks_enabled => '1',
      :passive_host_checks_enabled => '1',
      :enable_event_handlers => '1',
      :obsess_over_services => '0',
      :obsess_over_hosts => '0',
      :check_service_freshness => '1',
      :check_host_freshness => '0',
      :enable_flap_detection => '1',
      :enable_failure_prediction => '1',
      :process_performance_data => '0',
      :global_host_event_handler => '',
      :global_service_event_handler => '',
      :next_comment_id => '70323',
      :next_downtime_id => '53111',
      :next_event_id => '919208',
      :next_problem_id => '448337',
      :next_notification_id => '173587',
      :total_external_command_buffer_slots => '4096',
      :used_external_command_buffer_slots => '0',
      :high_external_command_buffer_slots => '5',
      :active_scheduled_host_check_stats => '0,1,3',
      :active_ondemand_host_check_stats => '5,57,150',
      :passive_host_check_stats => '0,0,0',
      :active_scheduled_service_check_stats => '529,2915,8915',
      :active_ondemand_service_check_stats => '0,0,0',
      :passive_service_check_stats => '0,1,3',
      :cached_host_check_stats => '5,57,150',
      :cached_service_check_stats => '0,0,0',
      :external_command_stats => '0,2,6',
      :parallel_host_check_stats => '0,1,3',
      :serial_host_check_stats => '0,0,0'
    })

    @host_status = Nagios::Util::StatusData::Section.new(:hoststatus, {
      :host_name => 'test_server',
      :modified_attributes => '1',
      :check_command => '',
      :check_period => '',
      :notification_period => '24x7',
      :check_interval => '5.000000',
      :retry_interval => '1.000000',
      :event_handler => '',
      :has_been_checked => '0',
      :should_be_scheduled => '1',
      :check_execution_time => '0.000',
      :check_latency => '1.023',
      :check_type => '0',
      :current_state => '0',
      :last_hard_state => '0',
      :last_event_id => '0',
      :current_event_id => '0',
      :current_problem_id => '0',
      :last_problem_id => '0',
      :plugin_output => '',
      :long_plugin_output => '',
      :performance_data => '',
      :last_check => '0',
      :next_check => '1383109036',
      :check_options => '1',
      :current_attempt => '1',
      :max_attempts => '5',
      :state_type => '1',
      :last_state_change => '1332145798',
      :last_hard_state_change => '1332145798',
      :last_time_up => '0',
      :last_time_down => '0',
      :last_time_unreachable => '0',
      :last_notification => '0',
      :next_notification => '0',
      :no_more_notifications => '0',
      :current_notification_number => '0',
      :current_notification_id => '171049',
      :notifications_enabled => '1',
      :problem_has_been_acknowledged => '0',
      :acknowledgement_type => '0',
      :active_checks_enabled => '1',
      :passive_checks_enabled => '1',
      :event_handler_enabled => '1',
      :flap_detection_enabled => '1',
      :failure_prediction_enabled => '1',
      :process_performance_data => '1',
      :obsess_over_host => '1',
      :last_update => '1383108828',
      :is_flapping => '0',
      :percent_state_change => '0.00',
      :scheduled_downtime_depth => '0'
    })

    @service_status = Nagios::Util::StatusData::Section.new(:servicestatus, {
      :host_name => 'test_server',
      :service_description => 'test_service',
      :modified_attributes => '0',
      :check_command => 'check_nrpe!adsvr-elapsedtime',
      :check_period => '24x7',
      :notification_period => '24x7',
      :check_interval => '10.000000',
      :retry_interval => '2.000000',
      :event_handler => '',
      :has_been_checked => '1',
      :should_be_scheduled => '1',
      :check_execution_time => '0.205',
      :check_latency => '0.612',
      :check_type => '0',
      :current_state => '0',
      :last_hard_state => '0',
      :last_event_id => '901709',
      :current_event_id => '902938',
      :current_problem_id => '0',
      :last_problem_id => '439658',
      :current_attempt => '1',
      :max_attempts => '3',
      :state_type => '1',
      :last_state_change => '1382958079',
      :last_hard_state_change => '1382958079',
      :last_time_ok => '1383108708',
      :last_time_warning => '1380311723',
      :last_time_unknown => '0',
      :last_time_critical => '1382957479',
      :plugin_output => 'OK: 12 files checked.',
      :long_plugin_output => ' /adsv/v1=0.4740% (128/27007) > 300msec\n /tm/js=0.5214% (147/28196) > 300msec\n /so.js=-0.1769% (-24/13570) > 300msec\n /rtb/sync=0.5265% (1245/236462) > 300msec\n /rd/v1=-26.9231% (-21/78) > 300msec\n /rtb/bid=1.6708% (23366/1398452) > 100msec\n /bc/v3=0.4388% (192/43759) > 300msec\n /rtb/sync_before=-0.0532% (-3/5634) > 300msec\n',
      :performance_data => '',
      :last_check => '1383108708',
      :next_check => '1383109308',
      :check_options => '0',
      :current_notification_number => '0',
      :current_notification_id => '156404',
      :last_notification => '0',
      :next_notification => '0',
      :no_more_notifications => '0',
      :notifications_enabled => '1',
      :active_checks_enabled => '1',
      :passive_checks_enabled => '1',
      :event_handler_enabled => '1',
      :problem_has_been_acknowledged => '0',
      :acknowledgement_type => '0',
      :flap_detection_enabled => '1',
      :failure_prediction_enabled => '1',
      :process_performance_data => '1',
      :obsess_over_service => '1',
      :last_update => '1383108828',
      :is_flapping => '0',
      :percent_state_change => '0.00',
      :scheduled_downtime_depth => '0'
    })

    @contact_status = Nagios::Util::StatusData::Section.new(:contactstatus, {
      :contact_name => 'azuma',
      :modified_attributes => '0',
      :modified_host_attributes => '0',
      :modified_service_attributes => '0',
      :host_notification_period => '24x7',
      :service_notification_period => '24x7',
      :last_host_notification => '0',
      :last_service_notification => '1383108648',
      :host_notifications_enabled => '1',
      :service_notifications_enabled => '1'
    })

    @service_comment = Nagios::Util::StatusData::Section.new(:servicecomment, {
      :host_name => 'test_server',
      :service_description => 'test_service',
      :entry_type => '2',
      :comment_id => '70155',
      :source => '0',
      :persistent => '0',
      :entry_time => '1383019578',
      :expires => '0',
      :expire_time => '0',
      :author => '(Nagios Process)',
      :comment_data => 'This service has been scheduled for fixed downtime from 09-11-2013 20:41:18 to 12-20-2013 20:41:18.  Notifications for the service will not be sent out during that time period.'
    })

    @host_comment = Nagios::Util::StatusData::Section.new(:hostcomment, {
      :host_name => 'test_server',
      :entry_type => '2',
      :comment_id => '70158',
      :source => '0',
      :persistent => '0',
      :entry_time => '1383019578',
      :expires => '0',
      :expire_time => '0',
      :author => '(Nagios Process)',
      :comment_data => 'This host has been scheduled for fixed downtime from 10-23-2013 14:47:47 to 11-02-2013 14:47:47.  Notifications for the host will not be sent out during that time period.'
    })

    @service_downtime = Nagios::Util::StatusData::Section.new(:servicedowntime, {
      :host_name => 'test_server',
      :service_description => 'test_service',
      :downtime_id => '27679',
      :entry_time => '1378899679',
      :start_time => '1378899678',
      :end_time => '1387539678',
      :triggered_by => '0',
      :fixed => '1',
      :duration => '8640000',
      :author => 'takada',
      :comment => 'maintenance'
    })

    @host_downtime = Nagios::Util::StatusData::Section.new(:hostdowntime, {
      :host_name => 'test_server',
      :downtime_id => '52730',
      :entry_time => '1382668269',
      :start_time => '1382668269',
      :end_time => '1383273069',
      :triggered_by => '0',
      :fixed => '1',
      :duration => '604800',
      :author => 'okuno',
      :comment => 'maintenance'
    })

    @status = Nagios::Util::StatusData.new({
      :info => [@info],
      :programstatus => [@program_status],
      :hoststatus => [@host_status],
      :servicstatus => [@service_status],
      :contactstatus => [@contact_status],
      :servicecomment => [@service_comment],
      :hostcomment => [@host_comment],
      :servicedowntime => [@service_downtime],
      :hostdown => [@host_downtime]
    })
  end

  it 'can be serialized to string' do
    expect(@status.dump).to be_instance_of(String)
  end

  context 'parse dat file' do
    before :all do
      here = File.dirname(__FILE__)
      file = 'test.dat'
      @path = File.join(here,file)
      open(@path, 'w'){|f| f.write(@status.dump)}
      @parsed_status = Nagios::Util::StatusData.parse_status_dat(@path)
    end

    after :all do
      FileUtils.rm(@path)
    end

    it 'contains info' do
      expect(@parsed_status.info.first).to eq(@info)
    end
    it 'contains program status' do
      expect(@parsed_status.programstatus.first).to eq(@program_status)
    end
    it 'contains host status' do
      expect(@parsed_status.hoststatus.first).to eq(@host_status)
    end
    it 'contains servicestatus' do
      expect(@parsed_status.servicestatus.first).to eq(@service_status)
    end
    it 'contains contact status' do
      expect(@parsed_status.contactstatus.first).to eq(@contact_status)
    end
    it 'contains service comment' do
      expect(@parsed_status.servicecomment.first).to eq(@service_comment)
    end
    it 'contains host comment' do
      expect(@parsed_status.hostcomment.first).to eq(@host_comment)
    end
    it 'contains service downtime' do
      expect(@parsed_status.servicedowntime.first).to eq(@service_downtime)
    end
    it 'contains host downtime' do
      expect(@parsed_status.hostdowntime.first).to eq(@host_downtime)
    end

    context 'info' do
      before :all do
        @info = @status.info.first
        @attrs = {
          :created => '1383108828',
          :version => '3.2.3',
          :last_update_check => '1383076248',
          :update_available => '1',
          :last_version => '3.2.3',
          :new_version => '4.0.1'
        }
      end
      it 'has correct attributes' do
        @attrs.each do |k,v|
          expect(@info.send(k)).to eq(v)
        end
      end
    end
  end

  describe Nagios::Util::StatusData::Section do
    before :all do
      @section = Nagios::Util::StatusData::Section.new(:test, {:foo => 'bar'})
    end

    it 'raise an exception for an attribute which does not exist' do
      expect(@section.foo).to raise_error
    end

    it 'can be converted to string correctly' do
      res = <<-STR
test {
	foo=bar
	}
      STR
      expect(@section.dump).to eq(res)
    end
  end
end
