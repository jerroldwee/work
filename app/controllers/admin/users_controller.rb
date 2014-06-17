class Admin::UsersController < ApplicationController
  layout 'admin'
  before_filter :admin_login_required

  def source
    source = User
    source = source.where("name LIKE ? OR email LIKE ?", "%#{params[:search]}%", "%#{params[:search]}%") unless params[:search].blank?
    source
  end

  def index
    @controller_name = "Users"
    @entries = self.source.paginate(:page => params[:page])

    if params[:json]
      render :json => @entries 
      return
    end
  end
  
  def photos
    @controller_name = "Photos"
    @user = User.find_by_id(params[:id].to_i)
    @entries = @user.user_fit_rooms.where("(temprary IS NULL OR temprary = ?) AND facebook_post_id IS NOT NULL", false)
    @entries = @entries.where("title LIKE ?", "%#{params[:search]}%") unless params[:search].blank?
    @entries.paginate(:page => params[:page])
    
    if params[:json]
      render :json => @entries 
      return
    end
  end

end
