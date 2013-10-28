require 'spec_helper'
require 'nagios/util/status'

describe Nagios::Util::StatusList do
  context 'built from html' do
    before :all do
      here = File.dirname(__FILE__)
      @list = Nagios::Util::StatusList.from_html(File.read(File.join(here, 'sample.html')))
    end

    it 'has 4 status' do
      @list.should have_exactly(4).items
    end

    it 'can retrieve statuses' do
      expects = [
        Nagios::Util::Status.new('foo', 'http elapsedtime', :critical, '10-28-2013 17:35:20', 3478, '3/3', 'Connection refused or timed out', true),
        Nagios::Util::Status.new('foo', 'Check Adsvr Redirection', :critical, '10-28-2013 17:38:19', 3287, '3/3', 'CRITICAL - Socket timeout after 1 seconds', true),
        Nagios::Util::Status.new('foo', 'Check Adsvr URL:/alive', :critical, '10-28-2013 17:30:49', 174146, '3/3', 'No route to host', true),
        Nagios::Util::Status.new('bar', 'http elapsedtime', :critical, '10-28-2013 17:35:20', 3478, '3/3', 'Connection refused or timed out', true)
      ]
      @list.zip(expects).each do |s,e|
        s.should eql(e)
      end
    end
  end
end
