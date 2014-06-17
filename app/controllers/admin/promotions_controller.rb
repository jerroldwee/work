class Admin::PromotionsController < ApplicationController
  layout 'admin'
  before_filter :admin_login_required

  def index
    @controller_name = "Promotions"
    @entries = Promotion.paginate(:page => params[:page])
  end

  def show
    @controller_name = "Promotions"
    @entry = Promotion.find(params[:id])
  end

  def new
    @controller_name = "Promotions"
    @entry = Promotion.new
  end

  def edit
    @controller_name = "Promotions"
    @entry = Promotion.find(params[:id])
  end

  def create
    @controller_name = "Promotions"
    @entry = Promotion.new(params.require(:promotion).permit(:title, :description, :url))
    @entry.upload = params[:promotion][:upload] if params[:promotion] && params[:promotion][:upload]

    if @entry.save
      redirect_to admin_promotions_url, notice: 'Promotion was successfully created.'
    else
      render action: 'new'
    end
  end

  def update
    @controller_name = "Promotions"
    @entry = Promotion.find(params[:id])
    @entry.upload = params[:promotion][:upload] if params[:promotion] && params[:promotion][:upload]

    if @entry.update(params.require(:promotion).permit(:title, :description, :url))
      redirect_to admin_promotions_url(@entry), notice: 'Promotion was successfully updated.'
    else
      render action: 'edit'
    end
  end

  def destroy
    @entry = Promotion.find(params[:id])
    @entry.destroy
    redirect_to admin_promotions_url, notice: 'Promotion was successfully destroyed.'
  end

end
