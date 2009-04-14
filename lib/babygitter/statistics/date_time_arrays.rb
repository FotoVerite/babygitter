module Babygitter
  module DateTimeArrays
    
    # Creates and array of arrays containing Week Number and Year starting from now and counting back 52 weeks.
    # * Creates an array
    # * Finds time now
    # * Loops 52 times putting the week number and year into the array counting down one week each time
    # * Reverses this array so earliest week is first
    def create_52_week_map
      array = []
      now = Time.now
      i = 0
      while i < 52
        array << now.strftime("%U %Y")
        now -= (60*60*24*7)
        i += 1
      end
      array.reverse
    end
    
    # Creates an array of arrays that contain strings made up of the week of year number and year 
    # IE. 16 2008 would be week 16 of 2008
    # this is used to map the commits by week. 
    def create_active_date_array(began, ended)
      active_date_array = []
      i = 0
      weeks_repo_has_been_active = ((ended - began ) / (60*60*24*1)).ceil
      while i <= weeks_repo_has_been_active
        active_date_array << began.strftime("%U %Y")
        began += (60*60*24*1)
        i += 1
      end
      active_date_array.uniq
    end
    
  end
end