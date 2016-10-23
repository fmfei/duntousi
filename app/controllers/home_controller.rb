# encoding: utf-8
class HomeController < ApplicationController
  # include ApplicationHelper
  # 网站首页
  def index
    #A
    @area_a = Seat.a
    @area_a_total = {}
    @area_a.each do |a|
      if @area_a_total[a.row].blank?
        @area_a_total[a.row] = {}
        @area_a_total[a.row][:col] = []
        @area_a_total[a.row][:amount] = 0
        a.num =~ /^(.+)-/
        @area_a_total[a.row][:prefix] = $1
      end
      @area_a_total[a.row][:col] << a
      @area_a_total[a.row][:amount] += 1
    end
    @area_a_count = @area_a.count
    @area_a_reserve = @area_a.reserve.count
    @area_a_sold = @area_a.sold.count
    @area_a_idle = @area_a.idle.count
    #B1
    @area_b1 = Seat.b1
    @area_b1_total = {}
    @area_b1.each do |b|
      if @area_b1_total[b.row].blank?
        @area_b1_total[b.row] = {}
        @area_b1_total[b.row][:col] = []
        @area_b1_total[b.row][:amount] = 0
        b.num =~ /^(.+)-/
        @area_b1_total[b.row][:prefix] = $1
      end
      @area_b1_total[b.row][:col] << b
      @area_b1_total[b.row][:amount] += 1
    end
    @area_b1_count = @area_b1.count
    @area_b1_reserve = @area_b1.reserve.count
    @area_b1_sold = @area_b1.sold.count
    @area_b1_idle = @area_b1.idle.count
    #B2
    @area_b2 = Seat.b2
    @area_b2_total = {}
    @area_b2.each do |b|
      if @area_b2_total[b.row].blank?
        @area_b2_total[b.row] = {}
        @area_b2_total[b.row][:col] = []
        @area_b2_total[b.row][:amount] = 0
        b.num =~ /^(.+)-/
        @area_b2_total[b.row][:prefix] = $1
      end
      @area_b2_total[b.row][:col] << b
      @area_b2_total[b.row][:amount] += 1
    end
    @area_b2_count = @area_b2.count
    @area_b2_reserve = @area_b2.reserve.count
    @area_b2_sold = @area_b2.sold.count
    @area_b2_idle = @area_b2.idle.count
    #C
    @area_c = Seat.c
    @area_c_total = {}
    @area_c.each do |c|
      if @area_c_total[c.row].blank?
        @area_c_total[c.row] = {}
        @area_c_total[c.row][:col] = []
        @area_c_total[c.row][:amount] = 0
        c.num =~ /^(.+)-/
        @area_c_total[c.row][:prefix] = $1
      end
      @area_c_total[c.row][:col] << c
      @area_c_total[c.row][:amount] += 1
    end
    @area_c_count = @area_c.count
    @area_c_reserve = @area_c.reserve.count
    @area_c_sold = @area_c.sold.count
    @area_c_idle = @area_c.idle.count
    #D
    @area_d = Seat.d
    @area_d_total = {}
    @area_d.each do |d|
      if @area_d_total[d.row].blank?
        @area_d_total[d.row] = {}
        @area_d_total[d.row][:col] = []
        @area_d_total[d.row][:amount] = 0
        d.num =~ /^(.+)-/
        @area_d_total[d.row][:prefix] = $1
      end
      @area_d_total[d.row][:col] << d
      @area_d_total[d.row][:amount] += 1
    end
    @area_d_count = @area_d.count
    @area_d_reserve = @area_d.reserve.count
    @area_d_sold = @area_d.sold.count
    @area_d_idle = @area_d.idle.count
    #E
    @area_e = Seat.e
    @area_e_total = {}
    @area_e.each do |e|
      if @area_e_total[e.row].blank?
        @area_e_total[e.row] = {}
        @area_e_total[e.row][:col] = []
        @area_e_total[e.row][:amount] = 0
        e.num =~ /^(.+)-/
        @area_e_total[e.row][:prefix] = $1
      end
      @area_e_total[e.row][:col] << e
      @area_e_total[e.row][:amount] += 1
    end
    @area_e_count = @area_e.count
    @area_e_reserve = @area_e.reserve.count
    @area_e_sold = @area_e.sold.count
    @area_e_idle = @area_e.idle.count
  end

  def show
    render :show_new, :layout=> "account"
  end

  # 公司简介
  def company_info
  end
  # banner
  def banner_info
    banners = Banner.display.for_pc
    respond_to do |format|
      format.json do
        render json: banners.to_json
      end
    end
  end

  def info_json
    loans = Loan.bidding_or_after.order('available_amount desc, id desc').limit(6)
    loan_infos = {}
    loans.each_with_index do |loan, index|
      loan_infos.merge!((index.to_s).to_sym => {id: loan.id, amount: loan.amount, state: loan.state.name, title: loan.title[0, 16], name: loan.borrower.name[0, 8], progress: loan.progress, interest: loan.interest, month: loan.months})
    end

    articles = {}
    Article.select('id, title').notice.limit(5).each_with_index do |article, index|
      articles.merge!(index.to_s.to_sym => {id: article.id, title: article.title[0,14]})
    end

    fabiaos = {}
    Article.select('id, title').fabiao.limit(5).each_with_index do |article, index|
      fabiaos.merge!(index.to_s.to_sym => {id: article.id, title: article.title})
    end

    friendlinks = Friendlink.order("id desc").limit(7)

    #新增新手标
    rookie_item = RookieLoan.can_be_invest.first

    info = {
            invest_people: User.lender.count + 9503,
            invest_amount: rmb_wan(Loan.total_amount + 95366700),
            interest_amount: rmb_wan(Collection.sum(:interest) + 1999200),
            loans: loan_infos,
            notices: articles,
            fabiaos: fabiaos,
            friendlinks: friendlinks,
            rookie_item: rookie_item
          }
    respond_to do |format|
      format.json do
        render json: info.to_json
      end
    end
  end

  def basic_info_json
    info = {company_name: SystemConfig.company_name.value,
            phone400: SystemConfig.phone400.value,
            serve_time: SystemConfig.serve_time.value,
            qq_server: SystemConfig.qq_server.value,
            qq_group: SystemConfig.qq_group.value,
            prize_register: SystemConfig.prize_register_amount.value.to_s + '元',
            prize_first: SystemConfig.prize_first_amount.value.to_s + '元',
            promotion_ratio: SystemConfig.promotion_ratio.value.to_s + '%',
            username: current_user.try(:username).to_s
          }
    respond_to do |format|
      format.json do
        render json: info.to_json
      end
    end
  end

  def send_verify_code2
    if params[:captcha].blank? || !simple_captcha_valid?
      render :text => 'captcha error'
      return
    end
    if User.where(:mobile  => params[:mobile]).count == 0
      # 生成验证码
      verify_code = 1001 + rand(8980)

      # 发送验证码
      redis = Redis.new
      redis.set params[:mobile], verify_code
      redis.expire params[:mobile], 120

      res = Resque.enqueue(SmsJob, :send_verify_code, params[:mobile], verify_code)
      render :text => res
    else
      render :text => 'false'
    end
  end

  def confirm_email
    user = User.find_by_confirmation_token params[:confirmation_token]
    if user.present? && user.confirmed_at.blank?
      # user.update_attribute(:confirmed_at, Time.now)
      user.confirm!
    elsif user.present? && user.confirmed_at.present?
      flash[:errors] = '该邮箱已通过验证。'
    else
      flash[:errors] = '邮箱验证失败，请重新验证。'
    end
    if current_user.present?
      redirect_to auth_email_account_users_path
    else
      redirect_to new_user_session_path
    end
  end

  def source
    cookies[:source] = params[:source_id1] if params[:source_id1].present?
    cookies[:channel] = params[:source_id2] if params[:source_id2].present?
    render nothing: true
  end

  def users_source
    if params[:sourcexxx].present?
      @users = User.reorder('id desc').where(:source => params[:sourcexxx]).paginate :page => params[:page], :per_page => 1000
      render layout: false
    else
      raise ActionController::RoutingError.new('Not Found')
    end
  end

end
