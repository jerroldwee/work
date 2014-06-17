class Admin::SettingsController < ApplicationController

  layout 'admin'
  before_filter :admin_login_required

  def index
    @controller_name = "Settings"
    @colors = Color.paginate(:page => params[:color_page], :limit => 100000)
    @frame_widths = FrameWidth.paginate(:page => params[:frame_width_page], :limit => 100000)
    @frame_shapes = FrameShape.paginate(:page => params[:frame_shape_page], :limit => 100000)
  end

  def new
    @controller_name = "Settings"
    @entry = Color.new if params[:type] == 'Color'
    @entry = FrameWidth.new if params[:type] == 'FrameWidth'
    @entry = FrameShape.new if params[:type] == 'FrameShape'
  end

  def edit
    @controller_name = "Settings"
    @entry = Color.find(params[:id]) if params[:type] == 'Color'
    @entry = FrameWidth.find(params[:id]) if params[:type] == 'FrameWidth'
    @entry = FrameShape.find(params[:id]) if params[:type] == 'FrameShape'
  end

  def create
    @controller_name = "Settings"
    klass = Color if params[:type] == 'Color'
    klass = FrameWidth if params[:type] == 'FrameWidth'
    klass = FrameShape if params[:type] == 'FrameShape'

    @entry = klass.new(params.require(:entry).permit(:name))
    if @entry.save
      redirect_to "/admin/settings/", notice: 'Setting was successfully updated.'
    else
      render action: 'new'
    end
  end

  def update
    @controller_name = "Settings"
    klass = Color if params[:type] == 'Color'
    klass = FrameWidth if params[:type] == 'FrameWidth'
    klass = FrameShape if params[:type] == 'FrameShape'

    @entry = klass.find(params[:id])
    if @entry.update(params.require(:entry).permit(:name))
      redirect_to "/admin/settings/", notice: 'Setting was successfully updated.'
    else
      redirect_to "/admin/settings/", notice: 'Setting was successfully updated.'
    end
  end

  def destroy
    klass = Color if params[:type] == 'Color'
    klass = FrameWidth if params[:type] == 'FrameWidth'
    klass = FrameShape if params[:type] == 'FrameShape'

    @entry = klass.find(params[:id])
    @entry.destroy if @entry
    redirect_to "/admin/settings/", notice: 'Setting was successfully updated.'
  end

end
