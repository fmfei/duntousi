# encoding: utf-8
class Backend::InvitesController < Backend::BaseController
  def index
    if params[:q].present?
      @lenders = Role.find_by_name('投资人').users.reorder("created_at desc").simple_search(params[:q]).paginate(:page => params[:page], :per_page => 20)
    else
      @lenders = Role.find_by_name('投资人').users.where('from_user_id is not null').reorder("created_at desc").paginate(:page => params[:page], :per_page => 20)
    end
  end
end