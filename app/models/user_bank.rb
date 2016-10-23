# coding: utf-8
class UserBank < ActiveRecord::Base
  # attr_accessible :area, :bank, :branch, :card_number, :city, :province, :user_id
  belongs_to :user
  validates_presence_of :card_number, :message => '卡号不能为空'
  validates_uniqueness_of :card_number, :message => "此银行卡已存在"
end
