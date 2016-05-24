require 'test_helper'

class UserTest < ActiveSupport::TestCase

  test "users have names" do
    assert User.new.respond_to?(:name)
  end

  test "users must have names" do
    assert_raises ActiveRecord::RecordInvalid  do
      User.create!()
    end
  end

  test "users have a last updated timestamp" do
    # It defaults to 0
    username = generate_random_username
    user = User.create!(name: username)
    assert_not user.last_update

    # It doesn't update when following invalid Users
    user.follow(user)
    assert_not user.last_update

    # It is set to the current time when following someone
    user.follow(User.create!(name: generate_random_username))
    assert_in_delta Time.now, user.last_update, 1
  end

  test "user update queue" do
    # Delete all users created by fixtures
    User.all.delete_all

    # Create user randomly with a range of 'last_update's
    expected_users = (0...10).to_a.shuffle.map do |n|
      name = generate_random_username
      User.create!(name: name, last_update: Time.now - n * 100)
    end

    # Expect the users sorted by last_udpate
    expected_users.sort_by! { |u| u.last_update.to_i }

    # Test result order
    assert_equal expected_users[0...-1], Array(User.update_queue(0, 1000))
    # Test result size limit
    assert_equal expected_users[0,5], Array(User.update_queue(0, 5))
    # Test result threshold
    assert_equal expected_users[0...-4], Array(User.update_queue(350, 10))
    assert_equal expected_users[0...-7], Array(User.update_queue(650, 10))
  end

  test "user names lenght is limited to 15 chars" do
    assert_raises ActiveRecord::RecordInvalid do
      User.create!(name: "a_looooooooooooooooooooong_name")
    end
  end

  test "user names must be unique" do
    username = generate_random_username
    User.create!(name: username)
    assert_raises ActiveRecord::RecordInvalid do
      User.create!(name: username)
    end
  end

  test "users can follow other users" do
    assert User.new.respond_to?(:follow), "User must have add_friend method"

    # Create two test users wich will have 0 friends
    user1 = User.create(name: "testuser1")
    assert_equal user1.friends.length, 0
    user2 = User.create(name: "testuser2")
    assert_equal user2.friends.length, 0

    # Now one user follows the other
    user1.follow(user2)

    # Only the follower must increment its number of friends
    user1 = User.find_by(name: "testuser1")
    assert_equal user1.friends.length, 1
    user2 = User.find_by(name: "testuser2")
    assert_equal user2.friends.length, 0

    # The first user is following the second user
    assert_equal user1.friends.first.id, user2.id
  end

  test "users cannot follow themselves" do
    user = User.create(name: "abc")
    friends_before = user.friends.length
    user.follow(user)
    assert_equal friends_before, user.friends.length
  end

  test "users get recommendations" do
    expected_result = create_test_users
    result = User.find_by(name: "X").suggest_friends.map { |x| x.name }
    assert_equal expected_result, result
  end

end
