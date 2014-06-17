require 'test_helper'

class Api::ProductsControllerTest < ActionController::TestCase
  test "should get product_types" do
    get :product_types
    assert_response :success
  end

  test "should get show" do
    get :show
    assert_response :success
  end

  test "should get index" do
    get :index
    assert_response :success
  end

end
