class UsersController < ApplicationController

  def show
    user = User.find_by!({:name => params[:name]})
    render json: user
  end

  def create
    user = User.find_or_create_by({:name => params[:name]})
    redirect_to user_path(user), status: :created
  end

end