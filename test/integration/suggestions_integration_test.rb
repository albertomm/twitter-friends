require 'test_helper'

class SuggestionsIntegrationTest < ActionDispatch::IntegrationTest

  test "users get JSON recommendations" do
    expected_result = create_test_users
    get '/users/X/recommendations'
    assert_response :success
    expected_body = ActiveSupport::JSON.encode(expected_result)
    assert_equal expected_body, response.body
  end
  
end
