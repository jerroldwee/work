class Prescription < ActiveRecord::Base
  serialize :info
  belongs_to :user
end
