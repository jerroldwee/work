class LineItem < ActiveRecord::Base
  belongs_to :order
  belongs_to :product
  belongs_to :cart
  belongs_to :lens
  belongs_to :color

  serialize :info

  attr_accessor :no
  attr_accessor :meta_info
  
  def color_name
    self.color ? self.color.name : ""
  end

  def total_price
    product.price * quantity
  end

  def meta(key)
    (meta_info || {})[key] || ""
  end

  def meta_str
    (meta_info || {}).to_a.select{|s|!s[1].blank?}.select{|s|s[0].to_s != "prescription_type"}.map{|m|"<b>"+m[0].camelize.gsub(/([a-z])([A-Z])/, '\1 \2').sub("Prescription", "")+"</b>: "+CGI.escape_html(m[1])}.join('<br/>').html_safe
  end

  def new_line_item?
    self.no.blank? || (self.no =~ /^_/)
  end

  def attachment
    if self.attachment_guid
      Attachment.where(:guid => self.attachment_guid).first
    else
      nil
    end
  end

  def amount
    line = self
    line.quantity * ((line.product.price||0) + (line.lens ? line.lens.price||0 : 0))
  end

end
