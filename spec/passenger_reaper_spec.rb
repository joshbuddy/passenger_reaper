require File.expand_path("../test_helper", __FILE__)

describe PassengerReaper::PassengerProcess do
  before do
    @passenger_status =<<EOF
PID: 14548   Sessions: 0    Processed: 42      Uptime: 40s
PID: 14521   Sessions: 0    Processed: 29      Uptime: 1h 20m 43s
PID: 14525   Sessions: 0    Processed: 32      Uptime: 20m 5s
PID: 14007   Sessions: 0    Processed: 36      Uptime: 1m 47s
PID: 14830   Sessions: 1    Processed: 1       Uptime: 5s
EOF
    PassengerReaper::PassengerProcess.stub!(:passenger_status).and_return(@passenger_status)
  end

  it "should return active passenger processes" do
    all_passenger_processes = PassengerReaper::PassengerProcess.active
    all_passenger_processes.count.should eql(5)
    passenger = all_passenger_processes.first
    passenger.pid.should eql(14548)
    passenger.uptime.should eql('40s')
  end
  
  it "should parse the uptime into seconds" do
    all_passenger_processes = PassengerReaper::PassengerProcess.active
    all_passenger_processes[0].uptime_in_seconds.should eql(40)
    all_passenger_processes[4].uptime_in_seconds.should eql(5)
    all_passenger_processes[3].uptime_in_seconds.should eql(107)
    all_passenger_processes[1].uptime_in_seconds.should eql(4843)
  end
  
  it "should return the stale passengers" do
    stub_time = Chronic.parse('Sep 26 17:40:34')
    Time.stub!(:now).and_return(stub_time)
    PassengerReaper::PassengerProcess.stub!(:last_log_entry).with(14521).and_return('Sep 26 16:40:34 web1 rails[14521]: Rendering promotions/index')
    PassengerReaper::PassengerProcess.stub!(:last_log_entry).with(14525).and_return('Sep 26 17:39:34 web1 rails[14525]: Rendering promotions/index')
    stale_passengers = PassengerReaper::PassengerProcess.stale
    stale_passengers.count.should eql(1)
    stale_passengers[0].pid.should eql(14521)
  end
end