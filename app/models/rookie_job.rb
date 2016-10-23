class RookieJob
  @queue = :high

  def self.perform
    bids = RookieBid.can_be_checked

    bids.each do |bid|
      if bid.due_date.to_date === Time.now.to_date
        #bid状态变成完成
        bid.update_attribute(:status, 'finished')
        #投资人增加已收回利息，减少待回收利息
        bid.user.add_collected_interest(bid.collection_interest)
        bid.user.minus_not_collection_interest(bid.collection_interest)
        #创建资金流
        CashFlow.create_rookie bid
        #短信通知用户利息已到账
        Resque.enqueue(SmsJob, :send_repay_notice, bid.user.mobile, bid.collection_interest.to_f.round(2))
      end
    end
  end

end