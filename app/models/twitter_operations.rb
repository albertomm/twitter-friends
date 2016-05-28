# Use this class to interact with the Twitter REST API.
# It is mainly used by TwitterUpdater
class TwitterOperations
  def initialize(verbose: false)
    # Print messages about progress
    @verbose = verbose
  end

  # Fetch a user's twitter friend names via Twitter REST API
  def get_twitter_friend_names(username)
    client = get_twitter_client

    # Fetch friend IDS
    friend_ids = handle_rate_limit do
      client.friend_ids(username).to_a
    end

    # Fetch friend data
    friends = handle_rate_limit do
      client.users(friend_ids).to_a
    end

    # Extract the friend names
    friendnames = []
    friends.each do |f|
      friendnames << f.screen_name
    end
    friendnames
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

  # Execute a block taking care of Twitter's rate limits, waiting when necessary
  def handle_rate_limit(&block)
    begin
      block.call
    rescue Twitter::Error::TooManyRequests => error
      wait_time = error.rate_limit.reset_in + 10
      if @verbose
        minutes = wait_time / 60
        puts
        puts "RATE LIMIT HIT: Wait #{minutes} minutes."
      end
      countdown(wait_time)
      retry
    end
  end

  # Wait with a countdown
  def countdown(seconds)
    seconds.downto(0).each do |remaining|
      if remaining <= 5
        puts " #{remaining} " if @verbose
      elsif remaining % 60 == 0
        minutes = remaining / 60
        puts "Retrying in #{minutes} minutes..." if @verbose
      end
      sleep 1
    end
  end
end
