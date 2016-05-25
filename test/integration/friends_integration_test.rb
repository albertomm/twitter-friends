require 'test_helper'

class FriendsIntegrationTest < ActionDispatch::IntegrationTest

  test "add one friend" do
    # Create a user
    username = generate_random_username
    post '/users', {:name => username}
    assert_response :created

    # Follow a friend
    friendname = generate_random_username
    post "/users/#{username}/friends", {:names => friendname}

    # We are redirected to the new friend resource URL
    assert_created_redirect "/users/#{username}/friends/#{friendname}"
    follow_created_redirect
    assert_response :success
  end

  test "add and remove friends" do
    # Create a user
    username = generate_random_username
    post_via_redirect '/users', name: username
    assert_response :success

    # Follow some friends
    friendnames = (0..5).map { generate_random_username }
    post "/users/#{username}/friends", names: friendnames
    assert_response :created

    # The friend list now includes the new friends
    get "/users/#{username}/friends"
    response_json = ActiveSupport::JSON.decode(response.body)
    assert_user_names friendnames

    # Unfollow a friend
    delete "/users/#{username}/friends/#{friendnames[2]}"

    # The friend list shouldn't include the new friends
    get "/users/#{username}/friends/#{friendnames[2]}"
    assert_response :missing
  end

  test "create invalid friend" do
    # Create a user
    username = generate_random_username
    post "/users", name: username
    assert_response :success

    # Reject friend names too long
    friendname = "a_looooooooooooooooooooooooooong_name"
    post "/users/#{username}/friends", name: friendname
    assert_response 422 # "Unprocessable Entity"

    # Reject friend names too short
    post "/users/#{username}/friends", name: ""
    assert_response 422 # "Unprocessable Entity"
  end

end
