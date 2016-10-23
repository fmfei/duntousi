# encoding: utf-8
class Backend::ProductsController < Backend::BaseController
  include_kindeditor :only => [:new, :edit, :create_product, :edit_product]
  def index
    @title = "一元夺宝管理"
    @products = Product.all.order('id desc').paginate(:page => params[:page], :per_page => 20)
  end

  def new
    @title = "新建产品"
    @product = Product.new
  end

  def create
    #创建产品
    @product = Product.new(products_params)
    @product.already = 0
    @product.remain = params[:product][:numbers].to_i
    if params[:product][:weight].empty?
      @product.weight = 1
    end
    if @product.save
      if Product.count == 1 || Product.where("already != numbers").count == 1
        Item.create_for(@product.id, @product.total_price)
      end
      redirect_to :action => 'index'  
    else
      flash[:errors] = @product.errors
      redirect_to :action => "new"
    end
  end

  def edit
    @title = "产品编辑"
    @product = Product.find(params[:id])
  end

  def update
    @product = Product.find(params[:id])

    respond_to do |format|
      if @product.update_attributes(products_params)
        format.html { redirect_to backend_products_path, notice: '更新成功' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end    
  end

  def destroy
    @product = Product.find(params[:id])
    @product.destroy

    respond_to do |format|
      flash[:success] = '删除成功'
      format.html { redirect_to(backend_products_path) }
      format.xml  { head :ok }
    end
  end

  def items_list
    @q = Item.order('id desc').ransack(params[:q])
    if params[:item_created].present? || params[:draw_lottery].present?
      return
    else
      @items = @q.result.paginate(:page => params[:page], :per_page => 20)
    end
  end

  def product_orders
    @item = Item.find(params[:id])
    @product_orders = @item.product_orders.order("id desc").paginate(:page => params[:page], :per_page => 15)
  end

  def draw_lottery
    #开奖
    item = Item.find(params[:item_id])
    if params[:cqssc].to_s.strip !~ /^\d{5}$/
      flash[:info] = "您输入的彩票号码不正确，请重新输入"
      redirect_to :action => "items_list"
      #render :text => "您输入的彩票号码不正确，请重新输入"

    elsif item.remain != 0
      flash[:info] = "该产品还没卖完，暂时不能开奖"
      redirect_to :action => "items_list"
      #render :text => "该产品还没卖完，暂时不能开奖"
    else
      #计算获奖号
      # item = Item.find(params[:item_id])
      order = item.product_orders.last
      hit_productorder = ProductOrder.where(["date(created_at) <= ?", order.created_at]).last(50)
      total_count = 0 #小于当前时间的50条记录（小时+分钟+秒+微秒组成的数）的总和
      hit_productorder.each do |order|
        total_count = total_count + (order.created_at.strftime("%H%M%S") + order.created_at.usec.to_s).to_i
      end
      hit_number = ((total_count + params[:cqssc].to_i) % item.already) + 10000001  #中奖号码 
      hit_mobile = ""
      #判断中奖记录, 更新中奖信息
      item.product_orders.each do |ipo|
        if ipo.numbers =~ /#{hit_number}/
          #在中奖记录中更新中奖信息
          ipo.update_attributes(is_hit: true, hit_number: hit_number)
          #在期数中更新中奖信息
          # item.update_attributes(hit_time: Time.now, hit_number: hit_number, number_total: total_count.to_s)
          item.update_hit_info(Time.now, hit_number, total_count.to_s, params[:cqssc].to_i)
          # item.product.update_attributes(already: +1, remain: -1)
          hit_mobile = ipo.user.mobile
          break
        end
      end
      flash[:info] = "已成功开奖，开奖号码是#{hit_number}, 中奖人为#{hit_mobile}"
      redirect_to :action => "items_list"
      #render :text => "已成功开奖，开奖号码是#{hit_number}, 中奖人为#{hit_mobile}"
    end
  end

  private
    def products_params
      params.require(:product).permit(:title, :type_id, :total_price, :desc, :numbers, :already, :remain, :weight)
      # params.require(:product).permit(attachements: :attachements)
    end

end