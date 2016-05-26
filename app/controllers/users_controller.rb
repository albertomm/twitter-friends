class UsersController < ApplicationController

  before_action only: [:show, :destroy] do
    @user = User.find_by!(name: params[:name])
  end

  def show
    render json: @user
  end

  def create
    @user = User.find_or_create_by!(name: params[:name])
    @user.level_up!(User::LEVEL_PRIMARY)
    redirect_to user_path(@user), status: :created
  end

  def destroy
    @user.destroy
    render nothing: true
  end

end
