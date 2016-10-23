# -*- coding: utf-8 -*-
# 宝付支付
require 'digest/md5'
class Baofoo

  extend PayGateway

  # URL = "https://vgw.baofoo.com/payindex" # 测试地址
  URL = "https://gw.baofoo.com/payindex" # 正式地址
  PAY_SUCCESS_RESPCODE = SUCC_RESP_CODE = "1"
  @callback = ""
  @merchant_id = "401771" # 商户ID，测试：100000178，正式：401771
  @terminal_id = "20173" # 终端 ID
  @interface_version = '4.0' # 接口版本
  @key_type = '1' # 加密类型
  @pay_id = '' # 功能 ID, 若选择全部银行则为空字符串,选择全 部银行即跳转宝付收银台选择银行
  @notice_type = '1' # 通知类型

  @md5key = 'g37g8yvg3ws8sq2x' # 测试： abcdefg

  # 文明字段次序
  @sign_value_keys = %w{MemberID TerminalID TransID Result ResultDesc FactMoney AdditionalInfo SuccTime Md5Sign}

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
      response_params["Md5Sign"].eql?(md5ed_sign_value response_params) and response_params["Result"].eql?(PAY_SUCCESS_RESPCODE) and valid_amount?(response_params["TransID"],response_params["FactMoney"])
      Rails.logger.info (md5ed_sign_value response_params)
      Rails.logger.info '@@@@@@@@@@@@@@@@@@@@@@'
    end

    def valid_amount? mer_order_num,tran_amt
      if pay_order_in_db = PayOrder.find_by_uuid(mer_order_num)
        Rails.logger.info '@@@@@'
        Rails.logger.info pay_order_in_db.amount
        Rails.logger.info tran_amt
        pay_order_in_db.amount.to_f.eql?(tran_amt.to_f / 100)
      else
        false
      end
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
      {:text=>"OK"}
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
        "MemberID" => @merchant_id,
        "TerminalID" => @terminal_id,
        "InterfaceVersion" => @interface_version,
        "KeyType" => @key_type,
        "PayID" => '',
        "TradeDate" => Time.now.strftime("%Y%m%d%H%M%S"), #交易时间14位
        "TransID" => order_num,
        "OrderMoney" => (amt.to_f*100).to_i,
        "NoticeType" => @notice_type,
        "PageUrl" => callback+"/Baofoo/1", # 前台返回地址
        "ReturnUrl" => callback+"/Baofoo/2"  #后台返回地址
      }
      params["Signature"] = Digest::MD5.hexdigest("#{params['MemberID']}|#{params['PayID']}|#{params['TradeDate']}|#{params['TransID']}|#{params['OrderMoney']}|#{params['PageUrl']}|#{params['ReturnUrl']}|#{params['NoticeType']}|#{@md5key}").downcase
      params
    end

    # MD5 明文 构造签名
    def md5ed_sign_value params
      Digest::MD5.hexdigest(@sign_value_keys.map{|key| "#{ key.eql?('Md5Sign')  ?  'Md5Sign='+@md5key : key+'='+params[key] }"}*"~|~").downcase
    end

  end
end
