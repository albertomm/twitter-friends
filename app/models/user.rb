require 'set'

class User < ActiveRecord::Base

  # CLASS METHODS

  def self.update_queue(threshold, limit = 10)
    date_min = Time.now - threshold
    User.all.where("last_update < ?", date_min).order(:last_update).limit(limit)
  end

  # FIELDS

  # User name
  validates :name,
    presence: true,
    uniqueness: true,
    length: {in: (1..15)} # Twitter limits

  # User relation level
  LEVEL_PRIMARY = 0    # The user was added to the app explicitly
  LEVEL_FRIEND = 1  # The user was added only as a friend of other
  LEVEL_OTHER = 2   # The user is a friend of a friend

  validates :level,
    presence: true

  # A User has N friends wich are also Users
  has_and_belongs_to_many :friends,
    join_table: :follows,
    class_name: "User",
    foreign_key: :user_id,
    association_foreign_key: :friend_id

  # Parameter used to create URLs
  def to_param
    return self.name
  end

  # PUBLIC METHODS

  # Change the user level if the new level is closer
  def level_up(new_level)
    old_level = self.level
    if new_level < self.level then
      self.level = new_level
    end
    self.level != old_level
  end

  # Same as :level_up but saves the User if the level has changed
  def level_up!(*args)
    if self.level_up(*args) then
      self.save!
    end
  end

  # Add other users as friends
  def follow(*friends)
    friends.each do |friend|
      # Ignore nil friends
      next if friend.nil?
      next if friend.id.nil?
      # The user cannot follow itself
      next if friend.name == self.name
      # Don't add duplicates
      next if self.friends.include?(friend)
      self.friends << friend
      updated = true
    end
    # Set the last_update time
    self.last_update = Time.now
    self.save!
  end

  # Remove a user from the friend list
  def unfollow(friend)
    self.friends.delete(friend)
  end

  # Get recommendations about new friends
  def suggest_friends
    candidates = Set.new # Users followed by friends
    result = Set.new
    self.friends.each do |friend|
      friend.friends.each do |candidate|
        # Ignore users already followed
        next if friends.include? candidate
        # If the candidate is repeated it can be suggested
        if candidates.add?(candidate).nil?
          result.add(candidate)
        end
      end
    end
    result.to_a
  end

end
