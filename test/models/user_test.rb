require 'test_helper'

class UserTest < ActiveSupport::TestCase

  test "users have names" do
    assert User.new.respond_to?(:name)
  end

  test "users must have names" do
    assert_raises ActiveRecord::RecordInvalid  do
      User.create!({:name => nil})
    end
  end

  test "user names must be unique" do
    User.create!({:name => "some_unique_name"})
    assert_raises ActiveRecord::RecordInvalid do
      User.create!({:name => "some_unique_name"})
    end
  end

  test "users can follow other users" do
    assert User.new.respond_to?(:follow), "User must have add_friend method"

    # Create two test users wich will have 0 friends
    user1 = User.create({:name => 'testuser1'})
    assert_equal user1.friends.length, 0
    user2 = User.create({:name => 'testuser2'})
    assert_equal user2.friends.length, 0

    # Now one user follows the other
    user1.follow(user2)

    # Only the follower must increment its number of friends
    user1 = User.find_by({:name => 'testuser1'})
    assert_equal user1.friends.length, 1
    user2 = User.find_by({:name => 'testuser2'})
    assert_equal user2.friends.length, 0

    # The first user is following the second user
    assert_equal user1.friends.first.id, user2.id
  end

  test "users cannot follow themselves" do
    user = User.create({:name => 'abc'})
    friends_before = user.friends.length
    user.follow(user)
    assert_equal friends_before, user.friends.length
  end
end
