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

  test "add user" do
    get '/users/added_user/recommendations'
    assert_response :missing

    post '/users', username: 'added_user'
    assert_response :success

    get '/users/added_user/recommendations'
    assert_response :success
  end

  test "add friend" do
    username = 'friendly_user'
    post '/users', username: username
    assert_response :success

    friendnames = ['friendly1', 'friendly2']
    post "/users/#{username}/friends", {:username => "some_friend", :friendnames => friendnames}
    assert_response :success
    response_json = ActiveSupport::JSON.decode(response.body)
    assert_equal friendnames, response_json
  end

end
