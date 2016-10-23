# encoding: utf-8
class Account::DebtsController < Account::BaseController

  # 债权列表
  def index
    @bids  = current_user.bids.repaying.paginate :page => params[:page], :per_page => 20
  end

  # 转让中
  def selling_list
    @bids  = current_user.bids.for_sale.paginate :page => params[:page], :per_page => 20
    render :index
  end

  def sold
    @bids  = current_user.bids.select("distinct on(bids.id) bids.*").joins('inner join bids as bids2 on bids2.from_bid_id = bids.id').paginate :page => params[:page], :per_page => 20
  end

  # 转让表单
  def sell
    @bid = Bid.find params[:id]
    if !@bid.can_be_sold?
      redirect_to account_debts_path
    end
  end

  # 叫卖
  def hawk
    @bid = Bid.find params[:id]
    for_sale_amount = params[:bid][:for_sale_amount].to_f
    if for_sale_amount > @bid.not_collected_principal
      flash[:error] = '转让金额不能大于未还本金'
      redirect_to :sell
      return
    end

    if (@bid.loan.min_invest.present? && for_sale_amount < @bid.loan.min_invest)
      flash[:error] = "转让金额须大于#{@bid.loan.min_invest}"
      redirect_to :sell
      return
    end

    @bid.hawk for_sale_amount

    redirect_to :action => :index
  end

  # 取消叫卖
  def cancel_hawk
    @bid = Bid.find params[:id]
    @bid.cancel_hawk
    redirect_to :action => :index
  end

end