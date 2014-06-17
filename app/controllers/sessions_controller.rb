class SessionsController < ApplicationController
  def new

  end

  def create
    if params[:code]
      user = User.from_omniauth(env["omniauth.auth"])
      session[:user_id] = user.id

      # redirect_to root_url
      redirect_back_or_default(user_path(user))
    else
      user = User.find_by_email(params[:email])
      if user && User.authenticate(params[:email], params[:password])
        if params[:remember_me]
          cookies.permanent[:token] = user.token
        else
          cookies[:token] = user.token
        end
        redirect_back_or_default(user_path(user))
      else
        flash.now.alert = "Invalid email or password"
        render "new"
      end
    end
  end

  def destroy
    session[:user_id] = nil
    cookies.delete(:token)
    redirect_back_or_default root_url
  end
end
