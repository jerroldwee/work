class Api::CreditsController < ApplicationController

  skip_before_filter :verify_authenticity_token
  before_filter :api_login_required

  def index
    if current_user
      render :json => { :credits => current_user.total_credit }
      return
    end
    render :json => { :error => "No user found" }
  end

  def wall
    if current_user
      fit_room = UserFitRoom.where("id = ?", params[:wall_id]).first
      if fit_room && fit_room.facebook_post_id.nil?
        unless UserFitRoom.where("facebook_post_id = ?", params[:facebook_post_id]).first
          info = {}
          begin
            info = JSON.parse(open("https://graph.facebook.com/#{params[:facebook_post_id]}?access_token=#{current_user.oauth_token}"){|f|f.read})
          rescue
          end
          if info["from"] && info["id"] && info["from"]["id"] == current_user.uid # && !info["link"].index("figo").nil?
            fit_room.facebook_post_id = params[:facebook_post_id]
            fit_room.save

            CreditReward.create({ :user_id => current_user.id, :description => "#{current_user.name} posted on facebook wall #{fit_room.target_image.url(:large)}", :total => 3, :reward_type => "Facebook Post" })
            current_user.update_total_credit
            current_user.save

            render :json => { :total_credit => "#{current_user.total_credit} credits" }
            return
          end
        end
      end
    end    

    render :json => { :error => "No credit added" }
  end

  def first_login
    if current_user
      unless CreditReward.where(:user_id => current_user.id, :reward_type => "App Login").first
        CreditReward.create({ :user_id => current_user.id, :description => "#{current_user.name} first logged in from app", :total => 10, :reward_type => "App Login" })
        current_user.update_total_credit
        current_user.save
      end
    end
  end

  # check request
  # https://graph.facebook.com/#{request.id}?access_token=#{current_user.oauth_token}

end
