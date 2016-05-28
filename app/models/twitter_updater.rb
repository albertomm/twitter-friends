# This is not a model per se, but a generic object that contains the
# logic required to update a user's friends making calls to the Twitter REST API
# Maybe we should call it a service?
class TwitterUpdater
  def initialize(verbose: false, threshold: 60 * 60 * 24, batch_size: 100)
    # Print information
    @verbose = verbose

    # Select only users wich haven't been update in at least X seconds
    @threshold = threshold

    # How many users to update each loop
    @batch_size = batch_size

    if @verbose
      puts
      puts '==============='
      puts 'Twitter Updater'
      puts '==============='
      puts
    end

    # Twitter Operations helper
    @ops = TwitterOperations.new verbose: @verbose
  end

  # Start updating all pending users.
  def run
    loop do
      do_update_loop @threshold, @batch_size
    end
  end

  # Main update loop method
  def do_update_loop(threshold, batch_size)
    # Get some users ready to be updated
    users = UpdateQueue.get_first_users(threshold, batch_size)
    if @verbose
      puts
      puts "Got #{users.length} from the queue."
    end

    # Update the users
    users.each do |user|
      update_twitter_friends(user)
    end

    # Wait if the queue is empty
    if users.empty?
      if @verbose
        puts
        puts 'Queue is empty, sleeping...'
        puts
      end
      sleep 60
    end
  end

  # Fetch the user friends from Twitter and add them as friends here
  def update_twitter_friends(user)
    puts " -> Updating user #{user.name} level #{user.level}"
    begin
      friend_names = @ops.get_twitter_friend_names(user.name)
    rescue Twitter::Error::NotFound
      puts "  ! User #{user.name} doesn't exist in Twitter." if @verbose
      user.destroy
      return
    end
    update_user_friend_list(user, friend_names)
  end

  # Gien a friend name list, add these as friends and remove the non existent
  def update_user_friend_list(user, friend_names)
    # Not important, but helps debugging
    friend_names.sort!

    # Remove the missing friends
    user.friends.each do |friend|
      unless friend_names.include?(friend.name)
        puts "  --- #{user.name} is no longer following #{friend.name}" if @verbose
        user.unfollow(friend)
      end
    end

    # Add the new friends
    friend_level = user.level + 1
    friends = []
    friend_names.each do |name|
      friend = User.find_or_create_by!(name: name)
      friend.level_up!(friend_level)
      unless user.friends.include?(friend)
        puts "  +++ #{user.name} is now following #{name}" if @verbose
        friends << friend
      end
    end
    user.follow!(*friends)
  end
end
