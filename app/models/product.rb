class Product < ActiveRecord::Base
  has_many :choices
  has_many :product_images, :through => :choices
  has_many :fit_room_images
  has_many :model_images
  has_many :male_model_images
  has_many :female_model_images

  has_many :line_items
  has_many :orders, through: :line_items

  before_destroy :ensure_not_referenced_by_any_line_item

  self.per_page = 15
  
  has_attached_file :upload, :styles => { 
    :large => "860x400>", 
    :medium => "430x200>",
    :small => "215x100>" 
  }

  def self.material_selections
    Material.all.map{|m|[m.name, m.id]}
  end

  def self.frame_shape_selections
    FrameShape.all.map{|m|[m.name, m.id]}
  end

  def self.frame_width_selections
    FrameWidth.all.map{|m|[m.name, m.id]}
  end

  def material_name
    material = Material.where("id = ?", self.material_id).first
    material ? material.name : ""
  end

  def frame_width_name
    frame_width = FrameWidth.where("id = ?", self.frame_width_id).first
    frame_width ? frame_width.name : ""
  end

  def frame_shape_name
    frame_shape = FrameShape.where("id = ?", self.frame_shape_id).first
    frame_shape ? frame_shape.name : ""
  end

  def first_image_url(color_priorities=[])
    if color_priorities && color_priorities.size > 0
      img = self.product_images.order("position ASC, id ASC").where("color_id IN (?)", [0] + color_priorities).first
    else
      img = self.product_images.order("position ASC, id ASC").first
    end
    if color_priorities && color_priorities.size > 0 && !img
      img = self.product_images.order("position ASC, id ASC").first
    end
    return img.upload.url(:medium) if img
    return ""
  end

  def first_fit_room_image_url(color_priorities=[])
    if color_priorities && color_priorities.size > 0
      img = self.fit_room_images.order("position ASC, id ASC").where("color_id IN (?)", [0] + color_priorities).first
    else
      img = self.fit_room_images.order("position ASC, id ASC").first
    end
    if color_priorities && color_priorities.size > 0 && !img
      img = self.fit_room_images.order("position ASC, id ASC").first
    end
    return img.upload.url(:medium) if img
    return ""
  end

  def first_female_model_image_url(style=:small)
    img = self.female_model_images.offset(2).first
    return img.upload.url(style) if img
    return ""
  end

  def first_male_model_image_url(style=:small)
    img = self.male_model_images.offset(2).first
    return img.upload.url(style) if img
    return ""
  end

  def first_model_image_url(style=:small)
    img = self.model_images.offset(2).first
    return img.upload.url(style) if img
    return ""
  end

  def has_male_image?
    (self.gender == "Male" || self.gender == "Unisex" || self.gender = "Men") && !self.first_male_model_image_url.blank?
  end

  def has_female_image?
    (self.gender == "Female" || self.gender == "Unisex" || self.gender = "Women") && !self.first_female_model_image_url.blank?
  end

  def male?
    self.gender == "Male" || self.gender == "Men"
  end

  private

  # ensure that there are no line items referencing this product
  def ensure_not_referenced_by_any_line_item
    if line_items.empty?
      return true
    else
      errors.add(:base, 'Line Items present')
      return false
    end
  end

end
