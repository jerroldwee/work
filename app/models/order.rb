class Order < ActiveRecord::Base
  validates_presence_of :full_name
  validates_presence_of :address_line_1
  validates_presence_of :region
  validates_presence_of :state
  validates_presence_of :country
  validates_presence_of :postal_code
  validates_presence_of :contact_no
  validates_presence_of :delivery_type
  validates :email, :format => { :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, message: "Does not look like an email"}
  
  has_many :line_items, dependent: :destroy
  before_create :add_checkout_token
  belongs_to :user

  def add_line_items_from_cart(cart)
    cart.line_items.each do |item|
      item.cart_id = nil
      line_items << item
    end
  end

  def subtotal_amount
    total = 0
    self.line_items.all.each{|l|
      total += l.amount
    }

    total += self.delivery_quantity * self.delivery_amount
    total
  end

  def amount
    self.subtotal_amount - self.total_discount
  end

  def delivery_info
    return "International (Standard $10 per item)" if self.delivery_type == "international-standard"
    return "International (Air $20 item)" if self.delivery_type == "international-air"
    return "Free (Singapore)"
  end

  def delivery_quantity
    total = 0
    self.line_items.all.each{|l|
      total += l.quantity
    }

    total
  end

  def total_discount
    [((self.discount_credit||0) * 0.5), self.subtotal_amount].min
  end

  def delivery_amount
    return 10 if self.delivery_type == "international-standard"
    return 20 if self.delivery_type == "international-air"
    return 0
  end

  def add_checkout_token
    generate_token(:checkout_token)
  end

  def generate_token(column)
    begin
      self[column] = secure_digest(Time.now, (1..10).map{ rand.to_s }) + 
                     secure_digest(Time.now, (1..20).map{ rand.to_s }) +
                     secure_digest(Time.now, (1..30).map{ rand.to_s })
    end while self.class.exists?(column => self[column])
  end

  def add_order_number
    generate_order_number(:order_number) unless self.order_number
  end

  def generate_order_number(column)
    counter = 0
    begin
      counter += 1
      self[column] = Time.now.strftime("%Y%m%d-#{counter}")
    end while self.class.exists?(column => self[column])
  end

  def secure_digest(*args)
    Digest::SHA1.hexdigest(args.flatten.join('--'))
  end

  def paypal_payment_items
    counter = 0
    total_discount = self.total_discount

    items = self.line_items.map{|line|
      counter+=1
      item_amount = line.amount
      discount = ""
      if total_discount > 0
        deduction = [total_discount, item_amount].min
        item_amount -= deduction
        total_discount -= deduction
        discount = "(discounted $ #{deduction})"
      end

      PayPal::ExpressCheckout::PaymentItem.new({
        :number => counter,
        :name =>  "#{line.product.code} - #{line.product.title} #{line.color_name}",
        :description =>  "#{line.product.code} - #{line.product.title} #{line.color_name} #{discount}",
        :quantity => 1,
        :amount => item_amount,
        :tax_amount => 0.00,
        :item_category => "Physical"
      })
    }

    if self.delivery_amount > 0
      counter += 1
      items << PayPal::ExpressCheckout::PaymentItem.new({
        :number => counter,
        :name =>  "Delivery cost",
        :description =>  self.delivery_quantity.to_s + " x $" + self.delivery_amount.to_s,
        :quantity => 1,
        :amount => (self.delivery_quantity * self.delivery_amount).floor,
        :tax_amount => 0.00,
        :item_category => "Physical"
      })
    end

    items
  end

end
