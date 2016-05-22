require 'test_helper'

class UserIntegrationTest < ActionDispatch::IntegrationTest

  test "missing user returns 404" do
    get '/users/someuser/recommendations'
    assert_response :missing
  end

  test "users get JSON recommendations" do
    create_test_users
    get '/users/X/recommendations'
    assert_response :success
    expected_body = ActiveSupport::JSON.encode(expected_result)
    assert_equal expected_body, response.body
  end

  # test "add user" do
  #   post '/users'
  #   assert_response :redirect
  # end

end
