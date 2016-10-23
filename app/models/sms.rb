#coding=utf-8
class Sms

  def self.send_verify_code(mobile, verify_code)
    JuheSms.send_verify_code(mobile, verify_code)
  end

  def self.send_repay_notice(mobile, amount)
    JuheSms.send_repay_notice(mobile, amount)
  end

  def self.send_lender(mobile)
    JuheSms.send_lender(mobile)
  end

end