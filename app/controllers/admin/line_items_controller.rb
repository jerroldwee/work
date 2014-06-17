class Admin::LineItemsController < ApplicationController
  layout 'admin'
  before_filter :admin_login_required

  def edit
    @order = Order.find(params[:order_id])
    @entry = @order.line_items.find(params[:id])
    @entry.meta_info = @entry.info
  end

  def update
    @order = Order.find(params[:order_id])
    @entry = @order.line_items.find(params[:id])

    @entry.info = params[:entry][:info] if params[:entry] && params[:entry][:info]
    
    if @entry.save
      redirect_to admin_order_url(@order), notice: 'Order was successfully updated.'
    else
      @entry.meta_info = @entry.info
      render action: 'edit'
    end
  end

end
