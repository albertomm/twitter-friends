class UserController < ApplicationController

  def recommendations
    user = User.find_by!({:name => params[:username]})
    suggested_names = user.suggest_friends.collect {|f| f.name}
    render json: suggested_names
  end

end
