class PagesController < ApplicationController
  
  skip_before_filter :verify_authenticity_token

  def index
    @with_bg = "with-bg"
  end

  def comingsoon
    @with_bg = "with-bg"
    @comingsoon = true
  end

  def faq
    @faq = 'active'
  end

  def philosophy
    @philosophy = 'active'
  end

  def returns
    @returns = 'active'
  end

  def privacy
    @privacy = 'active'
  end

  def terms
    @terms = 'active'
  end

  def referral
    @referral = 'active'
  end

  def contactus
    @contactus = 'active'
  end

  def about
    @with_bg = "about-bg"
    @alternative = "white"

    @about_us_page = true

    # render :layout => "application-about"
  end

  def apps
    @apps = 'active'   
  end

  def contest
    @contest = 'active'
  end
  # def welcome
  #   hash = { :data => rand(100) }
  #   func_name = params[:callback]
  #   render :text => "$.pjaxCallbacks[#{func_name.inspect}](#{hash.to_json})"
  # end

end
