class User

  include Neo4j::ActiveNode

  ## PROPERTIES

  # User name
  property :name, type: String, constraint: :unique
  validates :name, presence: true, uniqueness: true, length: {in: (1..15)}

  # User relation level. This is to prevent crawling all twitter users.
  LEVEL_PRIMARY = 0 # The user was added to the app explicitly
  LEVEL_FRIEND = 1  # The user was added because friend of a primary user
  LEVEL_OTHER = 2   # The user is a friend of a friend, crawling stops here
  property :level, type: Integer, default: LEVEL_OTHER
  validates :level, presence: true

  # Friends
  has_many :out, :friends, model_class: "User", type: "follows"

  # Timestamp of the last friends update
  property :last_update, type: DateTime, default: 0

  ## PUBLIC METHODS

  # Get the parameter used to create resource URLs
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

  # Add other users as friends, will update itself.
  def follow!(*friends)
    friends.uniq!
    friends.delete(self)
    friends -= self.friends
    self.friends << friends
    self.last_update = Time.now
    self.save!
  end

  # Remove a user from the friend list
  def unfollow(friend)
    self.friends.delete(friend)
  end

  # Get recommendations about new friends
  def suggest_friends
    # Retrieve the suggested friend IDs
    friend_ids = Neo4j::Session.current.query
      .match('(user:User {name: {name}})-[:follows]->(friend1:User)-[:follows]->(recommend:User)<--(friend2:User)')
      .params(name: self.name)
      .where('(user)-[:follows]->(friend2) AND NOT (user)-[:follows]->(recommend)')
      .return('distinct(recommend).uuid as id')
      .to_a.map { |n| n.id }
    # Return the friend objects
    # TODO: use only one query to get all users
    friend_ids.map {|uuid| User.find(uuid)}
  end

end
