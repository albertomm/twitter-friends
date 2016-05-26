require 'test_helper'

class UserTest < ActiveSupport::TestCase

  test "users have names" do
    assert User.new.respond_to?(:name)
  end

  test "users must have names" do
    assert_raises *INVALID_RECORD_EXCEPTIONS  do
      User.create!()
    end
  end

  test "users have a last updated timestamp" do
    # It defaults to 0
    username = generate_random_username
    user = User.create!(name: username)
    assert_equal DateTime.new(1970), user.last_update

    # It is set to the current time when following someone
    previous_date = user.last_update
    user.follow!(User.create!(name: generate_random_username))
    assert_in_delta Time.now, user.last_update, 1
    assert_not_equal user.last_update, previous_date

    # It updates even following invalid users
    previous_date = user.last_update
    user.follow!(user)
    assert_in_delta Time.now, user.last_update, 1
    assert_not_equal user.last_update, previous_date

    # Is saved automatically
    assert_equal user.last_update.to_i, User.find(user.id).last_update.to_i
  end

  test "users have a level" do
    # User levels are numbered in relation to the distance to a primary user
    assert User::LEVEL_PRIMARY < User::LEVEL_FRIEND
    assert User::LEVEL_FRIEND < User::LEVEL_OTHER

    # It defaults to the most distant value
    user = User.create!(name: generate_random_username)
    assert user.level >= User::LEVEL_OTHER

    # Update the level
    user.level_up(User::LEVEL_OTHER)
    assert_equal user.level, User::LEVEL_OTHER
    user.level_up(User::LEVEL_FRIEND)
    assert_equal user.level, User::LEVEL_FRIEND

    # User level can only get closer
    user.level_up(User::LEVEL_OTHER)
    assert_equal user.level, User::LEVEL_FRIEND

    # User level is not saved automatically
    assert_not_equal user.level, User.find_by(name: user.name).level

    # User level is saved when using the level_up! method (with the bang)
    user.level_up!(User::LEVEL_PRIMARY)
    assert_equal user.level, User::LEVEL_PRIMARY
    assert_equal user.level, User.find_by(name: user.name).level
  end

  test "user names lenght is limited to 15 chars" do
    assert_raises *INVALID_RECORD_EXCEPTIONS  do
      User.create!(name: "a_looooooooooooooooooooong_name")
    end
  end

  test "user names must be unique" do
    username = generate_random_username
    User.create!(name: username)
    assert_raises *INVALID_RECORD_EXCEPTIONS do
      User.create!(name: username)
    end
  end

  test "users can follow other users" do
    assert User.new.respond_to?(:follow!), "User must have add_friend method"

    name1 = generate_random_username
    name2 = generate_random_username

    # Create two test users wich will have 0 friends
    user1 = User.create!(name: name1)
    assert_equal user1.friends.length, 0
    user2 = User.create!(name: name2)
    assert_equal user2.friends.length, 0

    # Now one user follows the other
    user1.follow!(user2)

    # Only the follower must increment its number of friends
    user1 = User.find_by(name: name1)
    assert_equal user1.friends.length, 1
    user2 = User.find_by(name: name2)
    assert_equal user2.friends.length, 0

    # The first user is following the second user
    assert_equal user1.friends.first.id, user2.id
  end

  test "users cannot follow themselves" do
    user = User.create!(name: generate_random_username)
    friends_before = user.friends.length
    user.follow!(user)
    assert_equal friends_before, user.friends.length
  end

  test "user friends are unique" do
    user1 = User.create!(name: generate_random_username)
    user2 = User.create!(name: generate_random_username)

    # Cannot follow the same user twice
    user1.follow!(user2)
    user1.follow!(user2)
    assert_equal 1, user1.friends.length
  end

  test "users get recommendations" do
    expected_result = create_test_users
    result = User.find_by(name: "X").suggest_friends.map { |x| x.name }
    assert_equal expected_result.sort, result.sort
  end

end
