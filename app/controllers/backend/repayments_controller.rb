# encoding: utf-8
class Backend::RepaymentsController < Backend::BaseController
  def index
    @title = '还款管理'
    @q = Repayment.send(params[:state] || 'unpaid').order("due_date #{params[:state]=='paid' ? 'desc' : 'asc'}").ransack(params[:q])
    @repayments = @q.result.paginate :page => params[:page], :per_page => 20
  end

  def show
    @repayment = Repayment.find(params[:id])
    @collections = @repayment.collections
    @title = '还款详情'
  end

  # 借款人还款
  def update

    repayment = Repayment.find(params[:id])
    Repayment.transaction do
      if repayment.state == 'unpaid'
        # 账户充值
        CashFlow.recharge_for repayment.user, repayment.amount

        # 还款，生成cash_flow
        repayment.collections.each do |collection|
          collection.pay
        end

        # 修改状态
        repayment.update_attribute(:state, 'paid')
        repayment.update_attribute(:paid_at, Time.now)
        repayment.user.minus_not_repay_total(repayment.amount)
        # 最后一次还款，设置还款完成。
        if repayment.month_index == repayment.loan.months
          repayment.loan.set_finish
        end

        # 取消债权转让
        repayment.loan.bids.for_sale.each{ |bid| bid.cancel_hawk }
      end
      #通知借款人已经还款
      repayment.send_messages("借款人还款")
    end

    redirect_to backend_repayments_path(:state => 'unpaid')

  end

end