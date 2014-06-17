class Admin::OrdersController < ApplicationController
  layout 'admin'
  before_filter :admin_login_required

  def source
    source = Order
    source = source.where("order_number LIKE ? OR users.email LIKE ? OR users.name LIKE ? OR users.nric LIKE ?", "%#{params[:search]}%", "%#{params[:search]}%", "%#{params[:search]}%", "%#{params[:search]}%") unless params[:search].blank?
    source = source.includes("user") unless params[:search].blank?
    source = source.where("user_id = ?", params[:user_id]) unless params[:user_id].blank?
    source = source.where("line_items.product_id = ?", params[:product_id]) unless params[:product_id].blank?
    source = source.includes("line_items").group("orders.id") unless params[:product_id].blank?

    unless params[:user_id].blank?
      u = User.where("id = ?", params[:user_id]).first
      @controller_name = "Orders by #{u.name}" if u
    end

    unless params[:product_id].blank?
      p = Product.where("id = ?", params[:product_id]).first
      @controller_name = "Orders for #{p.title}" if p
    end

    source
  end

  def index
    @order_source = self.source
    @controller_name = "Orders"
    @entries = self.source.order("orders.id DESC").where("NOT(paypal_email IS NULL) OR payment_type = ?", "Cash").paginate(:page => params[:page])
  end

  def show
    @entry = Order.find(params[:id])
    @entries = @entry.line_items
    @entries.each{|line|line.meta_info = line.info}
    @discount_credit = @entry.discount_credit || 0
    @on_payment_mode = true
  end

  def update
    @entry = Order.find(params[:id])

    if @entry.update(params.require(:order).permit(:order_status, :delivery_tracking_url))
      redirect_to admin_order_url(@entry), notice: 'Order was successfully updated.'
    else
      render action: 'edit'
    end
  end

  def csv    
    order_source = self.source
    order_source = order_source.where("year(orders.created_at) = ?", params[:year].to_i) unless params[:year].blank?
    order_source = order_source.where("month(orders.created_at) = ?", params[:month].to_i) unless params[:month].blank?
    @entries = order_source.order("orders.id DESC").where("NOT(orders.paypal_email IS NULL) OR orders.payment_type = ?", "Cash").all

    require 'csv'
    csv_file = CSV.generate do |csv|
      arr = ["Order No", "Name", "Email", "Amount", "Status", "NRIC"]
      csv << arr

      @entries.each do |entry|
        csv << [entry.order_number, entry.user ? entry.user.name : entry.full_name, entry.paypal_email || (entry.user ? entry.user.email : nil) || entry.email, entry.amount, entry.order_status, entry.user ? entry.user.nric : nil]
      end
    end    

    send_data( csv_file, :type => "text/csv", :filename => "statistic.csv", :disposition => "attachment" )
  end

end
