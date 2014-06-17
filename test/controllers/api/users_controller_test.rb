require 'test_helper'

class Api::UsersControllerTest < ActionController::TestCase
  test "should get login" do
    get :login
    assert_response :success
  end

  test "should get invite_friends" do
    get :invite_friends
    assert_response :success
  end

end
