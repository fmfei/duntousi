# encoding: utf-8

require 'csv'

class Backend::LoanApplicationsController < Backend::BaseController
	def index
    @title = '贷款申请列表'
    @loan_applications = LoanApplication.order("id desc").paginate(:page => params[:page], :per_page => (params[:per_page_la] or 20))
    cookies[:per_page_la] = params[:per_page_la]
  end

  def show
  	@loan_application = LoanApplication.find(params[:id])
  end

  def download
  	if params[:printout].present?
  		Spreadsheet.client_encoding = 'UTF-8'
  		book = Spreadsheet::Workbook.new
  		@loan_applications = LoanApplication.order("id desc").find(params[:printout])
  		sheet1 = book.create_worksheet
  		sheet1.row(0).push("借款金额", "借款用途", "姓名", "身份证", "电话", "邮箱", "户籍", "居住地", "月收入(元)", "月开销(元)", "工作单位", "担任职务", "申请时间")
  		@loan_applications.each_with_index do |l, i|
  			sheet1.row(i + 1).push(
  				l.amount,
		  		l.loan_usage,
		  		l.name,
		  		l.id_card,
		  		l.phone,
		  		l.email,
		  		l.register_addr,
		  		l.addr,
		  		l.monthly_income,
		  		l.monthly_expense,
		  		l.company,
		  		l.title,
		  		l.created_at.strftime('%Y-%m-%d')
  			)
  		end
  		str_io = StringIO.new
	    book.write(str_io)
	    send_data(str_io.string, :filename => "loan_applications#{Time.now.strftime('%x')}.xls" )
  	else
      flash[:errors] = "请至少选择一项"
      redirect_to :back
    end
  end

end
