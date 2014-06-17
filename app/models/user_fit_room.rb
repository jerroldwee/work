class UserFitRoom < ActiveRecord::Base
  belongs_to :user
  belongs_to :product

  has_attached_file :photo, :styles => { 
    :large => "960x1280>",
    :medium => "540x720>", 
    :small => "270x360>" 
  }

  has_attached_file :target_image, :styles => { 
    :large => "960x1280>", 
    :medium => "540x720>", 
    :small => "270x360>" 
  }

  before_save :check_update
  after_save :check_changes
  
  def facebook_json
    json = nil
    if facebook_post_id && user
      json = JSON.parse(open("https://graph.facebook.com/#{self.facebook_post_id}?access_token=#{self.user.oauth_token}"){|f|f.read})
    end
    json
  end

  def check_update
    if !@checked 
      if self.photo_file_name_changed? || self.left_changed? || self.top_changed? || self.width_changed? || self.height_changed? || self.rotation_changed? || self.product_id_changed? || self.color_id_changed?
        @allow_changes = true
        @checked = true
      end
    end
  end

  def force_image_change
    @allow_changes = true
    self.check_changes
  end

  def check_changes
    if self.id && @allow_changes
      @allow_changes = false

      if self.product_id && self.color_id && self.width && self.height
        product = Product.find(self.product_id)
        frame_image = product.fit_room_images.where("color_id = ?", self.color_id).first
        frame_image_path = frame_image ? frame_image.upload.path(:large) : ""
        tmp_path = File.join(Rails.root, "tmp/fitroom/#{self.id}/#{rand(1000)}/output.jpg")
        FileUtils.mkdir_p(File.dirname(tmp_path))

        if frame_image_path
          base = ::MiniMagick::Image.open( File.join(File.dirname(__FILE__), '../assets/images/1x1.png') )          
          profilepic = ::MiniMagick::Image.open( File.join(File.dirname(__FILE__), self.sample_man? ? '../assets/images/photo-sample-man.png' : '../assets/images/photo-sample-woman.png') )
          if self.photo.exists?
            profilepic = ::MiniMagick::Image.open( self.photo.path(:large) )
          end
          frame = ::MiniMagick::Image.open( frame_image_path )

          base_width = 960
          base_height = 1280
          base.resize([base_width, base_height].join('x') + '!')

          image = base.composite(profilepic) do |c|
            c.geometry "#{base_width}x"
          end

          r = [1.0 * profilepic[:width] / base_width, 1.0 * profilepic[:height] / base_height].max
          base_width = profilepic[:width] / r
          base_height = profilepic[:height] / r

          wd, hg, l, t = [base_width * self.width, base_height * self.height, base_width * self.left, base_height * self.top].map{|m|m*0.01}.map{|m|"%.0f" % m}
          geo = [wd, "x", hg, "+", l, "+", t].join('').gsub("+-", "-")
          image = image.composite(frame) do |c|
            c.geometry geo
          end

          image.write(tmp_path)

          self.target_image = File.open(tmp_path)
          self.save
        end
      end

    end
  end

end
