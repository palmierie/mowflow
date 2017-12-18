require 'test_helper'

class CalendarWeekControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get calendar_week_show_url
    assert_response :success
  end

end
