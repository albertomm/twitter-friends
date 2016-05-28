require 'test_helper'

class UpdateQueueTest < ActiveSupport::TestCase
  test 'get first users' do
    # Delete all users created by fixtures and other tests
    User.delete_all

    # Create user randomly with a range of 'last_update's
    expected_users = (0...10).to_a.shuffle.map do |n|
      name = generate_random_username
      User.create!(
        name: name,
        level: User::LEVEL_PRIMARY,
        last_update: Time.now - n * 100 - 1
      )
    end

    # Expect the users sorted by last_udpate
    expected_users.sort_by! { |u| u.last_update.to_i }

    # Test result order
    assert_equal expected_users, Array(UpdateQueue.get_first_users(0, 1000))
    # Test result size limit
    assert_equal expected_users[0, 5], Array(UpdateQueue.get_first_users(0, 5))
    # Test result threshold
    assert_equal expected_users[0...-4], Array(UpdateQueue.get_first_users(350, 10))
    assert_equal expected_users[0...-7], Array(UpdateQueue.get_first_users(650, 10))
  end
end
