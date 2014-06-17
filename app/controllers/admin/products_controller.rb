class Admin::ProductsController < ApplicationController
  layout 'admin'
  before_filter :admin_login_required

  before_action :set_admin_product, only: [:show, :edit, :update, :destroy]

  def source
    source = Product
    source = source.where("code LIKE ? OR title LIKE ? OR gender LIKE ?", "%#{params[:search]}%", "%#{params[:search]}%", "%#{params[:search]}%") unless params[:search].blank?
    source = source.order("code ASC")
    params[:order_type] = "asc" unless ["asc", "desc"].include?(params[:order_type])
    source = source.reorder("#{params[:order]} #{params[:order_type]}") if !params[:order].blank? && ["code", "total_order_count"].include?(params[:order].downcase)
    if params[:order] == "total_order_count"
      source = source.select("products.*, COUNT(line_items.id) as total_order_count")
      source = source.group("products.id")
      source = source.joins("LEFT OUTER JOIN line_items ON line_items.product_id = products.id")
    end
    source
  end

  # GET /admin/products
  def index
    @products = self.source.paginate(:page => params[:page])
  end

  # GET /admin/products/1
  def show
    @product_choices = @product.choices if @product
    @product_fit_room_images = @product.fit_room_images if @product
    @models = {
      "Male" => @product.male_model_images.order("position ASC, id DESC"),
      "Female" => @product.female_model_images.order("position ASC, id DESC")
    }
  end

  # GET /admin/products/new
  def new
    @product = Product.new
    @product_fit_room_images = @product.fit_room_images if @product
  end

  # GET /admin/products/1/edit
  def edit
    @product_fit_room_images = @product.fit_room_images if @product
  end

  # POST /admin/products
  def create
    @product = Product.new(admin_product_params)

    if @product.save
      redirect_to admin_products_url, notice: 'Product was successfully created.'
    else
      render action: 'new'
    end
  end

  # PATCH/PUT /admin/products/1
  def update
    if @product.update(admin_product_params)
      redirect_to admin_product_url(@product), notice: 'Product was successfully updated.'
    else
      render action: 'edit'
    end
  end

  # DELETE /admin/products/1
  def destroy
    @product.destroy
    redirect_to admin_products_url, notice: 'Product was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_admin_product
      @product = Product.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def admin_product_params
      params.require(:product).permit(:title, :description, :price, :code, :product_type, :gender, :material_id, :frame_shape_id, :frame_width_id)
    end
end
