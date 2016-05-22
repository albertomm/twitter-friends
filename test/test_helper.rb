ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  def create_test_users
    testdata = {
      'X' => ['Laura', 'Pepe', 'Manuel'],
      'Laura' => ['Pepe', 'Marta', 'María'],
      'Pepe' => ['Leo', 'Laura', 'Marta', 'Juan'],
      'Manuel' => ['Leo', 'Pepe', 'Sergio', 'Víctor'],
    }

    # Create the test users and relations
    users = {}
    testdata.each do |username, friendnames|
      # Get or create the user
      user = users[username] = users.key?(username) ? users.fetch(username) : User.create({:name => username})
      # Get or create the friends
      friendnames.each do |n|
        users[n] = users.key?(n) ? users.fetch(n) : User.create({:name => n})
      end

      # Make the user follow the friends
      friends = friendnames.map {|n| users.fetch(n)}
      user.follow(*friends)
    end
  end

  def expected_result
    ['Marta', 'Leo']
  end

  def assert_contained(a1, a2)
    a2.all? { |e| a1.include?(e) }
  end

  # Add more helper methods to be used by all tests here...
end
