class MowFlowController < ApplicationController
  
  def show
    @dates = Date.today..(Date.today + 2)
    @jobs = ScheduledLocation.all.group_by(&:next_mow_date)
    @optimize_days = [1,2,3]
  end
  
  def optimize_list
    # get range of dates to for query
    @number_of_days = params["days"].to_i - 1
    @dates = Date.today..(Date.today + @number_of_days)
    # get jobs from database that are equal to the date range
    @jobs = ScheduledLocation.where(:next_mow_date => @dates).as_json

    # arrange job IDs in array
    @location_ids = []
    # arrange job durations in array
    @durations
    # put jobs into coordinate array following this format
    # "lng1,lat1;lng2,lat2;"
    @coordinates_string = ""
    @jobs.each do |job|
      @location_ids.push(job["id"])
      @coordinates_string += job["coordinates"] + ";"
      puts "job name: #{job['location_desc']} job date: #{job['next_mow_date']}"
    end
    @coordinates_string = @coordinates_string.chop!

    puts "coordinates: #{@coordinates_string}"
    @number_of_routes = @number_of_days + 1
    # puts "jobs: #{@jobs}"



    coordString = "-86.9116559,40.461655;-86.921173,40.46331199999999;-86.92182,40.46331;-86.90959199999999,40.4673048;-86.9364658,40.4795477;-86.97491,40.475311;-86.90780629999999,40.4946867;-86.90099339999999,40.47090149999999;-86.92161779999999,40.45996969999999;-86.92226699999999,40.450081;-86.9229952,40.4576658;-86.92029099999999,40.463401;-86.921531,40.463736;-86.9042097,40.4640966;-86.9121128,40.5065488;-86.922682,40.46330700000001;-86.91655659999999,40.448682;-86.9032374,40.4725059;-86.9030104,40.47211"
    # ApiCalls.get_matrix(coordString)
    puts "after api call"
  end



end
