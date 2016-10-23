# encoding: utf-8
class Backend::ProtocolsController < Backend::BaseController

  def index
    redirect_to "/backend/protocols/loan"
  end
  def show
    @title = '协议管理'
    render :template => "/backend/protocols/#{params[:id]}"
  end

end
