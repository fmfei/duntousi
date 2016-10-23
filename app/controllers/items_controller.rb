class ItemsController < ApplicationController
  before_action :set_item, only: [:show, :edit, :update, :destroy]
  layout 'yiyuangou'
  # GET /items
  # GET /items.json
  def index
    @item = Item.last
    if @item.remain != 0
      @item_status = 0
      #主图
      @main_pic = @item.product.attachements.main_pic.first
      #其他图片
      @normal_pic = @item.product.attachements.normal_pic
      #该期所有购买记录
      @recorde_all = @item.product_orders.order("id desc").paginate(:page => params[:page], :per_page => 20)
      #用户的夺宝号码
      @numbers = ""
      if current_user.present?
        current_user.product_orders.where(item_id: @item.id).each do |order|
          @numbers << order.numbers
        end
      end
      #前一期商品信息
      @pre_item = Item.where("id < ?", @item.id).last
      if @pre_item.present?
        @product_order_win = @pre_item.product_orders.hit_order.last
        if @product_order_win.present?
          #中奖者头像
          @avatar = @product_order_win.user.info.avatar.url
        end
        @pre_hit_status = 1
      else
        #第一期商品时右侧显示期待第一个中奖人
        @pre_hit_status = 0
      end
    else
      @item_status = 1
    end
  end

  # GET /items/1
  # GET /items/1.json
  #展示已投资过的产品
  def show
    @item = Item.find(params[:id])
    #当前一期
    @current_item = Item.last
    #主图
    @main_pic = @item.product.attachements.main_pic.first
    #其他图片
    @normal_pic = @item.product.attachements.normal_pic
    #50条记录
    @order_last = @item.product_orders.last #本期最后一条投入记录
    @product_order = ProductOrder.where(["date(created_at) <= ?", @order_last.created_at]).last(50).reverse
    #该期所有购买记录
    @recorde_all = @item.product_orders.order("id desc").paginate(:page => params[:page], :per_page => 20)
    #该期中奖记录
    @product_order_win = @item.product_orders.hit_order.first
    #该期中奖人的投入的人次及相应号码
    @numbers_count = 0
    @numbers = ""
    @product_order_win.user.product_orders.where(item_id: @item.id).each do |order|
      @numbers_count += order.amount
      @numbers += order.numbers
    end
  end

  # GET /items/new
  def new
    @item = Item.new
  end

  # GET /items/1/edit
  def edit
  end

  # POST /items
  # POST /items.json
  def create
    if current_user.present?
      Item.transaction do
        item = Item.find(params[:item_id].to_i)
        if item.remain <= 0
          #如果已被抢完，提示投资下一期
          flash[:info] = "该期已投完，请投资下一期"
        elsif item.remain > params[:amount].to_i
          #如果还没被抢完，可以抢，创建一条抢投记录，更新期数的已投和剩余的人次数
          if current_user.available.blank?
            flash[:info] = "请先注册并充值"
          elsif current_user.cash_flows.count == 1 && current_user.cash_flows.first.cash_flow_description == Dict::CashFlowDescription.prize
            flash[:info] = "注册红包仅可用于投标"
          elsif current_user.available >= params[:amount].to_i
            numbers = item.number_array.sample(params[:amount].to_i)
            order = ProductOrder.create_for(current_user, params[:item_id].to_i, params[:amount].to_i, numbers.join(" "))
            already = item.already + params[:amount].to_i
            remain = item.remain - params[:amount].to_i
            number_array = item.number_array - numbers
            item.update_already_remain(already, remain, number_array)
            flash[:info] = "参与成功!"
          else
            flash[:info] = "您的账户余额不足，请充值"
          end
        elsif item.remain <= params[:amount].to_i
          if current_user.available.blank?
            flash[:info] = "请先注册并充值"
          elsif current_user.available > params[:amount].to_i
            #如果已最后剩余的被抢完，除了更新记录外，还要创建新的一期，及开奖
            numbers = item.number_array
            order = ProductOrder.create_for(current_user, params[:item_id].to_i, item.remain, numbers.join(" "))
            already = item.already + item.remain
            remain = item.remain - item.remain
            number_array = item.number_array - numbers
            item.update_already_remain(already, remain, number_array)
            #更新产品信息
            item_product = item.product
            item_product.already += 1
            item_product.remain -= 1
            item_product.save
            #生成新的期数
            not_finish_product = Product.where("already != numbers").order("weight desc").first
            if not_finish_product.present?
              Item.create(product_id: not_finish_product.id, already: 0, remain: not_finish_product.total_price, number_array: (10000001..(10000000+not_finish_product.total_price)).to_a)
            end
            flash[:info] = "参与成功!"
          else
            flash[:info] = "您的账户余额不足，请充值"
          end
        end
      end
    else
      flash[:info] = "请先登录"
    end
    redirect_to :actions => "index"
  end

  # PATCH/PUT /items/1
  # PATCH/PUT /items/1.json
  def update
    respond_to do |format|
      if @item.update(item_params)
        format.html { redirect_to @item, notice: 'Item was successfully updated.' }
        format.json { render :show, status: :ok, location: @item }
      else
        format.html { render :edit }
        format.json { render json: @item.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /items/1
  # DELETE /items/1.json
  def destroy
    @item.destroy
    respond_to do |format|
      format.html { redirect_to items_url, notice: 'Item was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def show_waiting
    @item = Item.find(params[:id])
    if @item.hit_number.present?
      redirect_to item_path(@item)
      return
    end
    @item_status = 0
      #主图
      @main_pic = @item.product.attachements.main_pic.first
      #其他图片
      @normal_pic = @item.product.attachements.normal_pic
      #50条记录
      order_last = @item.product_orders.last #本期最后一条投入记录
      @product_order = ProductOrder.where(["date(created_at) <= ?", order_last.created_at]).last(50).reverse
      #该期所有购买记录
      @recorde_all = @item.product_orders.order("id desc").paginate(:page => params[:page], :per_page => 20)
      #用户的夺宝号码
      @numbers = ""
      if current_user.present?
        current_user.product_orders.where(item_id: @item.id).each do |order|
          @numbers << order.numbers
        end
      end
      #前一期商品信息
      @pre_item = Item.where("id < ?", @item.id).last
      if @pre_item.present?
        @product_order_win = @pre_item.product_orders.hit_order.last
        if @product_order_win.present?
          #中奖者头像
          @avatar = @product_order_win.user.info.avatar.url
        end
        @pre_hit_status = 1
      else
        #第一期商品时右侧显示期待第一个中奖人
        @pre_hit_status = 0
      end
  end

  #历史记录
  def item_history
    if params[:status] == "pre"
      item = Item.where("id < ?", params[:item_id].to_i).last
    elsif params[:status] == "after"
      item = Item.where("id > ?", params[:item_id].to_i).first
    end
    if item.present?
      if item.hit_number.present?
        product_order_win = item.product_orders.hit_order.first
        @item_history = {item_id: item.id, hit_number: item.hit_number, hit_amount: product_order_win.amount, hit_time: item.hit_time, invest_time: product_order_win.created_at, avatar: product_order_win.user.info.avatar.url, user_mobile: product_order_win.user.mobile, flage: 1}
        render json: @item_history
      else
        # product_order_win = item.product_orders.hit_order.first
        # @item_history = {item_id: item.id, hit_number: item.hit_number, hit_amount: product_order_win.amount, hit_time: item.hit_time, invest_time: product_order_win.created_at, avatar: product_order_win.user.info.avatar.url, user_mobile: product_order_win.user.mobile}

        render json: {item_id: item.id, flage: 0}
      end
    else
      render json: {flage: -1}
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_item
      @item = Item.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def item_params
      params.require(:item).permit(:product_id, :already, :remain, :hit_time, :hit_number, :number_total, :number_rand, {:number_array => []})
    end
end
