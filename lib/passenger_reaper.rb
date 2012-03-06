require "passenger_reaper/version"
require "passenger_reaper/ps_etime"
require "passenger_reaper/passenger_process"

module PassengerReaper
  MINIMUM_ETIME = 600 # 10 minutes

  class Runner
    def self.run(args)
      if %W(active inactive debug status).include?(ARGV.first)
        case ARGV.first
        when 'active'
          PassengerProcess.kill_stale_passengers
        when 'inactive'
          PassengerProcess.kill_inactive_passengers
        when 'debug'
          PassengerProcess.inactive_passengers_last_log_entry
        when 'status'
          puts "Total of passengers: #{PassengerProcess.all_passenger_pids.count}"
          puts "Stale passengers: #{PassengerProcess.stale.count}"
        end
      else
        help =<<-EOF
Error: please use the following syntax:
  
    passenger_reaper <command> <options>

Commands:

status    displays the number of total passenger workers and the number of active workers
active    kills stale workers that passengers has in the pool
inactive  kills workers that passenger no longer controls
debug     shows the last log entry from each inactive worker

Options:

--noop    don't actually kill processes but show which ones would have been killed
--hard    send the KILL signal
      EOF
        puts help
        exit 1
      end
    end
  end
end
