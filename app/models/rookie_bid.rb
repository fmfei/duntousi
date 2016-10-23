class RookieBid < ActiveRecord::Base
  belongs_to :user
  belongs_to :rookie_loan

  scope :can_be_checked, -> {where(status: 'repaying')}

  def self.create_by_user current_user, loan_id, invest_amount
    self.transaction do
      loan = RookieLoan.find(loan_id)
      if loan.loan_state_id == Dict::LoanState.bidding.id
        collection_interest = (invest_amount.to_f * (loan.interest.to_f * (loan.invest_day) / 36500)).round(2)

        bid = self.create(:user => current_user,
                          :rookie_loan_id => loan_id,
                          :invest_amount => invest_amount.to_f,
                          :invest_day => loan.invest_day,
                          :interest => loan.interest,
                          :status => 'repaying',
                          :due_date => Time.now + (loan.invest_day).day,
                          :collection_interest => collection_interest)
        #投资人增加待收利息
        bid.user.add_not_collection_interest(collection_interest)
        bid.user.minus_rookie_amount(invest_amount.to_f)
        #CashFlow.create_bid current_user, bid, loan
        RookieLoan.update_available_amount(loan, invest_amount)

        #向投资人发送站内信
        self.send_messages(bid, "审核通过")
      end
    end
  end

  def self.send_messages bid, status
    content = "您于#{bid.created_at.to_s(:long)}投资新手标#{bid.invest_amount.round(2)}元(借款用途：#{bid.rookie_loan.title})已经#{status}，感谢您对我们的关注和支持！"
    BidMessage.create(receive_user_id: bid.user_id, title: status, content: content, status: Dict::MessageStatus.unread.id)
  end
end
