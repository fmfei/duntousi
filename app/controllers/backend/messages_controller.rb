# encoding: utf-8
class Backend::MessagesController < Backend::BaseController

  def index
    @messages = Message.order("created_at desc").paginate(:page => params[:page], :per_page => 20)
    @title = '站内信管理'
  end
end
