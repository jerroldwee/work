require 'test_helper'

class Api::CreditsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
  end

  test "should get wall" do
    get :wall
    assert_response :success
  end

  test "should get first_login" do
    get :first_login
    assert_response :success
  end

end
