class CalendarWeekController < ApplicationController
  
  
  def index
    @dates = Date.today..(Date.today + 5)
    @jobs = ScheduledLocation.all.group_by(&:next_mow_date)
  end

  def sort
    params[:scheduled_location].each_with_index do |id, index|
      ScheduledLocation.where(id: id).update_all(next_mow_date: params[:date])
    end
    head :ok
  end

  private
     # Never trust parameters from the scary internet, only allow the white list through.
     def scheduled_location_params
      params.require(:scheduled_location).permit(:next_mow_date, :position)
    end
end
