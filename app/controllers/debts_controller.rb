# encoding: utf-8
include ApplicationHelper
class DebtsController < ApplicationController
  before_filter :authenticate_user!, :verify_lender, :only => [:new, :create]

  # 债权转让列表
  def index
    redirect_to '/debts_list'
    return
    @bids = Bid.for_sale.order('for_sale_time asc').paginate :page => params[:page], :per_page => 20
    @title = '债权转让'
  end

  def debt_json
    @bids = Bid.joins(:loan).select('bids.*,loans.title,loans.id as loand_id,loans.repay_style').for_sale.order('for_sale_time asc').paginate :page => params[:page], :per_page => 10
    @title = '债权转让'

    info = {
        total_pages: @bids.total_pages,
        current_page: @bids.current_page,
        loans: @bids,
        title: @title,
    }
    respond_to do |format|
      format.json do
        render json: info.to_json
      end
    end
  end

  # 详情
  def show
    @bid = Bid.for_sale.find(params[:id])
    return if @bid.blank?
    @loan = @bid.loan
    @child_bid = Bid.new(:user => current_user, :loan_id => @loan.id, :from_bid_id => @bid.id)

    # 投资100元，可得收益
    # @total = 0
    # @interest = Loan.calculator(@loan.repay_style, 100, @bid.for_sale_month, @loan.interest)
    # @interest.values.each{|v| @total += (v[:seed] + v[:interest])}
    # @earnings_tmp = @total - 100
    @title = '我要理财'

  end

  def new
    if current_user && current_user.auth_realname == 1
      @bid = Bid.for_sale.find(params[:id])
      return if @bid.blank?
      @loan = @bid.loan
      @child_bid = Bid.new(:user => current_user, :loan_id => @loan.id, :from_bid_id => @bid.id)
    end
    render layout: false
  end

  def show_debts
    @bid = Bid.for_sale.find(params[:id])
    return if @bid.blank?
    @loan = @bid.loan
    @child_bid = Bid.new(:user => current_user, :loan_id => @loan.id, :from_bid_id => @bid.id)

    # 投资100元，可得收益
    # @total = 0
    # @interest = Loan.calculator(@loan.repay_style, 100, @bid.for_sale_month, @loan.interest)
    # @interest.values.each{|v| @total += (v[:seed] + v[:interest])}
    # @earnings_tmp = @total - 100
    # @title = '我要理财'
    repaystyle = {"equal"=>"按月分期还款", "interest_only"=>"按月还息，到期还本", "at_due"=>"到期归还本息"}
    for_sale_month = @bid.for_sale_month
    loan_code = @loan.code ? @loan.code : @loan.id
    interest_year = percent(@loan.interest)
    bid_user_not_cur_user =  current_user.present? && @bid.user_id != current_user.id ? 1 : 0
    current_users =  current_user.present? ? 1:0

    identifications = []
    @loan.borrower.identifications.each do |i|
      if i.file.url.present?
        identifications << {category: t(i.category), desc: i.desc, url: i.file.url}
      end
    end
    user_info = { gender: @loan.borrower.info.gender, 
                  marry: @loan.borrower.info.marriage.try(:name),
                  wenhua: @loan.borrower.info.degree.try(:name),
                  income: @loan.borrower.info.income,
                  shebao: (@loan.borrower.info.social_security_id.present? ? '有' : '无'),
                  house: @loan.borrower.info.housing,
                  car: @loan.borrower.info.car
                }
    bids = []
    @loan.bids.each do |bid|
      bids << {name: (bid.user.username[0, 2]+'***'), invest_amount: bid.invest_amount, interest: bid.interest, created_at: format_time(bid.created_at), category: (bid.category)}
    end

    info = {
        state_name: @loan.state.name,
        loan_state_id: Dict::LoanState.bidding.id,
        current_user: current_users,
        bid_user_not_cur_user: bid_user_not_cur_user,
        interest_year:interest_year,
        for_sale_month:for_sale_month,
        repayment_methods: repaystyle[@loan.repay_style].to_s,
        loan_code: loan_code,
        earnings_tmp: @earnings_tmp,
        child_bid:@child_bid.from_bid_id,
        bid: @bid,
        loan: @loan,
        title: @title,
        desc: @loan.desc,
        identifications: identifications,
        user_info: user_info,
        bids: bids
    }
    respond_to do |format|
      format.json do
        render json: info.to_json
      end
    end
  end

  def create
    if params[:bid][:invest_amount].to_f > current_user.user_cash.available.to_f
      redirect_to "/show_debts?id=#{params[:bid][:from_bid_id]}&errors=账户余额不足"
      return
    end
    loan = Loan.can_be_seen.find(params[:bid][:loan_id])
    parent_bid = Bid.for_sale.find(params[:bid][:from_bid_id])

    if loan.min_invest.present? && params[:bid][:invest_amount].to_f < loan.min_invest
      redirect_to "/show_debts?id=#{params[:bid][:from_bid_id]}&errors=投资金额不能小于#{loan.min_invest}"
      return
    end

    if loan.min_invest.present? && (parent_bid.for_sale_amount < 2 * loan.min_invest) && (params[:bid][:invest_amount].to_f < parent_bid.for_sale_amount)
      redirect_to "/show_debts?id=#{params[:bid][:from_bid_id]}&errors=当前标的可投金额为#{parent_bid.for_sale_amount}元，请一次投满。"
      return
    end

    if params[:bid][:invest_amount].to_f > parent_bid.for_sale_amount
      params[:bid][:invest_amount] = parent_bid.for_sale_amount
    end

    begin
      Bid.bought_by current_user, parent_bid, params[:bid][:invest_amount].to_f
      redirect_to "/debts?notice=投标成功"
    rescue Exception => ex
      @bid = parent_bid.reload
      @loan = @bid.loan
      @child_bid = Bid.new(:user => current_user, :loan_id => @loan.id, :from_bid_id => @bid.id)

      # 投资100元，可得收益
      # @total = 0
      # @interest = Loan.calculator(@loan.repay_style, 100, @bid.for_sale_month, @loan.interest)
      # @interest.values.each{|v| @total += (v[:seed] + v[:interest])}
      # @earnings_tmp = @total - 100
      # flash[:errors] = ex.message
      redirect_to "/show_debts?id=#{params[:bid][:from_bid_id]}&notice=#{ex.message}"
    end
  end

  def verify_lender
    redirect_to root_url unless current_user.roles.is_lender.present?
  end

  def search
    sql = []
    sql << "repay_style = '#{params[:type]}'" if params[:type].present? && !params[:type].nil?
    sql << "credit_level = '#{params[:level]}'" if params[:level].present? && !params[:level].nil?
    if params[:time].present? && !params[:time].nil?
      case params[:time]
      when '1-3'
        sql << "months between 1 and 3"
      when '4-6'
        sql << "months between 4 and 6"
      when '7-12'
        sql << "months between 7 and 12"
      when '12+'
        sql << "months > 12"
      end
    end
    if params[:interest].present? && !params[:interest].nil?
      case params[:interest]
      when '5-10'
        sql << "interest between 5 and 10"
      when '10-15'
        sql << "interest between 10 and 15"
      when '15-20'
        sql << "interest between 15 and 20"
      when '20+'
        sql << "interest > 20"
      end
    end
    sql << "loan_state_id = '#{params[:state]}'" if params[:state].present? && !params[:state].nil?
    @loans = Loan.can_be_seen.where(sql.join(" and ")).order('id desc').paginate :page => params[:page], :per_page => 20
    render :layout => false
  end
end
