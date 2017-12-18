module CalendarHelper
  def calendar(date = Date.today, &block)
    Calendar.new(self, date, block).table
  end

  def calendar_week(date = Date.today, &block)
    CalendarWeek.new(self, date, block).table
  end
end