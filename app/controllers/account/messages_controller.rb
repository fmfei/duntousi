# encoding: utf-8
class Account::MessagesController < Account::BaseController

  def index
    case params[:tab]
    when "unread"
      @messages= current_user.received_messages.unread
    when "read"
      @messages = current_user.received_messages.read
    else
      @messages = current_user.received_messages.paginate :page => params[:page], :per_page => 10
    end
    # @messages_unread = current_user.received_messages.unread
    # @messages_read = current_user.received_messages.read
    # @messages = current_user.received_messages
    # @messages_unread = @messages_unread.order("created_at desc").paginate :page => params[:page], :per_page => 10
    # @messages_read = @messages_read.order("created_at desc").paginate :page => params[:page], :per_page => 10
    # @messages = @messages.order("created_at desc").paginate :page => params[:page], :per_page => 10
    # @messages.set_read unless params[:tab]=="read"
  end

end
