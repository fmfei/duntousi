#coding=utf-8
require 'uri'
require "open-uri"
require 'net/http'

class Idcard
	URL = 'http://op.juhe.cn/idcard/query'
	APPKEY = '76920933d8f422d29e24ecc10d6d311e'

	def self.request idcard, realname
		response = JSON.parse Net::HTTP.get(URI(URI.encode("#{URL}?key=#{APPKEY}&idcard=#{idcard}&realname=#{realname}")))
		Rails.logger.info '@@@@@@@@@@@@@@@@@@@'
		Rails.logger.info response
		Rails.logger.info '@@@@@@@@@@@@@@@@@@@'
		if response["error_code"] == 0 && response["result"]['res'] == 1
			return true
		else
			return false
		end
	end
end