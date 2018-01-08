class PagesController < ApplicationController
  skip_before_action :require_login, only: [:home]
  def home
    
  end
  def dashboard
    @user_business = UserBusiness.where('user_id = ?', current_user).first
    @user = User.where('id = ?', current_user).first
    if @user_business == nil
      redirect_to new_business_path
    else
      @business = get_business
      @date = Date.today
      # get previous unscheduled jobs
      @previous_skipped_jobs = ScheduledLocation.where(
                                                  "business_id = ? AND next_mow_date < ? AND in_progress IS ?",
                                                  @business.id, @date, nil)
      # get in_progress jobs from previous days
      @previous_scheduled_jobs = ScheduledLocation.where(
                                                    "business_id = ? AND service_date < ? AND in_progress IS ?",
                                                    @business.id, @date, true)
      # get today's jobs that are unscheduled
      @un_scheduled_jobs = ScheduledLocation.where(
                                              "business_id = ? AND (next_mow_date = ? OR service_date = ?) AND 
                                              in_progress IS ?",
                                              @business.id, @date, @date, nil)
      # get jobs where business_id, in_progress = true, service_date = today
      @scheduled_jobs = ScheduledLocation.where(
                                            "business_id = ? AND service_date = ? AND in_progress IS ?",
                                            @business.id, @date, true)
      # get upcoming jobs that are in_progress - true
      @upcoming_scheduled_jobs = ScheduledLocation.where(
                                            "business_id = ? AND service_date > ? AND in_progress IS ?",
                                            @business.id, @date, true)
    end

  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def get_business
      @user_business = UserBusiness.where('user_id = ?', current_user).first
      @business = Business.where('id = ?', @user_business.business_id).first
    end
    # Never trust parameters from the scary internet, only allow the white list through.
    
end
