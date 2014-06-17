require 'open-uri'

class FacebookController < ApplicationController
  layout false
  skip_before_filter :verify_authenticity_token
  skip_before_filter :detect_facebook_post!

  def details
    render :json => {
      :app_id => FACEBOOK["client_id"],
      :host => APP["host"]
    }
  end

  def channel
    cache_expire = 1.year
    response.headers["Pragma"] = "public"
    response.headers["Cache-Control"] = "max-age=#{cache_expire.to_i}"
    response.headers["Expires"] = (Time.now + cache_expire).strftime("%d %m %Y %H:%I:%S %Z")
    render :layout => false, :inline => "<script src='//connect.facebook.net/en_US/all.js'></script>"
  end

  def invited
    if current_user
      params[:to].split(',').each{|uid|
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

  def posted
    if current_user
      fit_room = UserFitRoom.where("id = ?", params[:wall_id]).first
      if fit_room && fit_room.facebook_post_id.nil?
        unless UserFitRoom.where("facebook_post_id = ?", params[:post_id]).first
          info = {}
          begin
            info = JSON.parse(open("https://graph.facebook.com/#{params[:post_id]}?access_token=#{current_user.oauth_token}"){|f|f.read})
          rescue
          end
          if info["from"] && info["id"] && info["from"]["id"] == current_user.uid && !info["link"].index("figo").nil?
            fit_room.facebook_post_id = params[:post_id]
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

end
