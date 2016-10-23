# encoding: utf-8

class Backend::WebStatisticsController < Backend::BaseController
  before_filter :get_date, :only => [:investment_statistics, :bid_statistics, :borrow_statistics]

  def index
    @title = '网站统计列表'
    @web_statistics = WebStatistic.order("id desc").all
  end

  def new
    @web_statistic = WebStatistic.new
  end

  def edit
    @web_statistic = WebStatistic.find(params[:id])
  end

  def create
    @web_statistic = WebStatistic.new(web_statistics_params)
    if @web_statistic.save
      flash[:success] = '添加成功'
      redirect_to backend_web_statistics_path
    else
      flash[:errors] = @web_statistic.errors
      render :new
    end
  end

  def update
    @web_statistic = WebStatistic.find(params[:id])

    respond_to do |format|
      if @web_statistic.update_attributes(web_statistics_params)
        format.html { redirect_to backend_web_statistics_path, notice: '更新成功' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @web_statistic.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @web_statistic = WebStatistic.find(params[:id])
    @web_statistic.destroy

    respond_to do |format|
      format.html { redirect_to backend_web_statistics_path }
      format.json { head :no_content }
    end
  end

  # 投资统计
  def investment_statistics
=begin
    @data_arr = []
    @registers_data = []
    @investment_data = []
    @investment_amount_data = []
    if @endday - @today < 30
      until @today > @endday
        @data_arr << @today.strftime('%m-%d')
        @registers_data << User.where("created_at >= ? and created_at < ?", @today, (@today + 1.day)).count
        @investment_data << Bid.where("created_at >= ? and created_at < ?", @today, (@today + 1.day)).select(:user_id).uniq.count
        @investment_amount_data << Bid.where("created_at >= ? and created_at < ?", @today, (@today + 1.day)).sum(:invest_amount).round(2).to_f
        @today += 1.day
      end
    else
      until @today > @endday
        @data_arr << @today.strftime('%Y-%m')
        @registers_data << User.where("created_at >= ? and created_at < ?", @today.strftime('%Y-%m-01'), (@today + 1.month).strftime('%Y-%m-01')).count
        @investment_data << Bid.where("created_at >= ? and created_at < ?", @today.strftime('%Y-%m-01'), (@today + 1.month).strftime('%Y-%m-01')).select(:user_id).uniq.count # 投资人数
        @investment_amount_data << Bid.where("created_at >= ? and created_at < ?", @today.strftime('%Y-%m-01'), (@today + 1.month).strftime('%Y-%m-01')).sum(:invest_amount).round(2).to_f
        @today += 1.month
      end
    end
=end
    @start = params[:start_date].present? ? params[:start_date].to_date : Time.zone.today.strftime('%Y-%m-01').to_date
    @end = params[:end_date].present? ? params[:end_date].to_date : Time.zone.tomorrow
    @loans = Loan.where("created_at >= ? and created_at < ?", @start, @end)
    @bids = Bid.select('user_id').where("created_at >= ? and created_at < ?", @start, @end).reorder('user_id').distinct('user_id')

  end

  # 投标统计
  def bid_statistics
    @data_arr = []
    @bid_count = {}
    @bid_amount = {}
    if @endday - @today < 30
      until @today > @endday
        @data_arr << @today.strftime('%m-%d')
        Bid::STATISTIC_NEED.each do |k, v|
          @bid_count[k] = [] if @bid_count[k].nil?
          @bid_amount[k] = [] if @bid_amount[k].nil?
          @statistic = Bid.where("status = ? and created_at >= ? and created_at < ?", v, @today, (@today + 1.day))
          @bid_count[k] << @statistic.count
          @bid_amount[k] << @statistic.sum(:invest_amount).round(2).to_f
        end
        @today += 1.day
      end
    else
      until @today > @endday
        @data_arr << @today.strftime('%Y-%m')
        Bid::STATISTIC_NEED.each do |k, v|
          @bid_count[k] = [] if @bid_count[k].nil?
          @bid_amount[k] = [] if @bid_amount[k].nil?
          @statistic = Bid.where("status = ? and created_at >= ? and created_at < ?", v, @today.strftime('%Y-%m-01'), (@today + 1.month).strftime('%Y-%m-01'))
          @bid_count[k] << @statistic.count
          @bid_amount[k] << @statistic.sum(:invest_amount).round(2).to_f
        end
        @today += 1.month
      end
    end

    @h = LazyHighCharts::HighChart.new('greph') do |f|
      f.options[:chart][:defaultSeriesType] = "line"
      f.title(:text => '投资统计-个数')
      f.subtitle(:text => @data_arr.first + ' 至 ' + @data_arr.last)
      f.yAxis(:labels => {:format => '{value}个'}, :title => {:text => '个数'})
      @bid_count.each do |k, v|
        f.series(:name => k, :data => v, :tooltip => {:valueSuffix => '个'})
      end
      f.xAxis(categories: @data_arr)
    end

    @a = LazyHighCharts::HighChart.new('greph') do |f|
      f.options[:chart][:defaultSeriesType] = "column"
      f.title(:text => '投资统计-金额')
      f.subtitle(:text => @data_arr.first + ' 至 ' + @data_arr.last)
      f.yAxis(:labels => {:format => '{value}元'}, :title => {:text => '金额'})
      @bid_amount.each do |k, v|
        f.series(:name => k, :data => v, :tooltip => {:valueSuffix => '元'})
      end
      f.xAxis(categories: @data_arr)
    end

  end

  # 借款统计
  def borrow_statistics
    @data_arr = []
    @loan_count = {}
    @loan_amount = {}
    if @endday - @today < 30
      until @today > @endday
        @data_arr << @today.strftime('%m-%d')
        Dict::LoanState.statistic_need.each do |s|
          @loan_count[s.name] = [] if @loan_count[s.name].nil?
          @loan_amount[s.name] = [] if @loan_amount[s.name].nil?
          @statistic = Loan.where("loan_state_id = ? and created_at >= ? and created_at < ?", s.id, @today, (@today + 1.day))
          @loan_count[s.name] << @statistic.count
          @loan_amount[s.name] << @statistic.sum(:amount).round(2).to_f
        end
        @today += 1.day
      end
    else
      until @today > @endday
        @data_arr << @today.strftime('%Y-%m')
        Dict::LoanState.statistic_need.each do |s|
          @loan_count[s.name] = [] if @loan_count[s.name].nil?
          @loan_amount[s.name] = [] if @loan_amount[s.name].nil?
          @statistic = Loan.where("loan_state_id = ? and created_at >= ? and created_at < ?", s.id, @today.strftime('%Y-%m-01'), (@today + 1.month).strftime('%Y-%m-01'))
          @loan_count[s.name] << @statistic.count
          @loan_amount[s.name] << @statistic.sum(:amount).round(2).to_f
        end
        @today += 1.month
      end
    end

    @h = LazyHighCharts::HighChart.new('greph') do |f|
      f.options[:chart][:defaultSeriesType] = "line"
      f.title(:text => '借款统计-个数')
      f.subtitle(:text => @data_arr.first + ' 至 ' + @data_arr.last)
      f.yAxis(:labels => {:format => '{value}个'}, :title => {:text => '个数'})
      @loan_count.each do |k, v|
        f.series(:name => k, :data => v, :tooltip => {:valueSuffix => '个'})
      end
      f.xAxis(categories: @data_arr)
    end

    @a = LazyHighCharts::HighChart.new('greph') do |f|
      f.options[:chart][:defaultSeriesType] = "column"
      f.title(:text => '借款统计-金额')
      f.subtitle(:text => @data_arr.first + ' 至 ' + @data_arr.last)
      f.yAxis(:labels => {:format => '{value}元'}, :title => {:text => '金额'})
      @loan_amount.each do |k, v|
        f.series(:name => k, :data => v, :tooltip => {:valueSuffix => '元'})
      end
      f.xAxis(categories: @data_arr)
    end
  end

  # 平台账户统计
  def fund

  end

  #用户余额统计
  def remainder
    @users = User.joins(:user_cash).where("user_cashes.available >= 1").where("users.id > 0").paginate :page => params[:page], :per_page => 20
    @total = UserCash.where("available >= 1 and user_id > 0").sum(:available)
  end

  private
  def get_date
    @today = params[:start_date].present? ? params[:start_date].to_date : Time.zone.today.strftime('%Y-%m-01').to_date
    @endday = params[:end_date].present? ? params[:end_date].to_date : Time.zone.today
  end
  def web_statistics_params
    params.require(:web_statistic).permit(:title,:code)
  end
end
