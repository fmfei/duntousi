# encoding: utf-8
class Account::BidsController < Account::BaseController

  # 投标记录
  def index
    # @search  = current_user.bids.search(params[:search])
    @bids = current_user.bids.status_in(['bidding', 'bids_auditing']).order("created_at desc").paginate :page => params[:page], :per_page => 20
  end

  def repaying
    @search  = current_user.bids.search(params[:search])
    @bids = @search.result.status_in(['repaying', 'overdue']).order("created_at desc").paginate :page => params[:page], :per_page => 20
  end

  def finished
    @search  = current_user.bids.finished.search(params[:search])
    @bids = @search.result.order("created_at desc").paginate :page => params[:page], :per_page => 20
  end

  # 理财统计
  def stat
  end

  def contract
    @bid = current_user.bids.find(params[:id])
    if @bid.present?
    else
      redirect_to :back
    end
  end

  def print_contract
    @bid = current_user.bids.find(params[:id])
    if @bid.present?
      render :contract,layout: false
    else
      redirect_to :back
    end
  end

  #新手标
  def rookie
    @bids = current_user.rookie_bids.paginate :page => params[:page], :per_page => 20
  end

end