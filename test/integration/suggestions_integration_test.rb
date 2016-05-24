require 'test_helper'

class SuggestionsIntegrationTest < ActionDispatch::IntegrationTest

  test "users get friend suggestions" do
    expected_names = create_test_users
    get "/users/X/suggestions"
    assert_response :success
    assert_user_names expected_names
  end

end
