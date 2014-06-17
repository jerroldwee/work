class Promotion < ActiveRecord::Base

  has_attached_file :upload, :styles => { 
    :large => "860x400>", 
    :medium => "430x200>",
    :small => "215x100>" 
  }
  
end
