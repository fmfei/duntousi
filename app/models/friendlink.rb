# coding: utf-8

class Friendlink < ActiveRecord::Base
  # attr_accessible :title, :url, :weight, :status

  default_scope {order("weight")}
  mount_uploader :logo, LogoUploader
end
