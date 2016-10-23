# encoding: utf-8
class Account::CollectionsController < Account::BaseController

  # 收款明细
  def index
    @collections = current_user.collections.unpaid.order('due_date').paginate :page => params[:page], :per_page => 20
  end

end