class Api::WallController < ApplicationController


  skip_before_filter :verify_authenticity_token
  before_filter :api_login_required

  def index
    host = "#{request.protocol}#{request.host_with_port}" 
    friends_id = []
    friend_user_names = {}
    begin
      response = open("https://graph.facebook.com/me/friends?fields=installed,name&access_token=#{current_user.oauth_token}"){|f|f.read}
      response = JSON.parse(response)
      response["data"].select{|s|s["installed"]}.each{|m|friend_user_names[m["id"]] = m["name"]}

      friends_id = response["data"].select{|s|s["installed"]}.map{|m|m["id"]}
      friends_id = User.select("id").where("uid IN (?)", [0] + friends_id).all.map{|m|m.id}
    rescue Exception => e
      
    end 

    selector = UserFitRoom.where("user_id IN (?)", [0, current_user.id] + friends_id).where("temprary IS NULL OR temprary = ?", false).order("user_fit_rooms.id DESC").paginate(:page => params[:page]).all

    render :json => {
      :total_page => selector.total_pages,
      :walls => selector.map{|wall|
        { 
          :id => wall.id,
          :facebook_id => wall.user.uid,
          :product_id => wall.product_id,
          :is_user_post => wall.user_id == current_user.id,
          :big_wall_img_url => wall.target_image.exists? ? host + wall.target_image.url(:large) : "",
          :medium_wall_img_url => wall.target_image.exists? ? host + wall.target_image.url(:medium) : "",
          :small_wall_img_url => wall.target_image.exists? ? host + wall.target_image.url(:small) : "",
          :timestamp => wall.created_at.to_s,
          :title => wall.title.blank? ? "Look cool with #{wall.product && wall.product.title ? wall.product.title : '...'}" : wall.title, 
          :name => friend_user_names[wall.user.uid].nil? ? current_user.name : friend_user_names[wall.user.uid]
        }
      }
    }
  end

  def show
  end

  def create
    entry = params[:id].blank? ? UserFitRoom.new : current_user.user_fit_rooms.find(params[:id])
    if entry
      entry.assign_attributes(params.permit(:left, :top, :width, :height, :rotation, :color_id, :product_id, :title))
      entry.user_id = current_user.id
    end

    if params[:upload]
      entry.target_image = params[:upload]
      entry.save
    end

    render :json => { :id => entry.id, :product_id => entry.product_id, :color_id => entry.color_id, :image => entry.target_image.url(:large) }    
  end

  def destroy
    entry = current_user.user_fit_rooms.find(params[:id])
    entry.destroy if entry
    render :json => { :status => "success" }
  end
end
