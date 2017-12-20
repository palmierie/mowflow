class MowFlowController < ApplicationController
  
  def show
    @dates = Date.today..(Date.today + 2)
    @jobs = ScheduledLocation.all.group_by(&:next_mow_date)
    @optimize_days = [1,2,3]
  end
  
  def optimize_list
    # get depot
    @user_business = UserBusiness.where('user_id = ?', current_user).first
    @business = Business.where('id = ?', @user_business.business_id).first
    @depot = ScheduledLocation.where('business_id = ? AND depot = ?', @business.id, true).first.as_json
    # get number of routes (days) for optimization
    @number_of_routes = params["days"].to_i
    # get range of dates to for query
    @number_of_days = params["days"].to_i - 1
    @dates = Date.today..(Date.today + @number_of_days)
    # get jobs from database that are equal to the date range
    @jobs = ScheduledLocation.where(:next_mow_date => @dates).as_json
    # add the depot to the beginning of the array
    @jobs.unshift(@depot)
    # arrange job IDs in array
    @location_ids = []
    # arrange job durations in array
    @duration_per_location = []
    # put jobs into coordinate array following this format:
    # "lng1,lat1;lng2,lat2;"
    @coordinates_string = ""
    @jobs.each do |job|
      @location_ids.push(job["id"])
      @duration_per_location.push(job["duration_id"].to_i)
      @coordinates_string += job["coordinates"] + ";"
    end
    @coordinates_string = @coordinates_string.chop!

    @location_matrix = create_matrix(@coordinates_string)
    puts "matrix: #{@location_matrix}"

    @data_hash_for_optimization = {
                                    location_ids: @location_ids,
                                    location_matrix: @location_matrix,
                                    duration_per_location: @duration_per_location,
                                    number_of_routes: @number_of_routes 
                                  }
    @opto_data = optimize_mine(@data_hash_for_optimization)
    puts "optimized data: #{@opto_data}"
    
  end

  private

    def create_matrix(coord_string)
      @matrix = ApiCalls.get_matrix(coord_string)
      return @matrix
    end

    def optimize_mine(data_hash)
      @opto_data = ApiCalls.python_google_or_tools(data_hash)
      return @opto_data
    end

end
