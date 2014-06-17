class PrescriptionsController < ApplicationController
  def show
    if current_user
      @entry = current_user.prescriptions.where(:id => params[:id]).first
      if @entry
        if params[:json]
          render :json => @entry.info
          return
        end
      end
    end
    
    if params[:json]
      render :json => {}
    end
  end
end
