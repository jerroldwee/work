class Admin::ChoicesController < ApplicationController
  layout 'admin'
  before_filter :admin_login_required

  def new
    @controller_name = "Product > New Choice"
    @product = Product.find(params[:product_id])
    @entry = Choice.new
    @entry.product_id = @product.id
  end

  def create
    @controller_name = "Product > New Choice"
    @product = Product.find(params[:product_id])
    @entry = Choice.new(params.require(:choice).permit(:product_id, :color_id, :inventory_count))

    if @entry.save
      redirect_to admin_product_choice_url(@product, @entry), notice: 'Product was successfully created.'
    else
      render action: 'new'
    end
  end

  def show
    @controller_name = "Product > Choice"
    @product = Product.find(params[:product_id])
    @entry = @product.choices.find(params[:id])  
    @product_images = @entry.product_images.order("position ASC, id DESC") if @entry
  end

  def edit
    @controller_name = "Product > Edit Choice"
    @product = Product.find(params[:product_id])
    @entry = @product.choices.find(params[:id])  
  end

  def update
    @controller_name = "Product > Edit Choice"
    @product = Product.find(params[:product_id])
    @entry = @product.choices.find(params[:id])

    if @entry.update(params.require(:choice).permit(:product_id, :color_id, :inventory_count))
      redirect_to admin_product_choice_url(@product, @entry), notice: 'Product was successfully updated.'
    else
      render action: 'edit'
    end
  end

end
