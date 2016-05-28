class SuggestionsController < ApplicationController
  before_action :find_user_by_name

  # Get friend suggestions for the user
  def show
    render json: @user.suggest_friends
  end
end
