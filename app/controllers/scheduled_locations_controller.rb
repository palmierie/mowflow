class ScheduledLocationsController < ApplicationController
  def index
    @scheduled_locations = ScheduledLocation.all
  end

  def new
    @scheduled_location = ScheduledLocation.new
    @clients = Client.all
    @durations = Duration.all
    @extra_duration_zero = ExtraDuration.where('id = ?', 6).first
    @business = get_business
  end

  def create
    @business = get_business
    @extra_duration_zero = ExtraDuration.where('id = ?', 6).first
    
    @scheduled_location = ScheduledLocation.new(scheduled_location_params)
    @scheduled_location.business_id = @business.id
    @scheduled_location.extra_duration_id = @extra_duration_zero.id
    # Change Mow Frequency input to integer and get next mow date
    mow_freq = get_mow_freq_as_int(@scheduled_location.mow_frequency)
    @scheduled_location.next_mow_date = get_next_mow_date(@scheduled_location.date_mowed, mow_freq)
    @scheduled_location.mow_frequency = mow_freq
    
    respond_to do |format|
      if @scheduled_location.save
        format.html { redirect_to scheduled_locations_path, notice: 'Job was successfully created.' }
        # format.json { render :show, status: :created, location: @user }
      else
        format.html { render :new }
        format.json { render json: @scheduled_location.errors, status: :unprocessable_entity }
      end
    end
  end

  def show
    @scheduled_location = ScheduledLocation.find(params[:id])
    @duration_obj = Duration.where('id = ?', @scheduled_location.duration_id).first
    @duration = @duration_obj.duration_desc
  end

  def edit
    @scheduled_location = ScheduledLocation.find(params[:id])
    @clients = Client.all
    @durations = Duration.all
    @extra_duration = ExtraDuration.where('id = ?', @scheduled_location.extra_duration_id).first
    @business = get_business
  end

  def update
    @scheduled_location = ScheduledLocation.find(params[:id])
    @extra_duration = ExtraDuration.where('id = ?', @scheduled_location.extra_duration_id).first
    # puts "LOG extra duration #{@extra_duration.id}"
    @scheduled_location.extra_duration_id = @extra_duration.id
    puts "LOG @sched.Extra dur #{@scheduled_location.extra_duration_id}"
     # Change Mow Frequency input to integer and get next mow date
     mow_freq = get_mow_freq_as_int(@scheduled_location.mow_frequency)
     @scheduled_location.next_mow_date = get_next_mow_date(@scheduled_location.date_mowed, mow_freq)
     @scheduled_location.mow_frequency = mow_freq

    if @scheduled_location.update(scheduled_location_params_update( @scheduled_location.extra_duration_id,
                                                                    @scheduled_location.next_mow_date,
                                                                    @scheduled_location.mow_frequency))
      redirect_to show
    else
      render 'edit'
    end
  end



  private
  
    # Use callbacks to share common setup or constraints between actions.
    def get_business
      @user_business = UserBusiness.where('user_id = ?', current_user).first
      @business = Business.where('id = ?', @user_business.business_id).first
    end

    def get_client
      @user_business = UserBusiness.where('user_id = ?', current_user).first
      @business = Business.where('id = ?', @user_business.business_id).first
    end

    # Change Mow Frequency input to integer
    def get_mow_freq_as_int(mow_freq)
      mow_frequency_as_string = mow_freq
      return mow_frequency_as_string.to_i
    end

    # Create Next Mow Date
    def get_next_mow_date(date_last_mowed, mow_freq)  
      date_mowed = @scheduled_location.date_mowed
      return date_mowed.days_since(mow_freq)
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def scheduled_location_params
      params.require(:scheduled_location).permit(:client_id, :business_id, :depot, :location_desc, :street_address, :city, :state, :zip, :google_place_id, :coordinates, :start_season, :end_season, :day_of_week, :mow_frequency, :date_mowed, :next_mow_date, :duration_id, :extra_duration_id, :user_notes, :special_job_notes)
    end

    # def scheduled_location_params_update(extra_dur, next_mow, mow_freq)
    #   {params.require(:scheduled_location).permit(:client_id, :business_id, :depot, :location_desc, :street_address, :city,  :state, :zip, :google_place_id, :coordinates, :start_season, :end_season, :day_of_week, :mow_frequency, :date_mowed, :next_mow_date, :duration_id, :extra_duration_id, :user_notes, :special_job_notes),
    #     params[:extra_duration_id] => extra_dur,
    #     params[:next_mow_date] => next_mow,
    #     params[:mow_frequency] => mow_freq}
    # end
end
