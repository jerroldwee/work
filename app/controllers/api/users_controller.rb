require 'open-uri'

class Api::UsersController < ApplicationController

  before_filter :api_login_required, :only => :invite_friends

  skip_before_filter :verify_authenticity_token

  def login
    begin
      data = open("https://graph.facebook.com/me?access_token=#{params[:oauth_token]}"){|f|f.read}
    rescue
      data = "{}"
    end
    info = JSON.parse(data)
    if info["id"] && info["email"] == params[:email]
      user_exists = User.where("uid = ?", info["id"]).first
      u = User.where("uid = ?", info["id"]).first_or_create
            
      #  "{\"id\":\"100006700179891\",\"name\":\"Lian Shu\",\"first_name\":\"Lian\",\"last_name\":\"Shu\",\"link\":\"https:\\/\\/www.facebook.com\\/lian.shu.mark\",\"username\":\"lian.shu.mark\",\"gender\":\"female\",\"email\":\"facebook\\u0040appcepted.com\",\"timezone\":8,\"locale\":\"en_US\",\"verified\":true,\"updated_time\":\"2013-09-30T04:17:36+0000\"}"
      
      u.provider = "facebook"
      u.uid = info["id"]
      u.name = info["name"]
      u.email = info["email"]
      u.username = info["username"]
      u.oauth_token = params["oauth_token"]
      u.save!

      u.enable_api!
      u.save!

      render :json => { 
        :id => u.id,
        :credits => 0,
        :wall_count => u.user_fit_rooms.where("temprary IS NULL OR temprary = ?", false).count,
        :profile_url => "https://www.facebook.com/profile.php?id=#{u.uid}",
        :website_url => user_url(u, :only_path => false),
        :api_key => u.api_key
      }
    else
      render :json => {
        :error => "Unauthorized Access"
      }
    end

  end

  def invite_friends
    if current_user
      params[:uids].each{|uid|
        unless InvitationRecord.where("to_uid = ?", uid).first
          info = {}
          begin
            info = JSON.parse(open("https://graph.facebook.com/#{params[:request_id]}_#{uid}?access_token=#{current_user.oauth_token}"){|f|f.read})
          rescue
          end
          if info["to"] && info["id"]
            InvitationRecord.create({ :to_uid => uid, :from_uid => current_user.uid })
            CreditReward.create({ :user_id => current_user.id, :description => "#{current_user.name} invited #{info["to"]["name"]}", :total => 2, :reward_type => "Facebook Invitation" })
            current_user.update_total_credit
            current_user.save

            render :json => { :total_credit => "#{current_user.total_credit} credits" }
            return
          end
        end
      }
    end

    render :json => { :error => "No credit added" }
  end
end
