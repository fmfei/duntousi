class SmsJob
	@queue = :high

  def self.perform(job_name, mobile, code)
  	self.send(job_name, mobile, code)
  end

	def self.send_verify_code mobile, code
		Sms.send_verify_code(mobile, code)
	end

  # 回款通知短信
  def self.send_repay_notice(mobile, amount)
  	Sms.send_repay_notice(mobile, amount)
  end

  def self.send_lender(mobile)
    Sms.send_lender(mobile)
  end
end