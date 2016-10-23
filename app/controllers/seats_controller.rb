class SeatsController < ApplicationController
  def index
    
  end

  def show
    
  end

  def new
    
  end

  def create
    
  end

  def edit
    
  end

  def update
    
  end

  def destroy
    
  end

  def update_status
    if params[:check_seat].blank? || params[:check_status].blank?
      render json: {status: 1, errmsg: "未选择座位号"}
    else
      params[:check_seat].each do |check_seat|
        seat = Seat.find_by_num(check_seat)
        if seat
          seat.update_attributes(status: params[:check_status])
        end
      end
      render json: {status: 0, errmsg: ""}
    end
  end

  def reset_seat
    if params[:seat].blank?
      render json: {status: 1, errmsg: "未选择座位号"}
    else
      seat = Seat.find_by_num(params[:seat])
      if seat
        seat.update_attributes(status: "idle")
      end
      render json: {status: 0, errmsg: ""}
    end
  end
end