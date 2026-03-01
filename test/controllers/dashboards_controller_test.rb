require "test_helper"

class DashboardsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get dashboards_index_url
    assert_response :success
  end

  test "should get show" do
    get dashboards_show_url
    assert_response :success
  end
end
