require 'test_helper'

class TwitterUpdaterTest < ActiveSupport::TestCase

  test "update user friend list" do
    updater = TwitterUpdater.new verbose: false

    # Create a new primary user
    user = User.create(
      name: generate_random_username,
      level: User::LEVEL_PRIMARY
    )

    # Add random friends
    friend_names = Array.new(10) { generate_random_username }
    updater.update_user_friend_list(user, friend_names)
    assert_equal friend_names.sort, user.friends.map {|f| f.name }.sort
      "New friends aren't the ones requested"

    # The new friends must have the correct levels
    expected_levels = Array.new(friend_names.length, User::LEVEL_FRIEND)
    assert_equal expected_levels, user.friends.map {|f| f.level },
      "New friends have the wrong levels"

    # Updating with a subgroup should remove some of the users
    updated_names = friend_names[0...-2]
    updater.update_user_friend_list(user, updated_names)
    assert_equal updated_names.sort, user.friends.map {|f| f.name }.sort,
      "Updated friends aren't the ones requested"

    # Updating with a group of mixed known and unknow friends
    updated_names = friend_names[3..-3] # Remove some friend names
    updated_names.push *Array.new(3) { generate_random_username } # Add some new
    updater.update_user_friend_list(user, updated_names)
    assert_equal updated_names.sort, user.friends.map {|f| f.name }.sort,
      "Updated friends aren't the ones requested"
  end

end
