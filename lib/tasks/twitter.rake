namespace :twitter do
  desc "Update the user friends using the Twitter REST API."
  task :update do
    puts "Running Twitter update task"
    TwitterUpdater.new(verbose: true).run
  end
end
