class CalendarWeekController < ApplicationController
  def show
    @date = params[:date] ? Date.parse(params[:date]) : Date.today
    # @next_mow_by_date = ScheduledLocation.all.group_by(&:next_mow_date)
  end
  
  def index
    @dates = Date.today..(Date.today + 5)
    @jobs = ScheduledLocation.all.group_by(&:next_mow_date)
    # @jobs = ScheduledLocation.all
  end

  def sort
    puts "next mow date: #{params[:next_mow_date]}"
    puts "params: #{params[:scheduled_location]}"
    params[:scheduled_location].each_with_index do |id, index|
      ScheduledLocation.where(id: id).update_all(position: index + 1)
    end
    head :ok
  end

  private
     # Never trust parameters from the scary internet, only allow the white list through.
     def scheduled_location_params
      params.require(:scheduled_location).permit(:next_mow_date, :position)
    end
end
