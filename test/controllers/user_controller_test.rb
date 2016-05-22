require 'test_helper'

class UserControllerTest < ActionController::TestCase

  test "missing user raises exception" do
    assert_raises ActiveRecord::RecordNotFound do
      get :recommendations, username: 'someuser'
    end
  end

  test "users get JSON recommendations" do
    create_test_users
    get :recommendations, username: "X"
    assert_response :success
    expected_result = ActiveSupport::JSON.encode(['Marta', 'Leo'])
    assert_equal expected_result, response.body
  end

  # test "add user" do
  #   post '/users'
  #   assert_response :redirect
  # end
end
