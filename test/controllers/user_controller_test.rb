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

  test "create user" do
    post :create, username: 'newUser'
    assert_response :success
    assert User.find_by!({:name => 'newUser'})
  end

  test "add friends" do
    username = 'friendlyuser'
    friendnames = ['friendone', 'friendtwo']
    postdata = {:friendnames => friendnames}
    post :create, {:username => username}
    post :add_friends, {:username => username, :friendnames => friendnames}
    expected_body = ActiveSupport::JSON.encode(friendnames)
    assert_equal response.body, expected_body
  end
end
