class OrdersController < ApplicationController
  # before_action :set_order, only: [:show, :edit, :update, :destroy]

  def index
    @user = current_user
    @entries = current_user.orders.order('created_at desc').page(params[:page])
  end

  def show
    @user = current_user
    @order = current_user.orders.where("id = ?", params[:id]).first
    @discount_credit = @order.discount_credit
    @entries = @order.line_items
    @on_payment_mode = true
    @on_user_order_show = true
  end

end
