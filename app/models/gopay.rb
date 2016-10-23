# -*- coding: utf-8 -*-
# 国付宝
# 测试账户:
require 'digest/md5'
class Gopay

  extend PayGateway

  URL = "https://www.gopay.com.cn/PGServer/Trans/WebClientAction.do"
  PAY_SUCCESS_RESPCODE = SUCC_RESP_CODE = "0000"
  @callback = ""
  @verfication_code = "qscihbedc486wsx" # 我的身份识别码
  @vir_card_no_in = "0000000002000151740" # 国付宝转入账户，正式环境
  #@merchant_id = "0000003358" # 商户ID
  @merchant_id = "0000104034" # 商户ID
  # 文明字段次序
  @sign_value_keys = %w{version tranCode
                        merchantID merOrderNum
                        tranAmt feeAmt tranDateTime
                        frontMerUrl backgroundMerUrl
                        orderId gopayOutOrderId
                        tranIP respCode VerficationCode}

  BANKCODE = [{ name: '中国工商银行', code: 'ICBC', img: 'bank_1.jpg'},
              { name: '招商银行', code: 'CMB', img: 'bank_2.jpg' },
              { name: '中国农业银行', code: 'ABC', img: 'bank_3.jpg' },
              { name: '中国建设银行', code: 'CCB', img: 'bank_4.jpg' },
              { name: '交通银行', code: 'BOCOM', img: 'bank_5.jpg' },
              { name: '兴业银行', code: 'CIB', img: 'bank_6.jpg' },
              { name: '中国民生银行', code: 'CMBC', img: 'CMBC.jpg'},
              { name: '华夏银行', code: 'HXBC', img: 'bank_8.jpg' },
              { name: '光大银行', code: 'CEB', img: 'bank_9.jpg' },
              { name: '广东发展银行', code: 'GDB', img: 'bank_10.jpg' },
              { name: '中信银行', code: 'CITIC', img: 'bank_11.jpg'  },
              { name: '中国银行', code: 'BOC', img: 'bank_12.jpg' },
              { name: '上海浦东发展银行', code: 'SPDB', img: 'SPDB.jpg' },
              { name: '中国邮政储蓄银行', code: 'PSBC', img: 'PSBC.jpg' },
              { name: '其他银行', code: '', img: '' }, ]


  class << self
    # 请求地址
    def request_url pay_order, callback=@callback, bank_code=''
      "#{URL+"?"+query(sprintf("%.2f",pay_order.amount), pay_order.uuid,callback, bank_code).map{|k,v| "#{k}=#{v}" }*"&"}"
    end

    # 如果code包含在BANKCODE返回true, 否则 false
    def bank_code_include? code
      BANKCODE.map{|b| b[:code] }.include?(code)
    end

    # 验证响应是否是 国付宝发来的并支付成功了
    # @param[Hash] 返回参数
    def verify_response? response_params
      # 是从国付宝发来的 并且 支付成功 并且要和数据库中的订单核对金额
      response_params["signValue"].eql?(md5ed_sign_value response_params) and response_params["respCode"].eql?(PAY_SUCCESS_RESPCODE) and valid_pay_order?(response_params["merOrderNum"],response_params["tranAmt"])
    end


    # 支付网关的订单流水号
    # @param[Hash] 通知参数集合
    # @return[String]
    def order_id response_params
      response_params["orderId"].to_s
    end

    # 支付网关发往银行的订单流水号
    # @params[Hash] 通知参数集合
    # @return[String]
    def out_order_id response_params
      response_params["gopayOutOrderId"].to_s
    end

    # 对成功通知的响应
    def notice_succ_response
      {:text=>"RespCode=#{SUCC_RESP_CODE}"}
    end

    # 我们的订单流水号
    # @params[Hash]
    def uuid response_params
      response_params["merOrderNum"]
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

    # 国付宝 汇入手续费
    def import_fee money
      0
    end

    private

    # 构造 查询参数
    # 支付金额
    # 订单号
    # 返回地址
    # 银行code
    def query amt, order_num, callback, bank_code
      params = {
        "version" => "2.0",
        "language" => "1",
        "tranCode" => "8888",
        "merchantID" => @merchant_id,
        "merOrderNum" => order_num,
        "tranAmt" => amt,
        "feeAmt"=> "0.00",
        "currencyType"=>"156", # 币种156人民币
        "frontMerUrl" => callback+"/Gopay/1", # 前台返回地址
        "backgroundMerUrl" =>callback+"/Gopay/2",  #后台返回地址
        "tranDateTime"=>Time.now.strftime("%Y%m%d%H%M%S"), #交易时间14位
        "virCardNoIn"=>@vir_card_no_in,
        "tranIP"=>"127.0.0.1",
        "isRepeatSubmit"=>"",
        "goodsName" => "",
        "goodsDetail" => "",
        "buyerName" => "",
        "buyerContact" => "",
        "merRemark1" => "",
        "merRemark2" => "",
        "signValue"=>"",
        "bankCode" => bank_code,
        "userType" => ""
      }
      params["signValue"] = md5ed_sign_value(params)
      params
    end

    # MD5 明文 构造签名
    def md5ed_sign_value params
      Digest::MD5.hexdigest @sign_value_keys.map{|key| "#{key}=[#{ key.eql?('VerficationCode')  ?  @verfication_code : params[key] }]"}*""
    end

  end
end
