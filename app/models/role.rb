# coding: utf-8
class Role < ActiveRecord::Base
  has_and_belongs_to_many :users, :join_table => 'users_roles'
  has_and_belongs_to_many :permissions

  scopify
  # attr_accessible :name, :permission_ids, :is_admin
  validates :name, uniqueness: true

  scope :is_admin, -> {where(:is_admin => true)}
  scope :is_lender,  -> {where(:name => '投资人')}
  scope :is_junior_auditor,  -> {where(:name => '初级审核')}
  scope :is_senior_auditor,  -> {where(:name => '高级审核')}
  scope :is_server,  -> {where(:name => '客服')}
  scope :is_accountant,  -> {where(:name => '财务')}
  scope :is_super_admin,  -> {where(:name => '超级管理员')}
  default_scope {order('id desc')}

end
