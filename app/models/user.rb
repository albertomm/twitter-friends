require 'set'

class User < ActiveRecord::Base

  def self.update_queue(threshold, limit = 10)
    date_min = Time.now - threshold
    User.all.where("last_update < ?", date_min).order(:last_update).limit(limit)
  end

  # Requires a unique name
  validates :name,
    presence: true,
    uniqueness: true,
    length: {in: (1..15)} # Twitter limits

  # A User has N friends wich are also Users
  has_and_belongs_to_many :friends,
    join_table: :follows,
    class_name: 'User',
    foreign_key: :user_id,
    association_foreign_key: :friend_id

  # Parameter used to create URLs
  def to_param
    return self.name
  end

  # Follow other users that become friends
  def follow(*friends)
    updated = false
    friends.each do |friend|
      # Fail for unsaved users
      fail 'friend.id is nil' if friend.id.nil?
      # The user cannot follow itself
      next if friend.name == self.name
      self.friends.push(friend)
      updated = true
    end
    # Set the last_update time only if something changed
    if updated then
      self.last_update = Time.now
      self.save
    end
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
