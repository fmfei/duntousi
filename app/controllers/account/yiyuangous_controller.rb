class Account::YiyuangousController < Account::BaseController
  def index
    
  end
  def progressing
    #正在进行的夺宝活动
    progressing_items = Item.where("remain != 0")
    @product_orders = current_user.product_orders.where(item_id: progressing_items.map{|item| item.id}).order("id desc").paginate(:page => params[:page], :per_page => 15)
  end

  def waiting
    #等待开奖活动
    progressing_items = Item.where("remain = 0 and hit_number is null")
    @product_orders = current_user.product_orders.where(item_id: progressing_items.map{|item| item.id}).order("id desc").paginate(:page => params[:page], :per_page => 15)
  end

  def finished
    #已揭晓的夺宝活动
    progressing_items = Item.where("hit_number is not null")
    @product_orders = current_user.product_orders.where(item_id: progressing_items.map{|item| item.id}).order("id desc").paginate(:page => params[:page], :per_page => 15)
  end

  def details
    
  end

end