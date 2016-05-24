require 'test_helper'

class UserIntegrationTest < ActionDispatch::IntegrationTest

  test "get missing user returns 404" do
    get "/users/#{generate_random_username}"
    assert_response :missing
  end

  test "create a user by posting the name" do
    # Post a new user name
    username = generate_random_username
    post "/users", name: username

    # The response sould be a redirect to the User's URL
    assert_created_redirect "/users/#{username}"
    follow_created_redirect
    assert_response :success

    # The User's URL should display the username
    json = ActiveSupport::JSON.decode(response.body)
    assert json.key?('name'), "Response doesn't contain a name."
    assert_equal json.fetch('name'), username
  end

  test "create invalid user" do
    # Reject user names too long
    username = "a_looooooooooooooooooooong_name"
    post "/users", name: username
    assert_response 422 # "Unprocessable Entity"

    # Reject user names too short
    post "/users", name: ""
    assert_response 422 # "Unprocessable Entity"
  end

end
