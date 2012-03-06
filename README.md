# Passenger Reaper

Gemification of https://gist.github.com/596401/db750535df61e679aad69e8d9c9750f8640a234f

## Usage

    #> gem install passenger_reaper
    #> passenger_reaper

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
