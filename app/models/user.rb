require 'set'

class User

  include Neo4j::ActiveNode

  ## CLASS METHODS

  # Return the users most likely to be needing an update
  def self.get_update_queue(threshold, limit = 10)
    date_min = Time.now.to_i - threshold
    users = User.all(:u)
      .where("u.last_update < {date_min}")
      .params(date_min: date_min)
      .limit(limit)
      .order(:last_update)
  end

  ## PROPERTIES

  # User name
  property :name, type: String, constraint: :unique
  validates :name, presence: true, uniqueness: true, length: {in: (1..15)}

  # User relation level
  LEVEL_PRIMARY = 0    # The user was added to the app explicitly
  LEVEL_FRIEND = 1  # The user was added only as a friend of other
  LEVEL_OTHER = 2   # The user is a friend of a friend
  property :level, type: Integer, default: 100
  validates :level, presence: true

  # Friends
  has_many :out, :friends, model_class: "User", type: "follows"

  # Timestamp of the last friends update
  property :last_update, type: DateTime, default: 0

  ## PUBLIC METHODS

  # Parameter used to create URLs
  def to_param
    return self.name
  end

  # Change the user level if the user is closer (its value is lower)
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
  # DEPRECATED: relational style
  def suggest_friends_relational
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

  # Get recommendations about new friends using Cypher (Neo4j)
  def suggest_friends
    # Retrieve the suggested friend IDs
    friend_ids = Neo4j::Session.current.query
      .match('(user:User {name: "X"})-[:follows]->(friend1:User)-[:follows]->(recommend:User)<--(friend2:User)')
      .where('(user)-[:follows]->(friend2) AND NOT (user)-[:follows]->(recommend)')
      .return('distinct(recommend).uuid as id')
      .to_a.map { |n| n.id }
    # Return the friend objects
    User.find(friend_ids)
  end

end
