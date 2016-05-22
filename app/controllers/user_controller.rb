class UserController < ApplicationController

  def create
    user = User.find_or_create_by({:name => params[:username]})
    render text: user.name
  end

  def add_friends
    user = User.find_by!({:name => params[:username]})
    friends = params[:friendnames].map do |friendname|
      User.find_or_create_by({:name => friendname})
    end
    user.follow(*friends)
    render json: user.friends.map {|f| f.name}
  end

  def recommendations
    user = User.find_by!({:name => params[:username]})
    suggested_names = user.suggest_friends.collect {|f| f.name}
    render json: suggested_names
  end

end
