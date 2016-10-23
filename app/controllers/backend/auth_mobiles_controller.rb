# encoding: utf-8
class Backend::AuthMobilesController < Backend::BaseController
  def index
    if params[:state] == 'true'
      @lenders = Role.find_by_name('投资人').users.auth_mobile_pass.order("id desc").simple_search(params[:q]).paginate :page => params[:page], :per_page => 20
    else
      @lenders = Role.find_by_name('投资人').users.auth_mobile_pass(false).order("id desc").simple_search(params[:q]).paginate :page => params[:page], :per_page => 20
    end
    @title = '手机认证管理'
  end

  def auth_realname_pass
    @lender = Role.find_by_name('投资人').users.find(params[:id])
    @lender.pass_auth_mobile
    return :back
  end
end
