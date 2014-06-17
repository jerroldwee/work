class Admin::ModelImagesController < ApplicationController
  layout 'admin'
  before_filter :admin_login_required

  def new
    @controller_name = "Product > New Model Image"
    @product = Product.find(params[:product_id])
    @entry = ModelImage.new
    @entry.product_id = @product.id
  end

  def create
    @controller_name = "Product > New Model Image"
    @product = Product.find(params[:product_id])
    model_klass = params[:model].to_s == 'Male' ? MaleModelImage : FemaleModelImage;
    @entry = model_klass.new(params.require(:model_image).permit(:product_id))
    @entry.upload = params[:model_image][:upload] if params[:model_image] && params[:model_image][:upload]

    if @entry.save
      redirect_to admin_product_model_image_url(@product, @entry), notice: 'Product was successfully created.'
    else
      render action: 'new'
    end
  end

  def show
    @controller_name = "Product > Model Image"
    @product = Product.find(params[:product_id])
    @entry = @product.model_images.find(params[:id])  
  end

  def edit
    @controller_name = "Product > Edit Model Image"
    @product = Product.find(params[:product_id])
    @entry = @product.model_images.find(params[:id])  
  end

  def update
    @controller_name = "Product > Edit Model Image"
    @product = Product.find(params[:product_id])
    @entry = @product.model_images.find(params[:id])
    @entry.upload = params[:model_image][:upload] if params[:model_image] && params[:model_image][:upload]

    if @entry.update(params.require(:model_image).permit(:product_id))
      redirect_to admin_product_model_image_url(@product, @entry), notice: 'Product was successfully updated.'
    else
      render action: 'edit'
    end
  end

  def reorder
    @product = Product.find(params[:product_id])

    ids = params["ids"].split(",").map{|m|m.to_i}
    entries = @product.model_images.where("id IN (?)", [0] + ids).all
    entry_ids = entries.map{|m|m.id}
    ids = ids.select{|s|entry_ids.index(s)}

    updates = "10000"
    ids.each_with_index{|m,pos|updates = "IF(id=#{m},#{pos},#{updates})"}
    @product.model_images.update_all("position = #{updates}", ["id IN (?)", [0] + entry_ids])
    
    render :json => { :status => "ok" }
  end

end
