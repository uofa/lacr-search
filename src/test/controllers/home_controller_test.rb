require 'test_helper'

class HomeControllerTest < ActionDispatch::IntegrationTest

  test "should get home page" do
    get "/"
    assert_response :success
    assert_select 'h1', 'Aberdeen Registers'
  end

end
