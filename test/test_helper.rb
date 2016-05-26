ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'securerandom'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  # fixtures :all

  # List of exceptions used to notify a missing record
  NOT_FOUND_EXCEPTIONS = [
    # ActiveRecord::RecordNotFound,
    Neo4j::ActiveNode::Labels::RecordNotFound
  ]

  # List of exceptions used to notify an invalid record
  INVALID_RECORD_EXCEPTIONS = [
    # ActiveRecord::RecordInvalid,
    Neo4j::ActiveNode::Persistence::RecordInvalidError
  ]

  # Create the users mentioned in the requirements example.
  # Self-relations seems to be too complex to use in fixtures.
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
      user = User.find_or_create_by(name: username)
      friends = friendnames.map { |n| User.find_or_create_by(name: n) }
      user.follow!(*friends)
    end

    # Return the expected result
    ['Marta', 'Leo']
  end

  # Assert that the response is the info of the expected users
  def assert_user_names(expected_names)
    users = ActiveSupport::JSON.decode(response.body)
    names = users.map { |user| user.fetch('name') }
    assert_equal expected_names.sort, names.sort
  end

  # Get a random and hopefully unique user name to be used in a test
  def generate_random_username
    SecureRandom.uuid.remove(/\W/).slice(0, 15)
  end

  # Assert that the response code is 201 (REST's "created") and the headers
  # contains a location for the new record. This is useful to assert REST POST
  # responses.
  def assert_created_redirect(location_url)
    assert_response :created
    assert response.headers.key?("Location"), "Location header not found."
    assert response.headers["Location"], location_url
  end

  # Follow a REST "created" redirect.
  # RoR "follow_redirect!" only works with status code 302
  def follow_created_redirect
    assert_response :created
    get response.headers["Location"]
  end

end
