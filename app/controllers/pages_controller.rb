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
    @pagetitle = 'Figoeyewear-FAQ'
  end

  def philosophy
    @philosophy = 'active'
    @pagetitle = 'Figoeyewear-Philosphy'
  end

  def returns
    @returns = 'active'
  end

  def privacy
    @privacy = 'active'
    @pagetitle = 'Figoeyewear-Privacy'
  end

  def terms
    @terms = 'active'
    @pagetitle = 'Figoeyewear-Terms and Condition'
  end

  def referral
    @referral = 'active'
    @pagetitle = 'Figoeyewear-Referral'
  end

  def contactus
    @contactus = 'active'
  end

  def about
    @with_bg = "about-bg"
    @alternative = "white"

    @about_us_page = true
    @pagetitle = 'Figoeyewear-AboutUs'
    # render :layout => "application-about"
  end

  def apps
    @apps = 'active'
    @pagetitle = 'Figoeyewear-MobileApplication'
  end

  def contest
    @contest = 'active'
    @pagetitle = 'Figoeyewear-contest'
  end
  # def welcome
  #   hash = { :data => rand(100) }
  #   func_name = params[:callback]
  #   render :text => "$.pjaxCallbacks[#{func_name.inspect}](#{hash.to_json})"
  # end

end
