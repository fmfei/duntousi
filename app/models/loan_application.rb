# coding: utf-8
class LoanApplication < ActiveRecord::Base
  # attr_accessible :amount, :loan_usage, :name, :id_card, :phone, :email, :register_addr, :addr, :monthly_income, :monthly_expense, :company, :title
   scope :today, -> {where('date(created_at) = ?', Date.today)}

validates_presence_of :name, :message => "用户名不能为空!"
# validates_length_of  :phone, :message => "手机号码格式不正确!", :with => /(^\d{15}$)|(^\d{18}$)|(^\d{17}(\d|X|x)$)/
validates_length_of :phone, :maximum => 11,  :message => "手机号码格式不正确!"
validates_length_of :id_card, :maximum => 18,  :message => "身份证号码格式不正确!"

# validates_length_of  :id_card, :message => "身份证号码格式不正确!", :with => /^0{0,1}(13[0-9]|15[0-9]|17[0-9]|18[0-9]|19[0-9])[0-9]{8}$/
validates_format_of :email, :message => "邮箱格式不正确!", :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i
end
