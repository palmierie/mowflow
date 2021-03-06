class MowFlowController < ApplicationController
  @@save_hash = {}
  @@jobs_hash = {}
  @@skipped_jobs_hash = {}
  @@cancel_skipped_jobs_hash = {}
  
  require 'uri'

  #non-optimization scheduling
  def show_one_day
    @date = Date.today
    # @jobs = ScheduledLocation.all.group_by(&:next_mow_date)
    @jobs = ScheduledLocation.where('next_mow_date = ? AND in_progress IS ?', @date, nil)
                                    .group_by(&:next_mow_date)

    @save_jobs = ScheduledLocation.where('next_mow_date = ? AND in_progress IS ?', @date, nil).as_json
    @opto_location_hashes = {}
    @opto_location_hashes["#{@date}"] = @save_jobs
    # Sets class varible @@save_hash - to be accessed from next method: save_list
    opto_hash_list(@opto_location_hashes)
  end

  #optimization scheduling
  def show
    # @jobs = ScheduledLocation.all.group_by(&:next_mow_date)
    @dates = Date.today..(Date.today + 2)
    @search_dates = @dates.to_a
    @jobs = {}
    @search_dates.each do |date|
      @jobs_per_date = ScheduledLocation.where("next_mow_date = ? AND in_progress IS ?", date, nil).as_json
      if @jobs_per_date.length > 0
        @jobs_arr = []
        @jobs_per_date.each do |job_date|
          @jobs_arr.push(job_date)
        end
        @jobs[date.strftime("%F")] = @jobs_arr
      end
    end
    @optimize_days = [1,2,3]
  end
  
  def optimize_list
    # get depot
    @business = get_business
    @depot = ScheduledLocation.where('business_id = ? AND depot IS ?', @business.id, true).first.as_json
    # get number of routes (days) for optimization
    @number_of_routes = params["days"].to_i
    # get range of dates to for query
    @number_of_days = params["days"].to_i - 1
    @dates = Date.today..(Date.today + @number_of_days)
    @dates = @dates.to_a
    # get jobs from database that are equal to the date range and are not in_progress
        # @jobs = ScheduledLocation.where(:next_mow_date => @dates).as_json  # OLD CODE
    @jobs = []
    @dates.each do |date|
      @job_date = ScheduledLocation.where("next_mow_date = ? AND in_progress IS ?", date, nil).as_json
      @jobs.push(@job_date)
    end
    @jobs = @jobs.flatten()

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
    @location_matrix_response = create_matrix(@coordinates_string)

    # If Matrix OSRM API works then run Google OR-Tools
    if @location_matrix_response[0] == "ok"
      @error_true = false
      @location_matrix = @location_matrix_response[1]
      @data_hash_for_optimization = {
                                      location_ids: @location_ids,
                                      location_matrix: @location_matrix,
                                      duration_per_location: @duration_per_location,
                                      number_of_routes: @number_of_routes 
                                    }
      # Run Google OR-TOOLS Python Script to Optimize for best driving route
      @opto_data_response = optimize_mine(@data_hash_for_optimization)
      # If Google OR-Tools works
      if @opto_data_response[0] == "ok"
        @opto_data = @opto_data_response[1]
        # loop through data and push location id arrays (without the depots) to containing hash
        # {"date"=>[loc_hash,loc_hash], "date-2"=>[loc_hash,loc_hash,loc_hash] }
        @opto_location_hashes = {}
        limit = @number_of_routes
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
      else
        @error_true = true
        @error_msg = @opto_data_response[1]    
      end
    else
      @error_true = true
      @error_msg = @location_matrix_response[1]
    end

    render 'results'
  end

  def save_list
    # Get class variable
    @hash_from_save = opto_hash_list
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
  
  def in_progress
    @business = get_business
    @date = Date.today.strftime("%F")
    # get in_progress jobs from previous days
    @previous_jobs = ScheduledLocation.where(
                                            "business_id = ? AND service_date < ? AND in_progress IS ?", 
                                            @business.id, @date, true)
    # previous job status options
    @prev_in_prog_options = ["Not Done","Done","Reschedule for Set Date"]
    # get jobs where business_id, in_progress = true, service_date = today
    @jobs = ScheduledLocation.where(
                                    "business_id = ? AND service_date = ? AND in_progress IS ?", 
                                    @business.id, @date, true)
    # current in_progress job status options
    @in_prog_options = ["Not Done","Done","Reschedule for Tomorrow","Reschedule for Set Date"]
    # get jobs where business_id, in_progress = true, service_date = today
    @future_jobs = ScheduledLocation.where(
                                    "business_id = ? AND service_date > ? AND in_progress IS ?", 
                                    @business.id, @date, true)
    # current in_progress job status options
    @future_in_prog_options = ["Not Done","Reschedule for Set Date"]
    
    # Sets class varible @@jobs_hash - to be accessed from next method: save_progress
    @all_jobs = @jobs + @previous_jobs + @future_jobs
    in_progress_jobs_hash(@all_jobs)
    @maps_params = build_map_params(@jobs)
    render 'in_progress'
  end

  def print_list
    @business = get_business
    @day = Date.today.strftime("%A")
    @date = Date.today.strftime("%F")
    @jobs = ScheduledLocation.where(
                                    "business_id = ? AND service_date = ? AND in_progress IS ?", 
                                    @business.id, @date, true)
    respond_to do |format|
      format.html
      format.pdf do
        pdf = ReportPdf.new(@jobs,@business.name)
        send_data pdf.render, filename: "#{@date}_#{@day}_schedule.pdf", type: 'application/pdf', disposition: "inline"
      end
    end
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
        scheduled_location_params_done[:next_mow_date] = (Date.today + 1)
        scheduled_location_params_done[:position] = nil
        @scheduled_location.update(scheduled_location_params_done)
      end

      # Reschedule Jobs for later date
      if @progress == "Reschedule for Set Date"
        @scheduled_location = ScheduledLocation.where("id = ?", job["id"]).first
        @reschedule_jobs.push(@scheduled_location)
        # Set the the redirect to rescheduling the remaning jobs marked "Reschedule for Later Date"
        @reschedule_redirect = true
      end
    end

    if @reschedule_redirect
      in_progress_jobs_hash(@reschedule_jobs)
      redirect_to reschedule_in_progress_path and return
    end
    respond_to do |format|
      format.html { redirect_to in_progress_path, notice: 'Job(s) status was successfully updated.' }
    end
  end

  def reschedule_in_progress
    @jobs = in_progress_jobs_hash
    render 'reschedule_in_progress'
  end

  def save_reschedule_in_progress
    scheduled_location_params_done = scheduled_location_params
    @jobs = in_progress_jobs_hash
    @jobs.each do |job|
      @reschedule_date_raw = params["#{job["id"]}"]
      @scheduled_location = ScheduledLocation.where("id = ?", job["id"]).first
      @reschedule_date = Date.parse("#{@reschedule_date_raw["date(1i)"]}-#{@reschedule_date_raw["date(2i)"]}-#{@reschedule_date_raw["date(3i)"]}")
      scheduled_location_params_done[:service_date] = @reschedule_date
      scheduled_location_params_done[:next_mow_date] = @reschedule_date
      @scheduled_location.update(scheduled_location_params_done)
    end
    respond_to do |format|
      format.html { redirect_to in_progress_path, notice: 'Job(s) was successfully rescheduled.' }
    end
  end

  ####  These methods are for Rescheduling and Canceling Skipped Jobs  ####
  def skipped_jobs
    @business = get_business
    @date = Date.today
    # get previous unscheduled jobs
    @previous_skipped_jobs = ScheduledLocation.where(
                                                "business_id = ? AND next_mow_date < ? AND in_progress IS ?",
                                                @business.id, @date, nil)
    # job status options
    @skipped_job_options = ["Leave Alone","Cancel","Reschedule for Set Date"]
    get_set_skipped_jobs_hash(@previous_skipped_jobs)
    render 'skipped_jobs'
  end

  def save_skipped_jobs
    @jobs = get_set_skipped_jobs_hash
    @reschedule_jobs = []
    @cancel_jobs = []
    @reschedule_redirect = false
    @cancel_redirect = false
    # loop through progress update select and handle params accordingly
    # params options: "Leave", "Cancel", "Reschedule for Later Date"
    @jobs.each do |job|
      @progress = params["#{job["id"]}"]
      # If "Leave Alone", then do nothing
      # Cancel 
      if @progress == "Cancel"
        scheduled_location_params_done = scheduled_location_params
        @scheduled_location = ScheduledLocation.where("id = ?", job["id"]).first
        @cancel_jobs.push(@scheduled_location)
        # Set the the redirect to canceling the remaning jobs marked "Cancel"
        @cancel_redirect = true
      end

      # Reschedule Jobs for later date
      if @progress == "Reschedule for Set Date"
        @scheduled_location = ScheduledLocation.where("id = ?", job["id"]).first
        @reschedule_jobs.push(@scheduled_location)
        # Set the the redirect to rescheduling the remaning jobs marked "Reschedule for Later Date"
        @reschedule_redirect = true
      end
    end
   
    if @cancel_redirect
      get_set_canceled_skipped_jobs_hash(@cancel_jobs)
      redirect_to cancel_skipped_jobs_path and return
    end
    if @reschedule_redirect
      get_set_skipped_jobs_hash(@reschedule_jobs)
      redirect_to reschedule_skipped_jobs_path and return
    end
    redirect_to skipped_jobs_path
  end

  def reschedule_skipped_jobs
    @jobs = get_set_skipped_jobs_hash
    render 'reschedule_skipped_jobs'
  end

  def save_reschedule_skipped_jobs
    scheduled_location_params_done = scheduled_location_params
    @jobs = get_set_skipped_jobs_hash
    @jobs.each do |job|
      @reschedule_date_raw = params["#{job["id"]}"]
      @scheduled_location = ScheduledLocation.where("id = ?", job["id"]).first
      @reschedule_date = Date.parse("#{@reschedule_date_raw["date(1i)"]}-#{@reschedule_date_raw["date(2i)"]}-#{@reschedule_date_raw["date(3i)"]}")
      scheduled_location_params_done[:next_mow_date] = @reschedule_date
      @scheduled_location.update(scheduled_location_params_done)
    end
    respond_to do |format|
      format.html { redirect_to skipped_jobs_path, notice: 'Job(s) was successfully rescheduled.' }
    end
  end

  def cancel_skipped_jobs
    @jobs = get_set_canceled_skipped_jobs_hash
    @cancel_skipped_job_options = ["Leave Alone","Delete"]
    render 'cancel_skipped_jobs'
  end

  def save_cancel_skipped_jobs
    @jobs = get_set_canceled_skipped_jobs_hash
    @jobs.each do |job|
      @cancel_confirmation = params["#{job["id"]}"]
      @scheduled_location = ScheduledLocation.where("id = ?", job["id"]).first
      if @cancel_confirmation == "Delete"
        @scheduled_location.destroy
      end
    end
    respond_to do |format|
      format.html { redirect_to skipped_jobs_path, notice: 'Job(s) was successfully deleted.' }
    end
  end

  private

    def get_business
      @user_business = UserBusiness.where('user_id = ?', current_user).first
      @business = Business.where('id = ?', @user_business.business_id).first
    end

    def create_matrix(coord_string)
      @response = ApiCalls.get_matrix(coord_string)
      @matrix = []
      if @response[0] == "ok"
        @matrix[0] = "ok"
        @matrix[1] = @response[1]
      else
        @matrix[0] = "bad"
        @matrix[1] = @response[1]
      end
      return @matrix
    end

    def optimize_mine(data_hash)
      @opto_data_response = ApiCalls.python_google_or_tools(data_hash)
      @opto_data = []
      if @opto_data_response == "Error with Google OR-Tools Script"
        @opto_data[0] = "bad"
        @opto_data[1] = @opto_data_response
      else
        @opto_data[0] = "ok"
        @opto_data[1] = @opto_data_response
      end
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

    def get_set_skipped_jobs_hash(skipped_jobs_to_save = nil)
      @@skipped_jobs_hash = skipped_jobs_to_save || @@skipped_jobs_hash
      return @@skipped_jobs_hash
    end

    def get_set_canceled_skipped_jobs_hash(skipped_jobs_to_cancel = nil)
      @@cancel_skipped_jobs_hash = skipped_jobs_to_cancel || @@cancel_skipped_jobs_hash
      return @@cancel_skipped_jobs_hash
    end

    # Create Next Mow Date
    def get_next_mow_date(date_mowed, mow_freq)  
      return date_mowed.days_since(mow_freq)
    end

    def build_location_string(sched_loc)
      location = "#{sched_loc.street_address}, #{sched_loc.city}, #{sched_loc.state}"
      return location
    end

    def build_map_params(jobs)
      # get depot
      @business = get_business
      @depot = ScheduledLocation.where('business_id = ? AND depot IS ?', @business.id, true).first
      #build string to encode
      @root_url = "https://www.google.com/maps/dir/?api=1"
      @origin_params = "&origin=#{@depot.street_address}, #{@depot.city}, #{@depot.state}"
      @destination_params = "&destination=#{@depot.street_address}, #{@depot.city}, #{@depot.state}"
      @travel_mode = "&travelmode=driving"
      #build waypoints
      @waypoints_string = "&waypoints="
      jobs.each do |job|
        @waypoint_string = "#{job.street_address}, #{job.city}, #{job.state}|"
        @waypoints_string += @waypoint_string
      end
      # @final_string = URI.encode(@waypoints_string)
      @waypoints_string = @waypoints_string.chop!
      @final_string = "#{@root_url}#{@origin_params}#{@destination_params}#{@travel_mode}#{@waypoints_string}"
      @final_string_encoded = URI.encode(@final_string)
      
      return @final_string_encoded
    end

   # Never trust parameters from the scary internet, only allow the white list through.
    def scheduled_location_params
      params.permit(:service_date, :in_progress, :position, :next_mow_date, :date_mowed)
    end

end