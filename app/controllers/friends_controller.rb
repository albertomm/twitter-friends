class FriendsController < ApplicationController

  # Show all the user friends
  def index
    user = User.find_by!(name: params[:user_name])
    render json: user.friends
  end

  # Show one of the user friends
  def show
    user = User.find_by!(name: params[:user_name])
    friend = user.friends.find_by!({:name => params[:name]})
    render json: friend
  end

  # Add friends to the user.
  # We accept a single name or a collection
  def create
    multi = params[:names].respond_to? :each
    multi ? create_multi : create_one
  end

  # Remove a friend from the user
  def destroy
    user = User.find_by!(name: params[:user_name])
    friend = User.find_by!(name: params[:name])
    user.friends.delete(friend)
    render json: friend
  end

  private

  # Add a single friend to the user
  def create_one
    user = user = User.find_by!(name: params[:user_name])
    friend = User.find_or_create_by(name: params[:names])
    user.follow(friend)
    redirect_to user_friend_path(user, friend), status: :created
  end

  # Add multiple friends to the user
  def create_multi
    user = User.find_by!(name: params[:user_name])

    # Get or create the friends
    friends = Set.new(params[:names]).map do |name|
      User.find_or_create_by({:name => name})
    end

    # Make the user follow the friends
    user.follow(*friends)
    render nothing: true, status: :created
  end

  # # Render the names of the sugested new friends for the user
  # def recommendations
  #   user = User.find_by!({:name => params[:username]})
  #   suggested_names = user.suggest_friends.collect {|f| f.name}
  #   render json: suggested_names
  # end
end
