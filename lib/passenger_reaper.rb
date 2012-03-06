require "passenger_reaper/version"
require "passenger_reaper/ps_etime"
require "passenger_reaper/passenger_process"

module PassengerReaper
  class Runner
    def self.run(args)
      case args.first
      when 'old'
        PassengerProcess.kill_old_passengers
      when 'active'
        PassengerProcess.kill_stale_passengers
      when 'inactive'
        PassengerProcess.kill_inactive_passengers
      when 'all'
        PassengerProcess.kill_old_passengers
        PassengerProcess.kill_stale_passengers
        PassengerProcess.kill_inactive_passengers
      when 'debug'
        PassengerProcess.inactive_passengers_last_log_entry
      when 'status'
        puts "Total of passengers: #{PassengerProcess.all_passenger_pids.count}"
        puts "Stale passengers: #{PassengerProcess.stale.count}"
      else
        help =<<-EOF
Error: please use the following syntax:
  
    passenger_reaper <command> <options>

Commands:

status    displays the number of total passenger workers and the number of active workers
old       kills old workers that passengers has in the pool
active    kills stale workers that passengers has in the pool
inactive  kills workers that passenger no longer controls
all       kills both active, inactive & old workers
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
