class Attachement < ActiveRecord::Base
  belongs_to :product

  mount_uploader :pic_name, AttachementsUploader

  scope :main_pic, ->{where("is_main = true")}
  scope :normal_pic, ->{where("is_main = false")}
end
