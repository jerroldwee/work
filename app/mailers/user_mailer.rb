class UserMailer < ActionMailer::Base
  default from: APP['email_sender']
  
  def order_email_notification(email, order)
    @email = email
    @order = order
    mail(:to => email, :subject => "[FIGO Eyewear] Order number #{order.try(:order_number)}")
  end
end
