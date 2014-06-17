class Choice < ActiveRecord::Base

  def self.color_selections
    #[["Red", 1], ["Blue", 2], ["Black", 3], ["Green", 4]]
    Color.all.map{|m|[m.name, m.id]}
  end

  def self.by_color_name(name)
    color = Color.where(:name => name).first
    self.where(:color_id => color ? color.id : 0)
  end

  def color_name
    colors = self.class.color_selections
    pair = colors.select{|s|s[1]==self.color_id}.first
    return "" unless pair
    return pair.first if pair
  end

  belongs_to :product
  has_many :product_images

  def first_image_url(style=:medium, request=nil)
    img = self.product_images.first
    return (request ? "#{request.protocol}#{request.host_with_port}" : "")+ img.upload.url(style) if img
    return ""
  end
  
end
