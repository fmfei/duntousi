# encoding: utf-8
class Backend::AutoInvestRulesController < Backend::BaseController
  def index
    @q = AutoInvestRule.ransack(params[:q])
    @rules = @q.result.active.reorder('queue asc,created_at asc').paginate :page => params[:page], :per_page => 50
    @title = '自动投标队列'
  end

  def stats
  end

  # 执行自动投标
  def execute
    AutoInvestRule.exec_for(Loan.find(params[:id]))
    redirect_to :back
  end

end