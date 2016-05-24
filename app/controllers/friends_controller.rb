class FriendsController < ApplicationController

  before_action { @user = User.find_by!(name: params[:user_name]) }

  # Show all the user friends
  def index
    render json: @user.friends
  end

  # Show one of the user friends
  def show
    friend = @user.friends.find_by!(name: params[:name])
    render json: friend
  end

  # Add friends to the user.
  # We accept a single name or a collection
  def create
    # Use different methods for single and multiple creation
    many = params[:names].respond_to? :each
    many ? create_many : create_one
  end

  # Remove a friend from the user
  def destroy
    friend = User.find_by!(name: params[:name])
    @user.unfollow(friend)
    render json: friend
  end

  private

  # Add a single friend to the user
  def create_one
    friend = User.find_or_create_by!(name: params[:names])
    @user.follow(friend)
    redirect_to user_friend_path(@user, friend), status: :created
  end

  # Add multiple friends to the user
  def create_many
    # Get or create the friends
    friends = Set.new(params[:names]).map do |name|
      User.find_or_create_by!({:name => name})
    end

    # Make the user follow the friends
    @user.follow(*friends)
    render nothing: true, status: :created
  end

end
