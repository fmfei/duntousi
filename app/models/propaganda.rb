# coding: utf-8
class Propaganda < ActiveRecord::Base
  # attr_accessible :name, :position, :parent_id, :weight
  belongs_to :parent, :class_name => "Propaganda"
  has_many :children, :class_name => "Propaganda", :foreign_key => :parent_id
  has_many :articles

  validates :name, uniqueness: true
  
  default_scope {order(:id)}
  scope :notice, -> {where(:name => '网站公告')}
  scope :fabiao, -> {where(:name => '发标公告')}
  scope :about_us, -> {where(:name => '关于我们')}
  scope :help, -> {where(:name => '各类常见问题')}

  #有子栏目的栏目（新闻列表。。。）
  scope :has_children, -> {where("name != '关于我们'")}


  def self.current
    self.first
  end

  def self.level_one
    self.where(:parent_id => nil)
  end

  def art_show
    self.articles.order('id').where(:show_nav => true)
  end

  def self.notice
    Propaganda.where(:name => '网站公告').first
  end

end
