#coding=utf-8
require 'xmlsimple'
require 'uri'
require "open-uri"
class JuheSms
  SENDURL = 'http://v.juhe.cn/sms/send'
  TPLID = 2292
  APPKEY = '8ca537818e6fd8d44420aa1fccd024fb'
  TPL = 0000

  def self.send_verify_code(nums_str, verify_code)
    open(URI::encode("#{SENDURL}?mobile=#{nums_str}&tpl_id=#{TPLID}&tpl_value=#code#=#{verify_code}&key=#{APPKEY}"))
  end

  # 回款通知短信
  def self.send_repay_notice(mobile, amount)
    open(URI::encode("#{SENDURL}?mobile=#{mobile}&tpl_id=#{2773}&tpl_value=#amount#=#{amount}&key=#{APPKEY}"))
  end

  def JuheSms.send_lender(mobile)
    open(URI::encode("#{SENDURL}?mobile=#{mobile}&tpl_id=#{TPL}&key=#{APPKEY}"))
  end

end