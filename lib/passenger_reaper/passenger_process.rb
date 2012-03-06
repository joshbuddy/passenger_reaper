require 'chronic'

module PassengerReaper
  class PassengerProcess
    MINIMUM_ETIME = 600 # 10 minutes

    attr_accessor :pid, :uptime
    
    def initialize(passenger_status_line)
      values = passenger_status_line.match(/PID:\s(\d*).*Uptime:\s*(.*)$/)
      @pid = values[1].to_i
      @uptime = values[2]
    end
    
    def uptime_in_seconds
      uptime_values = uptime.split(/\s/).map { |u| u.to_i }
      seconds = uptime_values[-1] || 0
      minutes = uptime_values[-2] || 0
      hours = uptime_values[-3] || 0
      seconds + (minutes*60) + (hours*3600)
    end


    def self.passenger_status
      @passenger_status ||= `passenger-status | grep PID`
    end
    
    def self.active
      passengers = []
      passenger_status.each_line do |line|
        passengers << PassengerProcess.new(line)
      end
      passengers
    end

    def self.old
      passengers = []
      passenger_status.each_line do |line|
        passengers << PassengerProcess.new(line)
      end
      passengers.select! { |ps| ps.uptime_in_seconds > MINIMUM_ETIME }
      passengers
    end

    def self.stale
      stale_passengers = []
      potentially_stale_processes = active.select { |p| p.uptime_in_seconds > 600 }
      potentially_stale_processes.each do |process|
        process_last_log_entry = last_log_entry(process.pid)
        etime = (Time.now - parse_time_from_log_entry(process_last_log_entry)).to_i
        if  etime > 600
          puts "Stale process last log entry: #{process_last_log_entry}" if debug?
          stale_passengers << process
        end
      end
      stale_passengers
    end
    
    def self.last_log_entry(pid)
      `grep 'rails\\[#{pid}\\]' #{Dir.pwd}/log/production.log | tail -n 1`.chomp
    end
    
    def self.last_log_entry_time(pid)
      log_entry = last_log_entry(pid)
      log_entry_time = parse_time_from_log_entry(log_entry)
      (Time.now - log_entry_time).to_i
    end
    
    def self.parse_time_from_log_entry(entry)
      Chronic.parse(entry.match(/.*\s.*\s\d{1,2}:\d{1,2}:\d{1,2}/)[0])    
    end

    def self.active_passenger_pids
      active.map{ |p| p.pid }
    end
    
    def self.passenger_memory_stats
      # 17630  287.0 MB  64.5 MB  Rails: /var/www/apps/gldl/current
      # 17761  285.9 MB  64.9 MB  Rails: /var/www/apps/gldl/current
      # 18242  293.1 MB  71.4 MB  Rails: /var/www/apps/gldl/current
      # 18255  285.9 MB  60.6 MB  Rails: /var/www/apps/gldl/current
      @passenger_memory_stats ||= `passenger-memory-stats | grep 'Rails:.*\/current'`
    end

    def self.all_passenger_pids
      passengers = []
      passenger_memory_stats.each_line do |line|
        matcher = line.match(/\s?(\d*)\s/)
        passengers << matcher[1] if matcher
      end
      passengers
    end

    def self.inactive_passenger_pids
      inactive_passenger_pids = []
      (all_passenger_pids - active_passenger_pids).each do |pid|
        raw_etime = `ps -p #{pid} --no-headers -o etime`.chomp
        etime = PsEtime.new(raw_etime)
        inactive_passenger_pids << pid unless (etime.age_in_seconds < (MINIMUM_ETIME || 600))
      end
      inactive_passenger_pids
    end

    def self.old_passenger_pids
      old_passenger_pids = []
      all_passenger_pids.each do |pid|
        raw_etime = `ps -p #{pid} --no-headers -o etime`.chomp
        etime = PsEtime.new(raw_etime)
        old_passenger_pids << pid unless (etime.age_in_seconds < (MINIMUM_ETIME || 600))
      end
      old_passenger_pids
    end

    def self.kill_inactive_passengers
      inactive_passenger_pids.each do |pid|
        kill(pid)
      end
    end
    def self.kill_old_passengers
      old.each do |ps|
        kill(ps.pid)
      end
    end
    
    def self.kill_stale_passengers
      stale.each do |p|
        kill(p.pid)
      end
    end
    
    def self.kill(pid)
      signal = ARGV.include?('--hard') ? 9 : 15
      command = "kill -#{signal} #{pid}"
      puts command
      `#{command}` unless noop?
    end
    
    def self.inactive_passengers_last_log_entry
      inactive_passenger_pids.each do |pid|
        puts last_log_entry(pid)[0, 150]
      end
    end  

    private
    
    def self.noop?
      @noop ||= ARGV.include?('--noop')
    end

    def self.debug?
      @noop ||= ARGV.include?('--debug')
    end
  end
end