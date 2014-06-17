class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  after_action :allow_iframe

  include AuthenticatedSystem

  private

  def allow_iframe
    response.headers.except! 'X-Frame-Options'
  end

  # def current_user
  #   @current_user ||= User.find(session[:user_id]) if session[:user_id]
  # end
  # helper_method :current_user
  
end
