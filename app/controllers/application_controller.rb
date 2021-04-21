class ApplicationController < ActionController::Base
  include SessionsHelper

  private
  
  #confirms a logged in user
  def logged_in_user
    unless logged_in?
      store_url_location
      flash[:danger] = "Please Log In."
      redirect_to login_url
    end
  end
end
