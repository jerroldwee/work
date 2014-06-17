class UsersController < ApplicationController
  before_filter :login_required, :only => [:edit, :delete_wall]

  def index
    redirect_to "/"
  end

  def show
    @user = User.where(:id => params[:id]).first
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(params.require(:user).permit(:email, :username, :password, :password_confirmation))
    if @user.save
      redirect_to log_in_path, :notice => "Signed up!"
    else
      render "new"
    end
  end

  def edit
    @user = current_user
  end

  def visual_try_on
    @products = Product.where("gender = ?", "Male").paginate(:page => params[:page])
  end

  def update
    @user = current_user

    if @user.update(params.require(:user).permit(:name, :nric, :email, :username))
      redirect_to edit_user_path(@user), notice: 'Profile was successfully updated.'
    else
      render action: 'edit'
    end    
  end

  def delete_wall
    @entry = current_user.user_fit_rooms.find(params[:id])
    @entry.destroy if @entry
    render :json => { :success => 1 }
  end

end
