# encoding: utf-8

class LoanApplicationsController < ApplicationController
	def new
		@loan_application = LoanApplication.new
    @title = '我要借款'
	end

	def create
		@loan_application = LoanApplication.new(info_params)
    if @loan_application.save
      flash[:success] = '您的贷款申请表已成功提交！近期请保持您的电话畅通，我们会尽快与您联系。谢谢！'
      redirect_to '/loan_applications/new'
    else
      flash[:errors] = @loan_application.errors
      render :new
    end
	end

      private
      def info_params
        params.require(:loan_application).permit(:name, :id_card, :phone, :email, :register_addr, :addr, :monthly_income, :monthly_expense, :company, :title, :amount, :loan_usage)
      end
end
