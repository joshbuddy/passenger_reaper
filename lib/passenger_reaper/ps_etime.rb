module PassengerReaper
  class PsEtime
    attr_accessor :seconds, :minutes, :hours, :days
    attr_reader :etime

    def initialize(raw_etime)
      @etime = raw_etime
      split_etime = @etime.split(/\-|\:/).map {|a| a.to_i}
      @seconds = split_etime[-1] || 0
      @minutes = split_etime[-2] || 0 
      @hours = split_etime[-3] || 0
      @days = split_etime[-4] || 0
    end
    
    def age_in_seconds
      @seconds + (@minutes*60) + (@hours*3600) + (@days*86400)
    end
  end
end
