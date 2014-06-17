class Admin::ProductImagesController < ApplicationController
  layout 'admin'
  before_filter :admin_login_required

  # GET /admin/products/new
  def new
    @controller_name = "Product > Choice > New Image"
    @product = Product.find(params[:product_id])
    @choice = Choice.find(params[:choice_id])
    @entry = ProductImage.new
    @entry.choice_id = @product.id
  end

  def create
    @controller_name = "Product > Choice > Image"
    @product = Product.find(params[:product_id])
    @choice = Choice.find(params[:choice_id])
    @entry = ProductImage.new(params.require(:product_image).permit(:choice_id))
    @entry.upload = params[:product_image][:upload] if params[:product_image] && params[:product_image][:upload]
    @entry.choice_id = @choice.id
    @entry.product_id = @choice.product.id

    if @entry.save
      redirect_to admin_product_choice_url(@choice.product, @choice), notice: 'Product was successfully created.'
    else
      render action: 'new'
    end
  end

  def edit
    @controller_name = "Product > Choice > Edit Image"
    @product = Product.find(params[:product_id])
    @choice = Choice.find(params[:choice_id])
    @entry = @choice.product_images.find(params[:id])  
  end

  def update
    @controller_name = "Product > Choice > Edit Image"
    @product = Product.find(params[:product_id])
    @choice = Choice.find(params[:choice_id])
    @entry = @choice.product_images.find(params[:id])  
    @entry.upload = params[:product_image][:upload] if params[:product_image] && params[:product_image][:upload]

    if @entry.update(params.require(:product_image).permit(:choice_id))
      redirect_to admin_product_choice_url(@choice.product, @choice), notice: 'Product was successfully updated.'
    else
      render action: 'edit'
    end
  end

  def reorder
    @choice = Choice.find(params[:choice_id])

    ids = params["ids"].split(",").map{|m|m.to_i}
    entries = @choice.product_images.where("id IN (?)", [0] + ids).all
    entry_ids = entries.map{|m|m.id}
    ids = ids.select{|s|entry_ids.index(s)}

    updates = "10000"
    ids.each_with_index{|m,pos|updates = "IF(id=#{m},#{pos},#{updates})"}
    @choice.product_images.update_all("position = #{updates}", ["id IN (?)", [0] + entry_ids])
    
    render :json => { :status => "ok" }
  end

end
