class CalendarController < ApplicationController
  def show
    @date = params[:date] ? Date.parse(params[:date]) : Date.today
    puts "@date #{@date}"
    @jobs_by_date = ScheduledLocation.all.group_by(&:date_mowed)
    puts "idk what this is: #{@jobs_by_date}"
    puts "jobs_by_date[@date] : #{@jobs_by_date[@date]}"
  end
end
