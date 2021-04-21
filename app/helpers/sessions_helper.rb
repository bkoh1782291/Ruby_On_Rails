module SessionsHelper

  # logs in current user
  def log_in(user)
    session[:user_id] = user.id
    # guarding against session attacks
    session[:session_token] = user.session_token
  end

  # stores the current user in a persistent session
  def remember(user)
    user.remember
    cookies.permanent.encrypted[:user_id] = user.id
    cookies.permanent[:remember_token] = user.remember_token
  end

  # returns the current user if logged in
  def current_user
    # if user_id equals session id
    if (user_id = session[:user_id])
      @current_user ||= User.find_by(id: user_id)
      # @current_user ||= user if session[:session_token] == session[:user_id]
    # if user_id matches encrypted cookie
    elsif (user_id = cookies.encrypted[:user_id])
      user = User.find_by(id: user_id)
      if user && user.authenticated?(:remember, cookies[:remember_token])
        log_in user
        @current_user = user
      end
    end
  end
  
  # Returns true if the given user is the current user
  def current_user?(user)
    user && user == current_user
  end

  # store the location of the URL to be accessed
  def store_url_location
    session[:forwarding_url] = request.original_url if request.get?
  end

  # returns true if the user is logged in, false otherwise
  def logged_in?
    !current_user.nil?
  end

  def forget(user)
    user.forget
    cookies.delete(:user_id)
    cookies.delete(:remember_token)
  end

  def log_out
    forget(current_user)
    reset_session
    @current_user = nil
  end
end
