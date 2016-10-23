# encoding: utf-8
class InvestsController < ApplicationController
  before_filter :authenticate_user!, :verify_lender, :only => [:new, :create]
  include ApplicationHelper
  # 我要理财
  def info_json
    @loans = Loan.bidding_or_after.where("interest <= 15").order('id desc').paginate :page => params[:page], :per_page => 10
    @title = '我要理财'

    loan_infos = {}
    @loans.each_with_index do |loan, index|
      loan_infos.merge!((index.to_s).to_sym => {id: loan.id, amount: loan.amount, state: loan.state.name, title: loan.title, name: loan.borrower.name, progress: loan.progress, interest: loan.interest, months: loan.months, available_amount: loan.available_amount})
    end

    info = {
            invest_people: User.lender.count + 9503,
            invest_amount: rmb_wan(Loan.total_amount + 95366700),
            total_deal_num: (Loan.count + 710),
            interest_amount: rmb_wan(Collection.sum(:interest) + 1999200),
            total_pages: @loans.total_pages,
            current_page: @loans.current_page,
            loans: loan_infos
    }
    respond_to do |format|
      format.json do
        render json: info.to_json
      end
    end
  end

  def index
    redirect_to '/loans'
    return
    @loans = Loan.bidding_or_after.order('id desc').paginate :page => params[:page], :per_page => 10
    @title = '我要理财'

  end


  # 投标详情
  def show
    redirect_to "/show_invest?id=#{params[:id]}"
    return
    # @loan = Loan.can_be_seen.find(params[:id])
    # @bid = Bid.new(:user => current_user, :loan_id => @loan.id)
    # @total = 0
    # @interest = Loan.calculator(@loan.repay_style, 100, @loan.months, @loan.interest)
    # @interest.values.each{|v| @total += (v[:seed] + v[:interest])}
    # @earnings_tmp = @total - 100
    # @title = '我要理财'
  end

  def show_invest
    @loan = Loan.can_be_seen.find(params[:id])
    @bid = Bid.new(:user => current_user, :loan_id => @loan.id)
    @total = 0
    @interest = Loan.calculator(@loan.repay_style, 100, @loan.months, @loan.interest)
    @interest.values.each{|v| @total += (v[:seed] + v[:interest])}
    @earnings_tmp = @total - 100
    @title = '我要理财'
    if @loan.loan_state_id == Dict::LoanState.bidding.id && @loan.due_date.present? && @loan.due_date > DateTime.now
      due_at = @loan.due_date.strftime("%Y,%m,%d")
    else
      due_at = 0
    end
    repaystyle = {"equal"=>"按月分期还款", "interest_only"=>"按月还息，到期还本", "at_due"=>"到期归还本息"}
    identifications = []
    @loan.borrower.identifications.each do |i|
      if i.file.url.present?
        identifications << {category: t(i.category), desc: i.desc, url: i.file.url}
      end
    end
    user_info = { gender: @loan.borrower.info.gender,
                  marry: @loan.borrower.info.marriage.try(:name).to_s,
                  wenhua: @loan.borrower.info.education.try(:name).to_s,
                  income: @loan.borrower.info.income,
                  shebao: (@loan.borrower.info.social_security_id.present? ? '有' : '无'),
                  house: @loan.borrower.info.housing,
                  car: @loan.borrower.info.car
                }
    bids = []
    @loan.bids.each do |bid|
      bids << {name: (bid.user.mobile.try(:[],0..2).to_s+'****'+bid.user.mobile.try(:[],-4..-1).to_s), invest_amount: bid.invest_amount.to_f.round(2), interest: bid.interest, created_at: format_time(bid.created_at), category: (bid.category)}
    end
    info = {
        cash_account: current_user.present? ? rmb(current_user.user_cash.available.to_f) : 0 ,
        must_be_login: must_be_login,
        current_user: current_user.present? ? 1:0,
        loan_state_id:Dict::LoanState.bidding.id,
        due_at: due_at,
        total_deal_num:123,
        collection_amount: @bid.collection_amount,
        earnings_tmp: @earnings_tmp,
        interest: @interest,
        loan: @loan,
        bid: @bid,
        repayment_methods: repaystyle[@loan.repay_style].to_s,
        state_name: @loan.state.name,
        desc: @loan.desc,
        identifications: identifications,
        user_info: user_info,
        bids: bids,
        prize_first_amount: SystemConfig.prize_first_amount.value,
        prize_last_amount: SystemConfig.prize_last_amount.value,
        prize_max_amount: SystemConfig.prize_max_amount.value
    }
    respond_to do |format|
      format.json do
        render json: info.to_json
      end
    end
  end

  #新手标
  def show_rookie_invest
    @loan = RookieLoan.can_be_seen.find(params[:id])
    @bid = RookieBid.new(:user => current_user, :rookie_loan_id => @loan.id)
    @title = '我要理财'
    if @loan.loan_state_id == Dict::LoanState.bidding.id && @loan.due_date.present? && @loan.due_date > DateTime.now
      due_at = @loan.due_date.strftime("%Y,%m,%d")
    else
      due_at = 0
    end
    bids = []
    @loan.rookie_bids.each do |bid|
      bids << {name: (bid.user.mobile.try(:[],0..2).to_s+'****'+bid.user.mobile.try(:[],-4..-1).to_s), invest_amount: bid.invest_amount.to_f.round(2), interest: bid.interest, created_at: format_time(bid.created_at), category: "手动投标"}
    end
    info = {
        cash_account: current_user.present? ? rmb(current_user.user_cash.rookie_amount.to_f) : 0 ,
        current_user: current_user.present? ? 1:0,
        loan_state_id:Dict::LoanState.bidding.id,
        due_at: due_at,
        total_deal_num:123,
        interest: @interest,
        loan: @loan,
        bid: @bid,
        state_name: @loan.state.name,
        desc: @loan.desc,
        bids: bids,
        prize_first_amount: SystemConfig.prize_first_amount.value,
        prize_last_amount: SystemConfig.prize_last_amount.value,
        prize_max_amount: SystemConfig.prize_max_amount.value
    }
    respond_to do |format|
      format.json do
        render json: info.to_json
      end
    end
  end

  # 投资
  def new
    @title = '我要理财'
    if current_user && current_user.auth_realname == 1
      @bid = Bid.new(:user => current_user,
                     :loan_id => params[:loan_id])
      @loan = Loan.can_be_seen.find(params[:loan_id])
    end
    render layout: false
  end

  #关于新手标的
  def rookie_new
    @title = '我要理财'
    if current_user && current_user.auth_realname == 1
      @bid = RookieBid.new(:user => current_user,
                     :rookie_loan_id => params[:loan_id])
      @loan = RookieLoan.can_be_seen.find(params[:loan_id])
    end
    render layout: false
  end

  # 投标
  def create
    if params[:bid][:invest_amount].to_f > current_user.user_cash.available.to_f.round(2)
      redirect_to "/show_invest?id=#{params[:bid][:loan_id]}&errors=账户余额不足"
      return
    end

    loan = Loan.can_be_seen.find(params[:bid][:loan_id])

    if loan.pass.present? && loan.pass != params[:bid][:pass]
      redirect_to "/show_invest?id=#{params[:bid][:loan_id]}&errors=约标密码错误"
      return
    end

    if loan.min_invest.present? && params[:bid][:invest_amount].to_f < loan.min_invest
      redirect_to "/show_invest?id=#{params[:bid][:loan_id]}&errors=投资金额不能小于#{loan.min_invest}"
      return
    end

    if loan.min_invest.present? && (loan.available_amount < 2 * loan.min_invest) && (params[:bid][:invest_amount].to_f < loan.available_amount)
      redirect_to "/show_invest?id=#{params[:bid][:loan_id]}&errors=当前标的可投金额为#{loan.available_amount}元，请一次投满。"
      return
    end

    ###### 现金券

    if params[:coupon].present? && params[:bid][:invest_amount].to_f >= 10000.00
      params[:bid][:invest_amount] = params[:bid][:invest_amount].to_f + params[:coupon].to_f
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

    #判断是否需要使用红包（两周内庆）
    if Time.now.to_date >= DateTime.new(2016, 8, 6)
      if params[:bribery_money].present? && (params[:bid][:invest_amount].to_f + params[:bribery_money].to_f) > loan.available_amount
        params[:bribery_money] = nil
      end
    end

    begin

      if params[:coupon].present? && params[:bid][:invest_amount].to_f >= 10000.00

        coupon = current_user.coupons.unused.where(amount: params[:coupon].to_f).first

        ###### 现金券
        if coupon.present?
          CashFlow.prize(current_user, params[:coupon].to_f)
          coupon.update_attribute(:status, 'used')
        end

      end

      #两周内庆红包
      if Time.now.to_date >= DateTime.new(2016, 8, 6)
        if params[:bribery_money].present?
          if params[:bribery_money] == "10"
            pri = '1'
          elsif params[:bribery_money] == "50"
            pri = '2'
          elsif params[:bribery_money] == '200'
            pri = '3'
          end
          record = current_user.two_yr_circle_records.actived.unused.where(prize: pri).first
          if record.present?
            CashFlow.prize(current_user, params[:bribery_money].to_f)
            params[:bid][:invest_amount] = (params[:bid][:invest_amount].to_f + params[:bribery_money].to_f).to_s
            record.update_attribute(:is_used, true)
          end
        end
      end

      Bid.create_by_user current_user, params[:bid][:loan_id], params[:bid][:invest_amount]
      #新年砸蛋活动
      # Resque.enqueue(PromotionJob, 'newyear_egg', {:user_id => current_user.id, :invest_amount => params[:bid][:invest_amount]})
      # if current_user.gender == '男'
      #   cc = (params[:bid][:invest_amount].to_f * 0.0038).round(2)
      # else
      #   cc = (params[:bid][:invest_amount].to_f * 0.005).round(2)
      # end

      # CashFlow.prize(current_user, cc)
      #两周年庆转盘抽奖活动
      if (Time.now.to_date >= DateTime.new(2016, 8, 15)) && (Time.now.to_date <= DateTime.new(2016, 8, 20))
        invest_amount_count = (current_user.bids.today.sum(:invest_amount).to_i)/10000
        already_records = current_user.two_yr_circle_records.today_create.count
        if invest_amount_count >= 3
          (invest_amount_count - already_records).times do 
            TwoYrCircleRecord.create_for(current_user)
          end
        end
      end

      redirect_to "/show_invest?id=#{params[:bid][:loan_id]}&notice=投标成功"
    rescue Exception => ex

      @loan = Loan.can_be_seen.find(params[:bid][:loan_id])
      @bid = Bid.new(:user => current_user,
                     :loan_id => params[:bid][:loan_id])
      redirect_to "/show_invest?id=#{params[:bid][:loan_id]}&errors=#{ex.message}"
    end
  end

  #创建新手标记录
  def create_rookie_bid
    params[:rookie_bid][:invest_amount] = 2000
    if params[:rookie_bid][:invest_amount].to_f > current_user.user_cash.rookie_amount.to_f.round(2)
      redirect_to "/show_rookie_invest?id=#{params[:rookie_bid][:loan_id]}&errors=新手体验金余额不足"
      return
    end

    loan = RookieLoan.can_be_seen.find(params[:rookie_bid][:loan_id])

    #新手标是否已满
    if loan.available_amount <= 0
      redirect_to "/show_rookie_invest?id=#{params[:rookie_bid][:loan_id]}&errors=该新手标已投满，请关注下期"
      return
    end

    begin

      RookieBid.create_by_user current_user, params[:rookie_bid][:loan_id], params[:rookie_bid][:invest_amount]

      redirect_to "/show_rookie_invest?id=#{params[:rookie_bid][:loan_id]}&notice=投标成功"
    rescue Exception => ex

      @loan = RookieLoan.can_be_seen.find(params[:rookie_bid][:loan_id])
      @bid = RookieBid.new(:user => current_user,
                     :rookie_loan_id => params[:rookie_bid][:loan_id])
      redirect_to "/show_rookie_invest?id=#{params[:rookie_bid][:loan_id]}&errors=#{ex.message}"
    end
  end

  # 投资计算器
  def calculator
    if !request.xhr?
      redirect_to '/cal'
      return
    end
    if params[:type].present? && params[:interest].present? && params[:months].present? && params[:amount].present?
      @apr_month = params[:interest].to_f/12
      @total = 0
      @interest = Loan.calculator(params[:type], params[:amount], params[:months], params[:interest])
      @interest.values.each{|v| @total += (v[:seed] + v[:interest])}
    else
      flash[:errors] = '请填写完整数据'
    end
    render :layout => false
  end

  def verify_lender
    redirect_to root_url unless current_user.roles.is_lender.present?
  end

  def search_json
    current_page = params[:page].present? ? params[:page] : 1
    interest = params['interest'].present? && params['interest'] != 'all' ?
        { interest: params['interest'] } : nil
    months = nil
    if params['months'].present? && params['months'].to_i >0
      get_months = params['months'].to_i
      months = get_months < 6 ?  ['months = ?' ,get_months] : ["months >= ?",get_months]
    end
    with_change = nil
    if params['biao_type'].present? && params['biao_type'] != 'all'
      if params['biao_type'] == 'mortgage'
        with_change = {with_mortgage: true}
      elsif params['biao_type'] == 'guarantee'
        with_change = {with_guarantee: true}
      end
    end

    if params['loan_state_id'].present? && params['loan_state_id'] != 'all'
      loans = Loan.where("interest <= 15").where({loan_state_id: params['loan_state_id'].to_i })
    else
      loans = Loan.where("interest <= 15").bidding_or_after
    end
    @loans = loans.where(interest).where(months).where(with_change).order('id desc').paginate :page => current_page, :per_page => 10

    loan_infos = {}
    @loans.each_with_index do |loan, index|
      loan_infos.merge!((index.to_s).to_sym => {id: loan.id, amount: loan.amount, state: loan.state.name, title: loan.title, name: loan.borrower.name, progress: loan.progress, interest: loan.interest, months: loan.months, available_amount: loan.available_amount})
    end

    @title = '我要理财'
    info = {total_pages: @loans.total_pages,
            current_page: current_page,
            loans: loan_infos}
    respond_to do |format|
      format.json do
        render json: info.to_json
      end
    end

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
