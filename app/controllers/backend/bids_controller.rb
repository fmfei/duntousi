#encoding:utf-8
class Backend::BidsController < Backend::BaseController

  def index
    @title = '投标管理'
    @q = Bid.ransack(params[:q])
    @bids = @q.result.includes(:user).includes(:loan).reorder("id desc").paginate(:page => params[:page], :per_page => 20)
  end

  def show
    @title = "投标管理"
    @bid = Bid.find(params[:id])
  end

  def belongs_to_loan
    @title = '投标详情'
    @loan = Loan.find(params[:loan_id])
    @bids = @loan.bids
  end

  def selling
    @title = "正在转让的债权"
    @bids = Bid.for_sale.includes(:user).includes(:loan).reorder("for_sale_time desc").paginate(:page => params[:page], :per_page => 20)
  end

  def sold
    @title = "已转让债权"
    @bids = Bid.bought_from_bid.includes(:user, :from_bid).includes(:loan).reorder("updated_at desc").paginate(:page => params[:page], :per_page => 20)
  end

end
