class Api::ProductsController < ApplicationController

  skip_before_filter :verify_authenticity_token

  before_filter :api_login_required

  def product_types
    render :json => ["Unisex", "Men", "Women"]
  end

  def show
  end

  def source
    source = Product

    source = source.where("material_id IN (?)", params[:material].map{|m|m.to_i} + [0])  unless params[:material].blank?
    source = source.where("frame_width_id IN (?)", params[:frame_width].map{|m|m.to_i} + [0])  unless params[:frame_width].blank?
    source = source.where("frame_shape_id IN (?)", params[:frame_shape].map{|m|m.to_i} + [0])  unless params[:frame_shape].blank?

    gender = params[:gender]
    if params[:action].to_s.downcase == 'men'
      gender = "Male"
    elsif params[:action].to_s.downcase == 'women'
      gender = "Female"
    elsif params[:action].to_s.downcase == 'unisex'
      gender = "Unisex"
    end

    source = source.includes(:choices)  unless params[:color].blank?
    source = source.where("choices.color_id IN (?)", params[:color].map{|m|m.to_i} + [0])  unless params[:color].blank?
    @color_priorities = params[:color].map{|m|m.to_i} unless params[:color].blank?
    @visual_try_on = 1 if params[:visual]
    source = source.where("gender = ?", gender) unless gender.blank?
    source
  end

  def index
    @products = self.source.paginate(:page => params[:page])
    render :json => {
      :products => @products.map{|p|
        {
          :id => p.id,
          :title => p.title,
          :colours => "#{p.choices.count} colours",
          :product_url => product_url(p, :only_path => false),
          :frames => p.choices.all.map{|c|
            frame = p.fit_room_images.where("color_id = ?", c.color_id).first;

            {
              :colour => c.color_name,
              :color_id => c.color_id,
              :big_img_url => c.first_image_url(:large, request),
              :medium_img_url => c.first_image_url(:medium, request),
              :small_img_url => c.first_image_url(:small, request),
              :big_frame_url => frame ? "#{request.protocol}#{request.host_with_port}" + frame.upload.url(:large) : "",
              :medium_frame_url => frame ? "#{request.protocol}#{request.host_with_port}" + frame.upload.url(:medium) : ""
            }
          }
        }
      },
      :total_page => @products.total_pages
    }
  end

  def men
    index
  end

  def women
    index
  end

  def unisex
    index
  end
  
end
