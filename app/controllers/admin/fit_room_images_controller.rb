class Admin::FitRoomImagesController < ApplicationController
  layout 'admin'
  before_filter :admin_login_required

  def new
    @controller_name = "Product > New Fit Room Image"
    @product = Product.find(params[:product_id])
    @entry = FitRoomImage.new
    @entry.product_id = @product.id
  end

  def create
    @controller_name = "Product > New Fit Room Image"
    @product = Product.find(params[:product_id])
    @entry = FitRoomImage.new(params.require(:fit_room_image).permit(:product_id, :name))
    @entry.upload = params[:fit_room_image][:upload] if params[:fit_room_image] && params[:fit_room_image][:upload]

    if @entry.save
      redirect_to admin_product_fit_room_image_url(@product, @entry), notice: 'Product was successfully created.'
    else
      render action: 'new'
    end
  end

  def show
    @controller_name = "Product > Fit Room Image"
    @product = Product.find(params[:product_id])
    @entry = @product.fit_room_images.find(params[:id])  
  end

  def edit
    @controller_name = "Product > Edit Fit Room Image"
    @product = Product.find(params[:product_id])
    @entry = @product.fit_room_images.find(params[:id])  
  end

  def update
    @controller_name = "Product > Edit Fit Room Image"
    @product = Product.find(params[:product_id])
    @entry = @product.fit_room_images.find(params[:id])
    @entry.upload = params[:fit_room_image][:upload] if params[:fit_room_image] && params[:fit_room_image][:upload]

    if @entry.update(params.require(:fit_room_image).permit(:product_id, :name))
      redirect_to admin_product_fit_room_image_url(@product, @entry), notice: 'Product was successfully updated.'
    else
      render action: 'edit'
    end
  end

end
