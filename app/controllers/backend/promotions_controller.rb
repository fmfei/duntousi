#encoding:utf-8
require 'csv'
class Backend::PromotionsController < Backend::BaseController

  def circle
  	@q = CircleRecord.joins(:user => :info).actived.ransack(params[:q])
    @records = @q.result.order('user_id asc, actived_at desc').paginate(:page => params[:page], :per_page => 100)
  end

  def egg
    @q = EggRecord.joins(:user => :info).ransack(params[:q])
    @records = @q.result.order('user_id asc, actived_at desc').paginate(:page => params[:page], :per_page => 100)
  end

  def circle_excel
		Spreadsheet.client_encoding = 'UTF-8'
		book = Spreadsheet::Workbook.new
		sheet1 = book.create_worksheet
		sheet1.row(0).push("中奖者", "手机号	", "中奖时间", "奖品")
		if params[:invest_total].present?
      @records = CircleRecord.joins(user:[:user_cash]).actived.where('user_cashes.invest_total > 0').order('user_id asc, actived_at desc')
    else
      @records = CircleRecord.actived.order('user_id asc, actived_at desc')
    end

		@records.each_with_index do |r, i|
			sheet1.row(i + 1).push(
				r.user.name,
				r.user.mobile,
				r.actived_at.strftime("%Y-%m-%d %H:%M:%S"),
				r.prize_text
				)
		end

		str_io = StringIO.new
    book.write(str_io)
    send_data(str_io.string, :filename => "中奖名单#{Time.now.strftime('%x')}.xls" )

  end

  def lucky_code
    #@records = LuckyCode.not_null.paginate(:page => params[:page], :per_page => 10)

    @q = LuckyCode.not_null.order('id desc').ransack(params[:q])
    if params[:download].present?
      export_lucky_users @q.result
      return
    else
      @records = @q.result.paginate(:page => params[:page], :per_page => 20)
    end
  end

  def translate_status status
    if status == "win"
      return "中奖"
    elsif status == "not_win"
      return "未中奖"
    else
      return "未开奖"
    end
  end

  def export_lucky_users withdraws
    if withdraws.present?
      Spreadsheet.client_encoding = 'UTF-8'
      book = Spreadsheet::Workbook.new
      sheet1 = book.create_worksheet
      sheet1.row(0).push("姓名", "手机号", "抽奖日期", "数字1", "数字2", "数字3", "数字4", "数字5", "数字6", "抽奖号码", "开奖号码", "猜中个数", "中奖状态")
      withdraws.each_with_index do |withdraw, i|
        sheet1.row(i + 1).push(
          withdraw.user.name,
          withdraw.user.mobile,
          withdraw.created_at.strftime("%Y-%m-%d %H:%M:%S"),
          withdraw.one,
          withdraw.two,
          withdraw.three,
          withdraw.four,
          withdraw.five,
          withdraw.six,
          withdraw.one.to_s+withdraw.two.to_s+withdraw.three.to_s+withdraw.four.to_s+withdraw.five.to_s+withdraw.six.to_s,
          withdraw.win_number,
          withdraw.hit_number,
          translate_status(withdraw.status)
        )
      end
      str_io = StringIO.new
      book.write(str_io)
      send_data(str_io.string, :filename => "luckycode#{Time.now.strftime('%x')}.xls" )
    end
  end

  def create_lucky_code
    @lucky_codes = LuckyCode.today.not_null
    @lucky_codes.each do |code|
      code.win_or_not params[:lucky_code]
    end
    flash[:success] = "已将奖金发送给中奖人"
    redirect_to :action => "lucky_code"
  end

  # 安慰奖
  def consolation_prize
    @lucky_codes = LuckyCode.today.not_win
    win_records = LuckyCode.today.win.collect{|code| code.user_id}
    @lucky_codes.each do |code|
      if win_records.include?(code.user_id)
        next
      else
        win_records << code.user_id
      end
      code.consolation
    end
    flash[:success] = "已发放安慰奖"
    redirect_to :action => "lucky_code"
  end

  #幸运猜猜猜后台页面
  def lucky_guess
    @records = LuckyGuess.order("id desc").all.paginate(:page => params[:page], :per_page => 10)
  end

  #幸运猜猜猜
  def create_lucky_guess
    lastbid_createtime = Bid.today.where(['invest_month = ?', 1]).last
    if lastbid_createtime.blank?
      flash[:success] = '今日没有一月标'
      redirect_to :action => "lucky_guess"
      return
    end
    lastbid_createtime.created_at.strftime("%H:%M:%S") =~ /\d+:\d+:(\d+)/
    last_second = $1
    if last_second.to_i % 2 == 0
      @status = 'double'
      @guess = "双数"
    else
      @status = 'single'
      @guess = "单数"
    end
    LuckyGuess.null.before_today.each do |guess|
      guess.win_or_not @status
    end
    flash[:success] = "发奖成功，中奖尾数为" + @guess
    redirect_to :action => "lucky_guess"
  end

  #后台互动红包页面
  #该活动只执行一次
  def huodong_comment
    @records = HuodongComment.all.paginate(:page => params[:page], :per_page => 10)
  end

  def newyear_egg
    @records = NewyearEgg.order("id desc").all.paginate(:page => params[:page], :per_page => 15)
  end

  #两周内庆转盘抽奖活动
  def two_yr_anniversary
    @q = TwoYrCircleRecord.joins(:user => :info).actived.ransack(params[:q])
    @records = @q.result.order('user_id asc, actived_at desc').paginate(:page => params[:page], :per_page => 30)
    # @records = TwoYrCircleRecord.actived.paginate(:page => params[:page], :per_page => 30)
  end

  def two_yr_anniversary_no_use
    @q = TwoYrCircleRecord.joins(:user => :info).not_actived.ransack(params[:q])
    @records = @q.result.order('user_id asc, actived_at desc').paginate(:page => params[:page], :per_page => 30)
  end

  def activies
    @q = Bonu.joins(:user => :info).ransack(params[:q])
    @records = @q.result.order('actived_at desc').paginate(:page => params[:page], :per_page => 30)
  end

  def bonu
    @bonu = Bonu.new
  end

  def create_bonu
    if params[:mobile].present?
      user = User.find_by_mobile(params[:mobile])
      if user.present?
        @bonu = Bonu.create(user_id: user.id, actived_at: Time.now, category: params[:category], detail: params[:detail], price: params[:price])
        if @bonu
          @bonu.update_attributes(due_at: @bonu.actived_at + params[:dur_time].to_i.days) if params[:dur_time].present?
          flash[:success] = "创建奖励成功！"
          redirect_to :action => "activies"
        else
          flash[:errors] = @bonu.errors
          redirect_to :back
        end
      else
        flash[:errors] = "未找到相应用户，请确认是否正确"
        redirect_to :back
      end
    else
      flash[:errors] = "您没有输入电话，请重新输入"
      redirect_to :back
    end
  end

  def add_delivery_num
    @bonu = Bonu.find(params[:bonu_id])
  end

  def create_delivery_num
    bonu = Bonu.find(params[:bonu_id])
    if bonu.present? && bonu.category == 'actual_object'
      bonu.delivery_num = params[:delivery_num]
      bonu.is_finished = true
      if bonu.save
        flash[:success] = "添加单号成功"
        redirect_to :action => "activies"
      else
        flash[:errors] = "更新失败"
        redirect_to :back
      end
    else
      flash[:errors] = "活动奖励不存在，请确认是否正确"
      redirect_to :back
    end
  end

end
