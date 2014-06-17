class Admin::LensController < ApplicationController

  layout 'admin'
  before_filter :admin_login_required

  def index
    @controller_name = "Lens"
    @entries = Lens.order("price ASC").paginate(:page => params[:page])
  end

  def show
    @controller_name = "Lens"
    @entry = Lens.find(params[:id])
  end

  def new
    @controller_name = "Lens"
    @entry = Lens.new
  end

  def edit
    @controller_name = "Lens"
    @entry = Lens.find(params[:id])
  end

  def create
    @controller_name = "Lens"
    @entry = Lens.new(params.require(:lens).permit(:name, :price))

    if @entry.save
      redirect_to admin_lens_url, notice: 'Lens was successfully created.'
    else
      render action: 'new'
    end
  end

  def update
    @controller_name = "Lens"
    @entry = Lens.find(params[:id])

    if @entry.update(params.require(:lens).permit(:name, :price))
      redirect_to admin_lens_url, notice: 'Lens was successfully updated.'
    else
      render action: 'edit'
    end
  end

  def destroy
    @entry = Lens.find(params[:id])
    @entry.destroy
    redirect_to admin_lens_url, notice: 'Lens was successfully destroyed.'
  end

end
