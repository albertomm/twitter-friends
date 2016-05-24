require 'test_helper'

class FriendsControllerTest < ActionController::TestCase

  test "add one friend" do
    # This user already exists because is on a fixture
    username = "friendly_user"

    # Post a friend name to the user friends resource
    friendname = generate_random_username
    post :create, user_name: username, names: friendname

    # The new friend should be present as a user
    assert friend = User.find_by(name: friendname),
      "Friend User wasn't created"

    # The new friend should be present in the user's friends
    user = User.find_by!(name: username)
    assert_includes user.friends, friend

    # The action should redirect to the new friend URL
    assert_created_redirect user_friend_path(user, friend)

    # The new friend URL should contain the friend info
    get :show, user_name: username, name: friendname
    assert_equal friend.to_json, response.body
  end

  test "add many friends and delete" do
    # This user is on a fixture
    username = "friendly_user"
    user = User.find_by(name: username)

    # POST to make the user follow the friends
    names = (0...5).map { generate_random_username }
    post :create, user_name: username, names: names

    # Response should redirect to the user friend list
    assert_response :created

    # The user friend list should contain the added friends
    get :index, user_name: username
    response_decoded = ActiveSupport::JSON.decode(response.body)
    names.each do |name|
      assert friend = User.find_by!(name: name), "Friend User wasn't created."
      friend_decoded = ActiveSupport::JSON.decode(friend.to_json)
      assert_includes response_decoded, friend_decoded
    end

    # Remove a friend
    friend = User.find_by(name: names.first)
    get :destroy, user_name: username, name: friend.name
    assert_response :success
    assert_equal response.body, friend.to_json

    # The friend list shouldn't include the deleted friend
    get :index, user_name: username
    assert_not response.body.include?(friend.name), "The friend is still there."
  end

end
