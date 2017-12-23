class MowFlowController < ApplicationController
  @@save_hash = {}
  @@jobs_hash = {}
  def show
    @dates = Date.today..(Date.today + 2)
    @jobs = ScheduledLocation.all.group_by(&:next_mow_date)
    @optimize_days = [1,2,3]
  end
  
  def optimize_list
    # get depot
    @business = get_business
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

    # Generate Location Matrix from coordinates
    puts "coord string: #{@coordinates_string}"
    @location_matrix = create_matrix(@coordinates_string)
    puts "matrix: #{@location_matrix}"

    @data_hash_for_optimization = {
                                    location_ids: @location_ids,
                                    location_matrix: @location_matrix,
                                    duration_per_location: @duration_per_location,
                                    number_of_routes: @number_of_routes 
                                  }
    # Run Google OR-TOOLS Python Script to Optimize for best driving route
    @opto_data = optimize_mine(@data_hash_for_optimization)
    
    # loop through data and push location id arrays (without the depots) to containing hash
    # {"date"=>[loc_hash,loc_hash], "date-2"=>[loc_hash,loc_hash,loc_hash] }
    @opto_location_hashes = {}
    limit = @number_of_routes;
    @dates_array = @dates.to_a
    for i in 1..limit
      @location_array = []
      @lookup_ids = @opto_data["route_day_#{i}"]["location_ids"].slice(1,(@opto_data["route_day_#{i}"]["location_ids"].length - 2))
      @lookup_ids.each do |id|
        @location_array.push( ScheduledLocation.where("id = ?", id).first.as_json )
      end
      @opto_location_hashes["#{@dates_array[i-1]}"] = @location_array
    end
    # Sets class varible @@save_hash - to be accessed from next method: save_list
    opto_hash_list(@opto_location_hashes)

    render 'results'
  end

  def save_list
    # Get class variable
    @hash_from_save = opto_hash_list
    ## TO DO:
    #  LOOP: Set service date of each location hash to key of the hash: @hash_from_save[date] = [{location},{location}, etc]
    @hash_from_save.each do |job_list|
      @opto_date = job_list[0]
      # set position
      position = 1
      job_list[1].each do |job|
        # set service date to @opto_date
        @opto_job = ScheduledLocation.where("id = ?", job["id"]).first
        @opto_job.service_date = @opto_date
        # if service_date is today then switch in_progress boolean to true
        if @opto_date == Date.today.strftime("%F")
          @opto_job.in_progress = true
        end
        # save position - order of jobs
        @opto_job.position = position
        @opto_job.update(scheduled_location_params)
        position += 1
      end
    end
    redirect_to in_progress_path
  end

  def select_work_list
    @business = get_business

    # redirect_to in_progess_path
  end
  
  def in_progress
    @business = get_business
    # get jobs where business_id, in_progress = true, service_date = today
    @jobs = ScheduledLocation.where("business_id = ? AND service_date = ? AND in_progress = ?", @business.id, Date.today.strftime("%F"), true)
    #get client info for each job
    # @clients = []
    # @jobs.each do |job|
    #   @client = Client.where("id = ?", job.client_id).first
    #   @clients.push(@client)
    # end
    @in_prog_options = ["Not Done","Done","Reschedule for Tomorrow","Reschedule for Later Date"]
    # Sets class varible @@jobs_hash - to be accessed from next method: save_progress
    in_progress_jobs_hash(@jobs)

    render 'in_progress'
  end

  def save_progress
    @jobs = in_progress_jobs_hash
    @reschedule_jobs = []
    @reschedule_redirect = false
    # loop through progress update select and handle params accordingly
    # params options: "Not Done", "Done", "Reschedule for Tomorrow", "Reschedule for Later Date"
    @jobs.each do |job|
      @progress = params["#{job["id"]}"]
      # If "Not Done", then do nothing
      # If "Done", then switch in_progress to false, set date_mowed to today, set next_mow_date, set service_date to nil, and position to nil
      if @progress == "Done"
        scheduled_location_params_done = scheduled_location_params
        @scheduled_location = ScheduledLocation.where("id = ?", job["id"]).first
        scheduled_location_params_done[:in_progress] = nil
        scheduled_location_params_done[:date_mowed] = Date.today
        scheduled_location_params_done[:next_mow_date] = get_next_mow_date(Date.today, job["mow_frequency"])
        scheduled_location_params_done[:service_date] = nil
        scheduled_location_params_done[:position] = nil
        @scheduled_location.update(scheduled_location_params_done)
      end
      
      # Reschedule Jobs for tomorrow 
      if @progress == "Reschedule for Tomorrow"
        scheduled_location_params_done = scheduled_location_params
        @scheduled_location = ScheduledLocation.where("id = ?", job["id"]).first
        scheduled_location_params_done[:service_date] = (Date.today + 1)
        scheduled_location_params_done[:position] = nil
        @scheduled_location.update(scheduled_location_params_done)
      end

      # Reschedule Jobs for later date
      if @progress == "Reschedule for Later Date"
        @scheduled_location = ScheduledLocation.where("id = ?", job["id"]).first
        @reschedule_jobs.push(@scheduled_location)
        # Set the the redirect to rescheduling the remaning jobs marked "Reschedule for Later Date"
        @reschedule_redirect = true
      end
    end

    if @reschedule_redirect
      in_progress_jobs_hash(@reschedule_jobs)
    end
    
  end

  private

    def get_business
      @user_business = UserBusiness.where('user_id = ?', current_user).first
      @business = Business.where('id = ?', @user_business.business_id).first
    end

    def create_matrix(coord_string)
      @matrix = ApiCalls.get_matrix(coord_string)
      return @matrix
    end

    def optimize_mine(data_hash)
      @opto_data = ApiCalls.python_google_or_tools(data_hash)
      return @opto_data
    end

    def opto_hash_list(hash_to_save = nil)
      @@save_hash = hash_to_save || @@save_hash
      return @@save_hash
    end

    def in_progress_jobs_hash(jobs_hash_to_save = nil)
      @@jobs_hash = jobs_hash_to_save || @@jobs_hash
      return @@jobs_hash
    end

    # Create Next Mow Date
    def get_next_mow_date(date_mowed, mow_freq)  
      return date_mowed.days_since(mow_freq)
    end

    def build_location_string(sched_loc)
      location = "#{sched_loc.street_address}, #{sched_loc.city}, #{sched_loc.state}"
      return location
    end

   # Never trust parameters from the scary internet, only allow the white list through.
    def scheduled_location_params
      params.permit(:service_date, :in_progress, :position, :next_mow_date, :date_mowed)
    end

end