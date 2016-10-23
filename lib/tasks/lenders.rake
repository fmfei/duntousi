# coding: utf-8
namespace :lenders do


  # 发送邮件给所有出借人
  desc "发送全Lender邮件"
  task :email_to_all => :environment do

    User.lender.where("email is not null").find_each do |lender|
      Resque.enqueue(EmailJob, "send_lender", {:user_id => lender.id})
    end
  end

  desc "发送全Lender短信"
  task :sms_to_all => :environment do

    User.lender.where("mobile is not null").find_each do |lender|
      Resque.enqueue(SmsJob, :send_lender, lender.mobile)
    end
  end

  task :update_loan => :environment do
    Loan.where('id < 962').each do |loan|
      loan.title = '(往期收益)' + loan.title
      loan.save
    end
  end

end