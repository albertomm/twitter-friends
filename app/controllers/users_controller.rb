class UsersController < ApplicationController
  # Load the User specified by the URL parameter
  before_action only: [:show, :destroy] do
    @user = User.find_by!(name: params[:name])
  end

  # Show the User information
  def show
    render json: @user
  end

  # Create a new User
  def create
    @user = User.find_or_create_by!(name: params[:name])
    @user.level_up!(User::LEVEL_PRIMARY)
    redirect_to user_path(@user), status: :created
  end

  # Delete the specified User
  def destroy
    @user.destroy
    render nothing: true
  end
end
