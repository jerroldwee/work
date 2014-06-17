class UserFitRoomsController < ApplicationController

  def save
    entry = params[:id].blank? ? UserFitRoom.new : current_user.user_fit_rooms.find(params[:id])
    if entry
      entry.assign_attributes(params.permit(:left, :top, :width, :height, :rotation, :color_id, :product_id, :sample_man, :title))
      entry.user_id = current_user.id
      entry.save
    end

    if params[:upload]
      entry.temprary = true
      entry.photo = params[:upload]
      entry.save
      entry.force_image_change
      render :text => "<script>parent.VisualTryOnDone(#{entry.id}, #{entry.photo.url(:large).inspect})</script>"
      return
    else
      entry.temprary = false
      entry.save
    end

    render :json => { :id => entry.id, :product_id => entry.product_id, :color_id => entry.color_id, :image => entry.target_image.url(:large) }
  end

end
