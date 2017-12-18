class CalendarWeekController < ApplicationController
  def show
    @date = params[:date] ? Date.parse(params[:date]) : Date.today
    @last_mow_by_date = ScheduledLocation.all.group_by(&:date_mowed)
    @next_mow_by_date = ScheduledLocation.all.group_by(&:next_mow_date)
  end
end
