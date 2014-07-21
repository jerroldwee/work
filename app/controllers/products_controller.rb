class ProductsController < ApplicationController
  layout 'application-product'

  def index
    @products = Product.paginate(:page => params[:page])
  end

  def filter_list(gender)
    entries = Product.where("gender = ?", gender)
    @materials = Material.where("id IN (?)", [0] + entries.group(:material_id).all.map{|m|m.material_id}).all
    @frame_shapes = FrameShape.where("id IN (?)", [0] + entries.group(:frame_shape_id).all.map{|m|m.frame_shape_id}).all
    @frame_widths = FrameWidth.where("id IN (?)", [0] + entries.group(:frame_width_id).all.map{|m|m.frame_width_id}).all
    @colors = Color.where("id IN (?)", [0] + Choice.joins(:product).where("gender = ?", gender).group("choices.color_id").all.map{|m|m.color_id}).all
  end

  def men
    @for_men = true
    @products = Product.where("gender = ?", "Male").paginate(:page => params[:page])
    filter_list("Male")

    render :action => :index
  end

  def women
    @for_women = true
    @products = Product.where("gender = ?", "Female").paginate(:page => params[:page])
    filter_list("Female")

    render :action => :index
  end

  def unisex
    @for_unisex = true
    @products = Product.where("gender = ?", "Unisex").paginate(:page => params[:page])
    filter_list("Unisex")

    render :action => :index
  end

  def test
    @for_unisex = true
    @products = Product.where("gender = ?", "Unisex").paginate(:page => params[:page])
    filter_list("Unisex")

    render :action => :index
  end

  def show 
    @product = Product.find(params[:id])
  end

  def source
    source = Product
    source = source.where("brand IN (?)", params[:brand]) unless params[:brand].blank?
    source = source.where("material_id IN (?)", params[:material].map{|m|m.to_i} + [0])  unless params[:material].blank?
    source = source.where("frame_width_id IN (?)", params[:frame_width].map{|m|m.to_i} + [0])  unless params[:frame_width].blank?
    source = source.where("frame_shape_id IN (?)", params[:frame_shape].map{|m|m.to_i} + [0])  unless params[:frame_shape].blank?

    source = source.includes(:choices)  unless params[:color].blank?
    source = source.where("choices.color_id IN (?)", params[:color].map{|m|m.to_i} + [0])  unless params[:color].blank?
    @color_priorities = params[:color].map{|m|m.to_i} unless params[:color].blank?
    @visual_try_on = 1 if params[:visual]
    source = source.where("gender = ?", params[:gender]) unless params[:gender].blank?
    source
  end

  def partial_list
    @products = self.source.paginate(:page => params[:page])
    render :partial => "list.html.erb"
  end

  def details
    product = Product.find(params[:id])
    render :json => { 
      :id => product.id, 
      :colors => product.choices.map{|m|
        image = product.fit_room_images.where("color_id = ?", m.color_id).first
        url = image ? image.upload.url(:large) : ""
        [m.id, m.color_name, m.first_image_url, url, m.color_id]
      } 
    }
  end

end
