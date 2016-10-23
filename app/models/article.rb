# coding: utf-8
class Article < ActiveRecord::Base
  # attr_accessible :user_id, :title, :content, :is_top, :is_home, :status, :propaganda_id, :position, :show_nav
  belongs_to :propaganda
  belongs_to :user

  #default_scope order(:id)
  scope :order_by_id, -> {order(:id)}
  scope :order_by_time, -> {order('updated_at desc')}
  scope :top, -> {where(:is_top => true)}
  scope :notice, -> {where(:propaganda_id => Propaganda.notice.id).order('created_at desc')}
  scope :fabiao, -> {where(:propaganda_id => Propaganda.fabiao.first.id).order('created_at desc')}
end
