class Admin::ModeratorsController < ApplicationController
  layout 'admin'
  before_filter :admin_login_required

  def source
    source = User.where("admin = ?", true)
    source = source.where("name LIKE ? OR email LIKE ?", "%#{params[:search]}%", "%#{params[:search]}%") unless params[:search].blank?
    source
  end

  def index
    @controller_name = "Admins"
    @entries = self.source.paginate(:page => params[:page])
  end

  def update
    @entry = User.find(params[:id])
    if @entry
      @entry.admin = true
      @entry.save
    end

    redirect_to admin_moderators_url
  end

  def destroy
    @entry = User.find(params[:id])
    if @entry
      @entry.admin = false
      @entry.save
    end

    redirect_to admin_moderators_url
  end

end
