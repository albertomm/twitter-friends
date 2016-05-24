require 'test_helper'

class SuggestionsControllerTest < ActionController::TestCase

    test "users get JSON recommendations" do
      expected_result = create_test_users
      get :recommendations, username: "X"
      assert_response :success
      expected_json = ActiveSupport::JSON.encode(expected_result)
      assert_equal expected_result, response.body
    end
    
end
