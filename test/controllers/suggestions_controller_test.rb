require 'test_helper'

class SuggestionsControllerTest < ActionController::TestCase
  test 'suggest friends' do
    expected_names = create_test_users
    get :show, user_name: 'X'
    assert_response :success
    assert_user_names expected_names
  end
end
