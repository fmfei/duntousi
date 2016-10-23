# encoding: utf-8
class Api::LoansController < Api::BaseController
  include ApplicationHelper
  before_action :authenticate_user!, :verify_lender, :only => [:create]

  ##
  #
  # 借款详情
  #
  # GET /api/loans/:id
  #
  # params:
  #
  #  id 借款id
  #
  # 返回结果
  #
  #  {
  #     "status": 1,
  #     "message": "success",
  #     "data": {
  #         "id": 45,
  #         "amount": 60000,
  #         "available_amount": 40100,
  #         "process": 33.17,
  #         "title": "资金周转",
  #         "interest": 12,
  #         "months": 1,
  #         "desc": "借款详情啊但是发的发阿打发快递费，阿斯顿发的说法的",
  #         "repay_style": "equal",
  #         "gender": "男性",
  #         "marry": "未婚",
  #         "wenhua": "",
  #         "income": 50000,
  #         "shebao": "无",
  #         "house": "无",
  #         "car": "无",
  #         "state": "投标中",
  #         "files": [
  #             {
  #                 "category": "借款申请表",
  #                 "desc": "借款申请表"
  #             },
  #             {
  #                 "category": "公司证件",
  #                 "desc": "营业执照"
  #             },
  #             {
  #                 "category": "抵押借款协议",
  #                 "desc": "房产证"
  #             }
  #         ],
  #         "bids": [
  #             {
  #                 "mobile": "150****0167",
  #                 "invest_amount": 15000,
  #                 "created_at": "2015-11-19 14:45:57",
  #                 "invest_type": "自动投标"
  #             },
  #             {
  #                 "mobile": "152****7231",
  #                 "invest_amount": 100,
  #                 "created_at": "2015-11-30 17:00:25",
  #                 "invest_type": "手动投标"
  #             }
  #         ]
  #     }
  #  }
  def show

    @loan = Loan.can_be_seen.find(params[:id])
    @identifications = []
    @loan.borrower.identifications.each do |i|
      if i.file.url.present?
        @identifications << {'category': t(i.category), 'desc': i.desc, 'url': i.file.url}
      end
    end
    @bids = []
    @loan.bids.each do |bid|
      @bids << {mobile: (bid.user.mobile.try(:[],0..2).to_s+'****'+bid.user.mobile.try(:[],-4..-1).to_s), invest_amount: bid.invest_amount.to_f.round(2), interest: bid.interest, created_at: format_time(bid.created_at), invest_type: (bid.category)}
    end
  end

  ##
  #
  # 我要投资接口
  #
  # GET /api/loans/newest
  #
  # 返回结果同借款详情
  #
  def newest
    @loan = Loan.where("pass = ''").bidding_or_after.order('available_amount desc, id desc').first
    render 'show'
  end

  ##
  #
  # 借款列表
  #
  # GET /api/loans
  #
  # 返回结果
  #
  #  {
  #     "status": 1,
  #     "message": "success",
  #     "data": {
  #         "loans": [
  #             {
  #                 "id": 11,
  #                 "title": "资金流动",
  #                 "amount": 80000,
  #                 "available_amount": 80000,
  #                 "months": 3,
  #                 "interest": 5,
  #                 "repay_style": "equal",
  #                 "repaying": false,
  #                 "desc": "借款详情啊但是发的发阿打发快递费，阿斯顿发的说法的",
  #                 "state": "流标" #["初审", "终审", "等待发标", "投标中", "流标", "满标审核中", "还款中", "逾期", "还款完成"]
  #             },
  #             {
  #                 "id": 7,
  #                 "title": "买房",
  #                 "amount": 60000,
  #                 "available_amount": 50000,
  #                 "months": 3,
  #                 "interest": 12,
  #                 "repay_style": "equal",
  #                 "repaying": false,
  #                 "desc": "借款详情啊但是发的发阿打发快递费，阿斯顿发的说法的",
  #                 "state": "流标"
  #             },
  #             {
  #                 "id": 14,
  #                 "title": "资金周转",
  #                 "amount": 60000,
  #                 "available_amount": 46774.21,
  #                 "months": 1,
  #                 "interest": 12,
  #                 "repay_style": "equal",
  #                 "repaying": false,
  #                 "desc": "借款详情啊但是发的发阿打发快递费，阿斯顿发的说法的",
  #                 "state": "流标"
  #             },
  #             {
  #                 "id": 45,
  #                 "title": "资金周转",
  #                 "amount": 60000,
  #                 "available_amount": 44900,
  #                 "months": 1,
  #                 "interest": 12,
  #                 "repay_style": "equal",
  #                 "repaying": false,
  #                 "desc": "借款详情啊但是发的发阿打发快递费，阿斯顿发的说法的",
  #                 "state": "投标中"
  #             },
  #             {
  #                 "id": 6,
  #                 "title": "WANG",
  #                 "amount": 50000,
  #                 "available_amount": 37001,
  #                 "months": 3,
  #                 "interest": 12,
  #                 "repay_style": "equal",
  #                 "repaying": false,
  #                 "desc": "借款详情啊但是发的发阿打发快递费，阿斯顿发的说法的",
  #                 "state": "流标"
  #             }
  #         ]
  #     }
  # }
  def index
    @loans = Loan.where("pass = ''").bidding_or_after.order('available_amount desc, id desc').limit(5)
  end

  ##
  #
  # 投标
  #
  # POST /api/loans
  #
  # params:
  #
  #  bid[invest_amount]  投资金额
  #  bid[loan_id]  投标id
  #  bid[pass]  约标密码，非约标为空
  #
  # 返回结果
  #
  #  {
  #     "status": 1,
  #     "message": "success",
  #     "data": {
  #         "id": 45,
  #         "amount": 60000,
  #         "available_amount": 44900,
  #         "process": 25.17,
  #         "title": "资金周转",
  #         "interest": 12,
  #         "months": 1,
  #         "desc": "借款详情啊但是发的发阿打发快递费，阿斯顿发的说法的",
  #         "repay_style": "equal",
  #         "gender": "男性",
  #         "marry": "未婚",
  #         "wenhua": "",
  #         "income": 50000,
  #         "shebao": "无",
  #         "house": "无",
  #         "car": "无",
  #         "state": "投标中" # ["初审", "终审", "等待发标", "投标中", "流标", "满标审核中", "还款中", "逾期", "还款完成"]
  #     }
  #  }
  #
  #  {
  #     "status": 0,
  #     "message": "错误信息"
  #  }
  def create
    if params[:bid][:invest_amount].to_f > current_user.user_cash.available.to_f.round(2)
      @message = '账户余额不足'
      @status = 0
      render 'layouts/api', layout: false
      return
    end

    loan = Loan.can_be_seen.find(params[:bid][:loan_id])

    if loan.pass.present? && loan.pass != params[:bid][:pass]
      @message = '约标密码错误'
      @status = 0
      render 'layouts/api', layout: false
      return
    end

    if loan.min_invest.present? && params[:bid][:invest_amount].to_f < loan.min_invest
      @message = "投资金额不能小于#{loan.min_invest}"
      @status = 0
      render 'layouts/api', layout: false
      return
    end

    if loan.min_invest.present? && (loan.available_amount < 2 * loan.min_invest) && (params[:bid][:invest_amount].to_f < loan.available_amount)
      @message = "当前标的可投金额为#{loan.available_amount}元，请一次投满。"
      @status = 0
      render 'layouts/api', layout: false
      return
    end

    # 防止：剩余金额 < 最小投资额
    if loan.min_invest.present? && (loan.available_amount > 2 * loan.min_invest) && (loan.available_amount > params[:bid][:invest_amount].to_f) && ((loan.available_amount - params[:bid][:invest_amount].to_f) < loan.min_invest)
      params[:bid][:invest_amount] = loan.available_amount - loan.min_invest
    end

    if loan.max_invest.present? && loan.min_invest.present? && params[:bid][:invest_amount].to_f > (loan.max_invest - loan.min_invest) && params[:bid][:invest_amount].to_f < loan.max_invest
      params[:bid][:invest_amount] = loan.max_invest - loan.min_invest
    end

    if loan.max_invest.present? && params[:bid][:invest_amount].to_f > loan.max_invest
      params[:bid][:invest_amount] = loan.max_invest
    end

    if params[:bid][:invest_amount].to_f > loan.available_amount
      params[:bid][:invest_amount] = loan.available_amount
    end

    begin
      bid = Bid.create_by_user current_user, params[:bid][:loan_id], params[:bid][:invest_amount]
      # 投资奖励
      # if params[:bid][:invest_amount].to_f >= 10000
      #   (params[:bid][:invest_amount].to_i / 10000).to_i.times do
      #     CircleRecord.create_for(current_user)
      #   end
      # end
      # @message = "success"
      # @status = 1
      @loan = loan.reload
      # render 'layouts/api', layout: false
      render 'show'
      return
    rescue Exception => ex
      @message = "error"
      @status = 0
      render 'layouts/api', layout: false
      return
    end
  end

end