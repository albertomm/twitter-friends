require 'test_helper'

class UserControllerTest < ActionController::TestCase

  test "user X recommendations" do
    get :recommendations
    assert_response :success
    assert_equal "Marta, Leo", response.body
  end

  # test "missing user" do
  #   get '/users/someuser'
  #   assert_response :missing
  # end
  #
  # test "add user" do
  #   post '/users'
  #   assert_response :redirect
  # end
end
