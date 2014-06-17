module AuthenticatedSystem
    protected
  
    # Filter method to enforce a login requirement.
    #
    # To require logins for all actions, use this in your controllers:
    #
    #   before_filter :login_required
    #
    # To require logins for specific actions, use this in your controllers:
    #
    #   before_filter :login_required, :only => [ :edit, :update ]
    #
    # To skip this in a subclassed controller:
    #
    #   skip_before_filter :login_required
    #
    def login_required
      username, passwd = get_auth_data
      logged_in? && authorized? ? true : access_denied
    end

    def admin_login_required
      username, passwd = get_auth_data
      logged_in? && admin_authorized? ? true : access_denied
    end

    def api_login_required
      api_logged_in? && authorized? ? true : api_access_denied
    end
    
    # Returns true or false if the user is logged in.
    # Preloads current_user with the user model if they're logged in.
    def logged_in?
      (current_user ? login_access : false).is_a?(User)
    end

    def api_logged_in?
      (current_api_user ? login_from_api_key : false).is_a?(User)
    end
    
    # Check if the user is authorized.
    #
    # Override this method in your controllers if you want to restrict access
    # to only a few actions or if you want to check if the user
    # has the correct rights.
    #
    # Example:
    #
    #  # only allow nonbobs
    #  def authorize?
    #    current_user.login != "bob"
    #  end
    def authorized?
      true
    end

    def admin_authorized?
      current_user.admin?
    end
    
    # Redirect as appropriate when an access request fails.
    #
    # The default action is to redirect to the login screen.
    #
    # Override this method in your controllers if you want to have special
    # behavior in case the user is not authorized
    # to access the requested action.  For example, a popup window might
    # simply close itself.
    
    def access_denied
      puts "access denied"
      respond_to do |accepts|
        accepts.html do
          store_location
          # render :text => "Authentication failed: access denied"
          redirect_to log_in_path
        end
        accepts.json do
          render :json => {:success => false, :message => "Authentication failed"}
        end
        accepts.xml do
          headers["Status"]           = "Unauthorized"
          headers["WWW-Authenticate"] = %(Basic realm="Web Password")
          render :text => "Could't authenticate you", :status => '401 Unauthorized'
        end
      end
      false
    end  

    def api_access_denied
      puts "api access denied"
      render :json => {:success => false, :message => "Authentication failed"}
      false
    end  

    # Store the URI of the current request in the session.
    #
    # We can return to this location by calling #redirect_back_or_default.
    def store_location
      session[:return_to] = request.fullpath
    end
    
    # Redirect to the URI stored by the most recent store_location call or
    # to the passed default.
    def redirect_back_or_default(default)
      session[:return_to] ? redirect_to(session[:return_to]) : redirect_to(default)
      session[:return_to] = nil
    end
    
    # Inclusion hook to make #current_user and #logged_in?
    # available as ActionView helper methods.
    def self.included(base)
      base.send :helper_method, :current_user, :logged_in?
    end

    # When called with before_filter :login_from_cookie will check for an :token
    # cookie and log the user back in if apropriate
    def login_from_cookie
      User.find_by_token!(cookies[:token]) if cookies[:token]
    end
    
    def login_from_api_key
      User.find_by_api_key(params[:api_key]) if params[:api_key]
    end

    def login_from_session
      User.find(session[:user_id]) if session[:user_id]
    end
    
    def login_access
      login_from_api_key || login_from_cookie || login_from_session
    end

    private
    
    def current_user
      begin
        # @current_user ||= User.find(session[:user_id]) if session[:user_id]
        # @current_user ||= User.find_by_token!(cookies[:token]) if cookies[:token]
        @current_user ||= login_access unless @current_user == false
      rescue 
        @current_user = nil
      end      
    end

    def current_api_user
      begin
        # @current_user ||= User.find(session[:user_id]) if session[:user_id]
        # @current_user ||= User.find_by_token!(cookies[:token]) if cookies[:token]
        @current_user ||= login_from_api_key unless @current_user == false
      rescue 
        @current_user = nil
      end      
    end

    # gets BASIC auth info
    def get_auth_data
      user, pass = nil, nil
      # extract authorisation credentials 
      if request.env.has_key? 'X-HTTP_AUTHORIZATION' 
        # try to get it where mod_rewrite might have put it 
        authdata = request.env['X-HTTP_AUTHORIZATION'].to_s.split 
      elsif request.env.has_key? 'HTTP_AUTHORIZATION' 
        # this is the regular location 
        authdata = request.env['HTTP_AUTHORIZATION'].to_s.split  
      end 
   
      # at the moment we only support basic authentication 
      if authdata && authdata[0] == 'Basic' 
        user, pass = Base64.decode64(authdata[1]).split(':')[0..1] 
      end 
      return [user, pass] 
    end
end