class ScheduledLocationsController < ApplicationController
  def index
    @scheduled_locations = ScheduledLocation.all
  end

  def new
    @scheduled_location = ScheduledLocation.new
    @clients = Client.all
    @durations = Duration.all
    @extra_duration_zero = ExtraDuration.where('id = ?', 0).first
    @business = get_business
  end

  def create
    @business = get_business
    @extra_duration_zero = ExtraDuration.where('id = ?', 0).first

    @scheduled_location = ScheduledLocation.new(scheduled_location_params)
    @scheduled_location.business_id = @business.id
    @scheduled_location.extra_duration_id = @extra_duration_zero.id
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
  end

  def edit
    @scheduled_location = ScheduledLocation.find(params[:id])
    @clients = Client.all
    @durations = Duration.all
    @extra_durations = ExtraDuration.all
  end

  def update
    @scheduled_location = ScheduledLocation.find(params[:id])
    if @scheduled_location.update(scheduled_location_params)
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

    # Never trust parameters from the scary internet, only allow the white list through.
    def scheduled_location_params
      params.require(:scheduled_location).permit(:client_id, :business_id, :depot, :location_desc, :street_address, :city, :state, :zip, :google_place_id, :coordinates, :start_season, :end_season, :day_of_week, :mow_frequency, :date_mowed, :next_mow_date, :duration_id, :extra_duration_id, :user_notes, :special_job_notes)
    end
end
