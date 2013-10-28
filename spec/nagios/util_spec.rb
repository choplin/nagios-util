require 'spec_helper'

describe Nagios::Util do
  it 'should have a version number' do
    Nagios::Util::VERSION.should_not be_nil
  end
end
