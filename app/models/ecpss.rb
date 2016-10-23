# -*- coding: utf-8 -*-
# 汇潮支付
require 'digest/md5'
class Ecpss

  extend PayGateway

  URL = "https://pay.ecpss.com/sslpayment"
  PAY_SUCCESS_RESPCODE = SUCC_RESP_CODE = "88"
  @callback = ""
  @merchant_id = "21316" # 商户ID，测试：20000
  @md5key = 'o(CWEtOY' # 测试： huichaoceshi

  # 文明字段次序
  @sign_value_keys = %w{BillNo Amount Succeed MD5key}

  class << self
    # 请求地址
    def request_url pay_order, callback=@callback, bank_code=''
      "#{URL+"?"+query(sprintf("%.2f",pay_order.amount), pay_order.uuid, callback).map{|k,v| "#{k}=#{v}" }*"&"}"
    end

    # 如果code包含在BANKCODE返回true, 否则 false
    def bank_code_include? code
      BANKCODE.map{|b| b[:code] }.include?(code)
    end

    # 验证响应是否是 发来的并支付成功了
    # @param[Hash] 返回参数
    def verify_response? response_params
      # 是从汇潮支付发来的 并且 支付成功 并且要和数据库中的订单核对金额
      response_params["SignMD5info"].eql?(md5ed_sign_value response_params) and response_params["Succeed"].eql?(PAY_SUCCESS_RESPCODE) and valid_pay_order?(response_params["BillNo"],response_params["Amount"])
    end


    # 支付网关的订单流水号
    # @param[Hash] 通知参数集合
    # @return[String]
    def order_id response_params
      ''
    end

    # 支付网关发往银行的订单流水号
    # @params[Hash] 通知参数集合
    # @return[String]
    def out_order_id response_params
      ''
    end

    # 对成功通知的响应
    def notice_succ_response
      {:text=>"ok"}
    end

    # 我们的订单流水号
    # @params[Hash]
    def uuid response_params
      response_params["BillNo"]
    end

    # 支付手续费
    def get_fee(money)
      (money.to_f * 0.0025).round(2)
    end

    def get_real_fee(money)
      (money.to_f / (1-0.0025)).round(2)-money
    end

    def give_fee(money)
      2
    end

    # 汇入手续费
    def import_fee money
      0
    end

    private

    # 构造 查询参数
    # 支付金额
    # 订单号
    # 返回地址
    # 银行code
    def query amt, order_num, callback
      params = {
        "MerNo" => @merchant_id,
        "BillNo" => order_num,
        "Amount" => amt,
        "ReturnURL" => callback+"/Ecpss/1", # 前台返回地址
        "AdviceURL" => callback+"/Ecpss/2"  #后台返回地址
      }
      params["SignInfo"] = Digest::MD5.hexdigest("#{@merchant_id}&#{order_num}&#{amt}&#{params['ReturnURL']}&#{@md5key}").upcase
      params["orderTime"] = Time.now.strftime("%Y%m%d%H%M%S") #交易时间14位
      params
    end

    # MD5 明文 构造签名
    def md5ed_sign_value params
      Digest::MD5.hexdigest(@sign_value_keys.map{|key| "#{ key.eql?('MD5key')  ?  @md5key : params[key] }"}*"&").upcase
    end

  end
end
