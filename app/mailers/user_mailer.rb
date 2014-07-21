class UserMailer < ActionMailer::Base
  default from: APP['email_sender']
  
  def order_email_notification(email, order)
    @email = email
    @order = order
    mail(:to => email, :subject => "[FIGO Eyewear] Order number #{order.try(:order_number)}")
  end

  def order_email_notification2(subject, body)
    @subject = subject
    @body= body
    mail(to: 'jerrold.wee.2011@smu.edu.sg', :subject => "[FIGO Eyewear] Order number")
  end



end
