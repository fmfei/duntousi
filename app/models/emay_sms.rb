#coding=utf-8
require 'xmlsimple'
require 'uri'
require "open-uri"
class EmaySms
  # 需要配置用户名、密码
  USER = "xxxx-xxx-xxx-xxx"
  PWD = "xxxxxx"
  SENDURL = 'http://sdkhttp.eucp.b2m.cn/sdkproxy/sendsms.action'
  QUERYBALANCE = 'http://sdkhttp.eucp.b2m.cn/sdkproxy/querybalance.action'

  def self.send_verify_code(nums_str, verify_code)
    content = "【#{SystemConfig.company_name.value}】您好，感谢您选择#{SystemConfig.company_name.value}.本次操作的手机验证码：#{verify_code}，如非本人操作请致电：#{SystemConfig.phone400.value}."
    try_times = 0
    while (try_times<2) do
      begin
        open("#{SENDURL}?cdkey=#{USER}&password=#{PWD}&phone=#{nums_str}&message=#{URI.escape(content.encode("utf-8"))}") do |f|
          xml = XmlSimple.xml_in(f)
          if xml["error"] != ["0"]
            raise xml["message"].first
          end
        end
        break;
      rescue =>ex
        try_times+=1
        p ex.to_s
        if (try_times==2)
          return false
        end
      end
    end
    return true
  end

  def self.querybalance
    open("#{QUERYBALANCE}?cdkey=#{USER}&password=#{PWD}") do |f|
      xml = XmlSimple.xml_in(f)
      xml["message"].first
    end
  end

end