# -*- coding: utf-8 -*-
# 支付网关的公共方法 模块
module PayGateway
  # @params[String] 响应参数中的订单号
  # @params[String] 响应参数中的金额
  # @return[bool]
  def valid_pay_order? mer_order_num,tran_amt
     if pay_order_in_db = PayOrder.find_by_uuid(mer_order_num)
      Rails.logger.info pay_order_in_db.amount
       pay_order_in_db.amount.eql?(BigDecimal.new(tran_amt))
     else
       false
     end
  end

  # @param[Hash] 通知参数集合
  # @return[Fixnum] 来源编号 1:前台 2:后台,这是一个约定
  def notice_from response_params
    response_params["notice_from"].to_i
  end
end
