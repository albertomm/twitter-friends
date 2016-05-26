# This is not a model per se, but a generic object that contains the
# logic required to update a user's friends making calls to the Twitter REST API
# Maybe we should call it a service?
class TwitterUpdater

  def initialize
    puts "updater started"
  end

  # Start updating all pending users.
  def run
    while true do
      puts "loop"
      do_update_loop
    end
  end

  # Wait with a countdown
  def countdown(seconds)
    seconds.downto(0).each do |remaining|
      if remaining < 5
        puts remaining
      elsif remaining % 60 == 0
        puts "retrying in #{remaining}"
      end
      sleep 1
    end
  end

  private

  # Main update loop method
  def do_update_loop
    # Get some users ready to be updated
    users = User.get_update_queue(60, 100)

    # Update the users
    users.each do |user|
      puts "updating #{user.name}"
      update_user_friends(user)
    end

    # Wait if the queue is empty
    if users.empty? then
      puts "Queue is empty, sleeping..."
      sleep 60
    end
  end

  # Fetch the user friends from Twitter and add them as friends here
  def update_user_friends(user)
    friends = []
    if user.level <= User::LEVEL_FRIEND then
      puts "Updating user #{user.name} level #{user.level}"
      friendnames = get_twitter_friend_names(user.name)
      friend_level = user.level + 1
      friendnames.each do |name|
        friend = User.find_or_create_by!(name: name)
        friend.level_up!(friend_level)
        friends << friend
      end
    else
      puts "Ignoring user #{user.name} level #{user.level}"
    end
    user.follow!(*friends)
  end

  # Configure and return a Twitter::Client instance
  def get_twitter_client
    twitter_config = {
      consumer_key: Figaro.env.twitter_consumer_key!,
      consumer_secret: Figaro.env.twitter_consumer_secret!,
      bearer_token: Figaro.env.twitter_bearer_token!
    }
    Twitter::REST::Client.new(twitter_config)
  end

  # Fetch the twitter friend names via REST
  def get_twitter_friend_names(username)
    client = get_twitter_client

    # Fetch friend IDS
    friend_ids = begin
      client.friends(username).to_a
    rescue Twitter::Error::TooManyRequests => error
      wait_time = error.rate_limit.reset_in + 10
      puts "RATE LIMIT HIT: Wait #{wait_time}"
      self.countdown(wait_time)
      retry
    end
    puts "  #{friend_ids.length} friend IDs retrieved"

    # Fetch friend data
    friends = begin
      client.users(friend_ids).to_a
    rescue Twitter::Error::TooManyRequests => error
      wait_time = error.rate_limit.reset_in + 10
      puts "RATE LIMIT HIT: Wait #{wait_time}"
      self.countdown(wait_time)
      retry
    end
    puts "  #{friends.length} friends retrieved"

    # Extract the friend names
    friendnames = []
    friends.each do |f|
      puts f.screen_name
      friendnames << f.screen_name
    end
    friendnames
  end

end
