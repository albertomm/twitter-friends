class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  # Convert Neo4j "invalid record" exception to Error 422
  rescue_from Neo4j::ActiveNode::Persistence::RecordInvalidError do |exception|
    render text: exception.message, status: 422 # "Unprocessable Entity"
  end

  def find_user_by_name
    @user = User.find_by!(name: params[:user_name])
  end

end
