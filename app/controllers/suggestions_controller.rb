class SuggestionsController < ApplicationController

  before_action :find_user_by_name

  # Get friend suggestions for the user
  def show
    user = User.find_by!(name: params[:user_name])
    render json: user.suggest_friends
  end

end
