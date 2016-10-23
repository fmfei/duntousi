# -*- coding: utf-8 -*-
class ThirdPay
  def self.request_url(pay_class,pay_order, callback, gate_id=nil)
    pay_order.update_attribute(:pay_class,pay_class.titleize.gsub(/\s/,""))

    Object.const_get(pay_class.titleize.gsub(/\s/,"")).request_url(pay_order,callback, gate_id)
  end
  def self.verify_response(params)
    pay_class = self.get_pay_class(params)
    pay_class.verify_response?(params)
  end
  def self.uuid(params)
    pay_class = self.get_pay_class(params)
    pay_class.uuid(params)
  end
  def self.notice_succ_response(params)
    pay_class = self.get_pay_class(params)
    pay_class.notice_succ_response
  end

  def self.order_id(params)
    pay_class = self.get_pay_class(params)
    pay_class.order_id(params)
  end

  def self.out_order_id(params)
    pay_class = self.get_pay_class(params)
    pay_class.out_order_id(params)
  end
  def self.notice_from(params)
    pay_class = self.get_pay_class(params)
    pay_class.notice_from(params)
  end

  def self.get_pay_class(params)
    Object.const_get(params[:pay_class].titleize.gsub(/\s/,""))
  end

  def self.get_fee(params,money)
    pay_class = self.get_pay_class(params)
    pay_class.get_fee(money)
  end

end