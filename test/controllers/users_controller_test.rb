require 'test_helper'

class UsersControllerTest < ActionController::TestCase

  test "get missing user raises exception" do
    assert_raises ActiveRecord::RecordNotFound do
      get :show, name: generate_random_username
    end
  end

  test "create user" do
    # Create a user in the database by POSTing its name
    username = generate_random_username
    post :create, name: username
    assert user = User.find_by(name: username), 'User not created'

    # Users created explicitly have the corresponding level
    assert_equal User::LEVEL_PRIMARY, user.level

    # The response should be a redirection to the User URL
    assert_response :created
    assert_created_redirect user_path(user)

    # The resource URL contains the new user info
    get :show, name: user.name
    assert_equal response.body, user.to_json
  end

  test "create invalid user" do
    username = "a_looooooooooooooooooooong_name"
    assert_raises ActiveRecord::RecordInvalid do
      post :create, name: username
    end
  end

end
