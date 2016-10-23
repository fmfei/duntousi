class Api::CashFlowsController < Api::BaseController

  before_action :authenticate_user!, :verify_lender

  ##
  # 交易记录
  #
  # GET /api/cash_flows
  #
  # params
  #   page: 页码
  #   per_page: 可为空，默认10
  # return
  #  {
  #     "status": 1,
  #     "message": "success",
  #     "data": {
  #         "cash_flows": [
  #             {
  #                 "created_at": "2015/11/27/ 14:45",
  #                 "description": "手动投标",
  #                 "amount": "100.00￥",
  #                 "available": "9389.31￥"
  #             },
  #             {
  #                 "created_at": "2015/11/27/ 14:45",
  #                 "description": "手动投标",
  #                 "amount": "100.00￥",
  #                 "available": "9489.31￥"
  #             }
  #         ]
  #     }
  #  }
  def index
    @cash_flows = current_user.cash_flows.order('id desc').paginate :page => params[:page], :per_page => 10
  end

  ##
  # 投标中的项目
  #
  # GET /api/cash_flows/bids
  #
  # params
  #   page: 页码
  #   per_page: 可为空，默认10
  # return
  #  {
  #     "status": 1,
  #     "message": "success",
  #     "data": {
  #         "bids": [
  #             {
  #                 "title": "周游世界",
  #                 "invest_month": 1,
  #                 "amount": 200000,
  #                 "interest": 16,
  #                 "invest_amount": "100.0",
  #                 "status": "投标中",
  #                 "created_at": "2015/11/18/ 10:44"
  #             },
  #             {
  #                 "title": "买房",
  #                 "invest_month": 1,
  #                 "amount": 50000,
  #                 "interest": 12,
  #                 "invest_amount": "9120.0",
  #                 "status": "投标中",
  #                 "created_at": "2015/11/19/ 14:06"
  #             }
  #         ]
  #     }
  #  }
  def bids
    @bids = current_user.bids.status_in(['bidding', 'bids_auditing']).order("created_at desc").paginate :page => params[:page], :per_page => 10
  end

  ##
  # 还款中的项目（参数同投标中的项目）
  #
  # GET /api/cash_flows/repaying
  def repaying
    @bids = current_user.bids.status_in(['repaying', 'overdue']).order("created_at desc").paginate :page => params[:page], :per_page => 10
    render :bids
  end

  ##
  # 已还清的项目（参数同投标中的项目）
  #
  # GET /api/cash_flows/finished
  def finished
    @bids = current_user.bids.finished.order("created_at desc").paginate :page => params[:page], :per_page => 10
    render :bids
  end

  ##
  # 理财统计
  #
  # GET /api/cash_flows/stat
  #
  #  {
  #     "status": 1,
  #     "message": "success",
  #     "data": {
  #         "total_amount": "52256.09￥", # 账户总额
  #         "available": "9389.30￥", # 可用金额
  #         "freeze_amount": "111.00￥", # 冻结总额
  #         "not_collection_total": "42755.79￥", # 待收总额
  #         "not_collection_principal": "42211.52￥", # 待收本金
  #         "not_collection_interest": "544.27￥", # 待收利息
  #         "recharge_total": "61533.00￥", # 充值总额
  #         "withdraw_total": "111.00￥", # 提现总额
  #         "invest_total": "102365.05￥", # 累计投资
  #         "collected_interest": "677.36￥", # 已赚利息
  #         "prize_total": "132.47￥", # 奖励总额
  #         "bidding_total": "10520.00￥", # 投标中总金额
  #         "withdraw_fee_total": "0.03￥", # 提现手续费
  #         "sell_bid_fee_total": "0.00￥" # 债权转让手续费
  #     }
  #  }
  def stat
  end



end