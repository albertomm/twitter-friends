require 'test_helper'

class BasicTest < ActionDispatch::IntegrationTest
  test "the truth" do
    assert true
  end

  test "get recommendations for X" do
    get "/users/X/recommendations"
    assert_response :success
  end

end
