class Api::PromotionsController < ApplicationController

  skip_before_filter :verify_authenticity_token
  before_filter :api_login_required

  def index
    @promotions = Promotion.paginate(:page => params[:page])
    render :json => @promotions.map{|p|
      {
        :id => p.id,
        :title => p.title,
        :promotion_url => p.url,
        :img_url => p.upload.exists? ? "#{request.protocol}#{request.host_with_port}" + p.upload.url(:large) : ""
      }
    }    
  end

end
