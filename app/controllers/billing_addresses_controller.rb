class BillingAddressesController < ApplicationController
  def show
    if current_user
      @entry = current_user.billing_addresses.where(:id => params[:id]).first
      if @entry
        if params[:json]
          render :json => [
            :full_name, :address_line_1, :address_line_2, :address_line_3, :region, :state, :country, :postal_code, :contact_no, :email
          ].inject({}){|c,v| c[v] = @entry.send(v); c}
          return
        end
      end
    end
    
    if params[:json]
      render :json => {}
    end
    
    
  end
  
  
    
end
