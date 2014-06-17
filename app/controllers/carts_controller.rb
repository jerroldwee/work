class CartsController < ApplicationController
  
  def new
    @entries = [{ "product_id" => params["product_id"], "color_id" => params["color_id"], "lens_id" => params["lens_id"], "quantity" => 1 }].map{|m|
      LineItem.new({
        :no => "_1",
        :product_id => m["product_id"],
        :lens_id => m["lens_id"],
        :color_id => m["color_id"],
        :quantity => m["quantity"]
      })
    }

    render :show
  end

  def index
    @discount_credit = 0
    if cookies["discount_credit"] && current_user
      @discount_credit = [0, [cookies["discount_credit"].to_i, current_user.total_credit].min].max
    end
    @entries = JSON.parse(cookies["cart"].blank? ? "[]" : cookies["cart"]).map{|m|
      LineItem.new({
        :no => m["no"],
        :product_id => m["product_id"],
        :lens_id => m["lens_id"],
        :color_id => m["color_id"],
        :quantity => m["quantity"],
        :meta_info => m["info"],
        :attachment_guid => m["attachment_guid"]
      })
    }
  end

  def show
    carts = JSON.parse(cookies["cart"].blank? ? "[]" : cookies["cart"])
    cart = carts.select{|s|s["no"] == params["id"].to_i}.first

    @entries = [cart].compact.map{|m|
      LineItem.new({
        :no => m["no"],
        :product_id => m["product_id"],
        :lens_id => m["lens_id"],
        :color_id => m["color_id"],
        :quantity => m["quantity"],
        :meta_info => m["info"],
        :attachment_guid => m["attachment_guid"]
      })
    }    
  end

  def save
    cookies["cart"] = JSON.parse(cookies["cart"].blank? ? "[]" : cookies["cart"])

    max_num = 0
    cookies["cart"].each{|c|max_num=[max_num, c["no"]].max}

    params[:entry].each_pair do |key, p|
      if !p["product_id"].blank? && !p["color_id"].blank? && !p["lens_id"].blank?
        cart = cookies["cart"].select{|s|s["no"] == key.to_i}.first

        unless params["upload"].blank?
          attachment = Attachment.new
          attachment.upload = params["upload"]
          attachment.save
          p["attachment_guid"] = attachment.guid
        end

        if p["info"] && !p["info"]["prescription_title"].blank?
          if current_user
            Prescription.create({
              :title => p["info"]["prescription_title"],
              :info => p["info"].is_a?(Hash) ? p["info"] : {},
              :user_id => current_user.id
            })
          end
        end

        if cart
          cart["quantity"] = p["quantity"].to_i
          cart["info"] = p["info"] if p["info"].is_a?(Hash)
          unless p["attachment_guid"].blank?
            if cart["attachment_guid"] && !LineItem.where(:attachment_guid => cart["attachment_guid"]).first
              Attachment.where(:guid => cart["attachment_guid"]).first.destroy
            end
            cart["attachment_guid"] = p["attachment_guid"] 
          end
        else
          max_num += 1
          no = max_num 
          cookies["cart"] << { 
            "no" => no,
            "product_id" => p["product_id"], 
            "color_id" => p["color_id"], 
            "lens_id" => p["lens_id"], 
            "quantity" => p["quantity"].to_i,
            "info" => p["info"].is_a?(Hash) ? p["info"] : {},
            "attachment_guid" => p["attachment_guid"]
          }
        end        
      end
    end

    if params[:discount_credit] && current_user
      cookies["discount_credit"] = [0, [params[:discount_credit].to_i, current_user.total_credit].min].max
    end
    @discount_credit = cookies["discount_credit"].to_i

    total_cart = cookies[:cart].inject(0){|c,v|c+v["quantity"]}
    cookies["cart"] = cookies["cart"].select{|s|s["quantity"] > 0}
    cookies["cart"] = cookies["cart"].to_json

    if params[:json].blank?
      redirect_to "/carts"
    else      
      render :json => { :total => total_cart }
    end
  end

  def billing
    @entry = Order.new

    @billing = BillingAddress.new

    if current_user && !params[:billing_id].blank?
      billing = current_user.billing_addresses.where("id = ?", params[:billing_id]).first
      @billing = billing if billing
    end

    unless params[:entry].blank?
      @entry.assign_attributes(params.require(:entry).permit(:full_name, :address_line_1, :address_line_2, :address_line_3, :region, :state, :country, :postal_code, :contact_no, :email, :delivery_type))
      @entry.save

      if current_user
        @billing.assign_attributes(params.require(:entry).permit(:full_name, :address_line_1, :address_line_2, :address_line_3, :region, :state, :country, :postal_code, :contact_no, :email))
        @billing.user_id = current_user.id
        @billing.save
      end

      if @entry.valid?

        @discount_credit = 0
        if cookies["discount_credit"] && current_user
          @discount_credit = [0, [cookies["discount_credit"].to_i, current_user.total_credit].min].max
        end

        @entry.discount_credit = @discount_credit
        @entry.save

        lines = JSON.parse(cookies["cart"].blank? ? "[]" : cookies["cart"]).map{|m|
          LineItem.new({
            :order_id => @entry.id,
            :no => m["no"],
            :product_id => m["product_id"],
            :lens_id => m["lens_id"],
            :color_id => m["color_id"],
            :quantity => m["quantity"],
            :info => m["info"],
            :attachment_guid => m["attachment_guid"]
          })
        }
        lines.each{|l|l.save}
        redirect_to "/carts/#{@entry.checkout_token}/payment"
        return;

      end
    end
  end

  def verify
    @entry = Order.where("checkout_token = ? AND paypal_checkout_token = ?", params[:checkout_request_token], params[:token]).first

    checkout_details = PayPal::ExpressCheckout::Checkout.new(:token => params[:token]).details
    if checkout_details && checkout_details.payments && checkout_details.payments[0]
      lines = @entry.line_items

      @entry.discount_credit = [@entry.discount_credit || 0, (current_user ? current_user.total_credit : 0)].min
      payment_items = @entry.paypal_payment_items

      payments = PayPal::ExpressCheckout::Payment.new(
        :payment_action     => "Sale",
        :description        => "Order ##{@entry.id}",
        :amount             => @entry.amount,
        :currency           => "SGD",
        :payment_items      => payment_items
      )

      pay_details = PayPal::ExpressCheckout::Checkout.new(:token => params[:token], :payer_id => checkout_details.payer_id, :payments => payments).pay
      if pay_details.success?
        @entry.paypal_email = checkout_details.email
        @entry.paypal_customer_token = checkout_details.payer_id

        if @entry.discount_credit > 0
          CreditReward.create({ :user_id => current_user.id, :description => "Credit Used to purchase Order ##{@entry.id}", :total => -@entry.discount_credit, :reward_type => "Credit Used" })
          current_user.update_total_credit
          current_user.save          
        end
        @entry.save 
      else
        redirect_to "/carts/failed"
        return
      end
    end

    redirect_to "/carts/thank_you"
    return;

    render :text => "okay #{@entry.id} #{@entry.paypal_email}"
  end

  def payment
    @discount_credit = 0
    if cookies["discount_credit"] && current_user
      @discount_credit = [0, [cookies["discount_credit"].to_i, current_user.total_credit].min].max
    end

    @on_payment_mode = true
    @order = Order.where(:checkout_token => params[:id]).first

    if @order
      @entries = @order.line_items.all    

      if params[:payment_type] == "paypal"
        payment_host = params[:host] || request.url.split(request.path).first        

        payment_items = @order.paypal_payment_items

        payments = PayPal::ExpressCheckout::Payment.new(
          :payment_action     => "Sale",
          :description        => "Order ##{@order.id}",
          :amount             => @order.amount,
          :currency           => "SGD",
          :payment_items      => payment_items
        )

        billing = PayPal::ExpressCheckout::Billing.new(
          :type               => 'MerchantInitiatedBilling',
          :payment_type       => 'InstantOnly',
          :description        => 'Figo Payment'
        );
        response = PayPal::ExpressCheckout::Checkout.new({
          :return_url         => "#{payment_host}/carts/verify?checkout_request_token=#{@order.checkout_token}",
          :cancel_url         => "#{payment_host}/carts/cancel",
          :solution_type      => 'Sole',
          :landing_page       => 'Billing',
          :billings           => [ billing ],
          :payments           => payments
        }).checkout

        @order.payment_type = "Paypal"
        @order.user_id = current_user.id if current_user
        @order.paypal_checkout_token = response.token if response.checkout_url
        @order.add_order_number
        @order.save

        return redirect_to response.checkout_url if response.checkout_url 

      elsif params[:payment_type] == "cash"

        @order.payment_type = "Cash"
        @order.user_id = current_user.id if current_user
        @order.add_order_number
        if @order.save
          APP['receivers'].each do |email|
            UserMailer.order_email_notification(email, @order).deliver
          end
        end
        
        return redirect_to "/carts/thank_you"

      end

    end

  end

  def thank_you
    cookies["cart"] = "[]"
    return redirect_to "/contactus"
    # render :text => "Thanks"
  end

end
