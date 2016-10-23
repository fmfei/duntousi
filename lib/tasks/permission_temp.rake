# coding: utf-8
namespace :add_temp_rk do
  
  desc '添加查看余额的权限'
  task :setup_permissions => :environment do
    if Permission.find_by_name("两周内庆转盘").blank?
      Permission.create( :name => '两周内庆转盘',
                         :action => 'manage',
                         :subject => '/backend/promotions/two_yr_anniversary')
    end
    if Permission.find_by_name("最新活动").blank?
      Permission.create( :name => '最新活动',
                         :action => 'manage',
                         :subject => '/backend/promotions/activies')
    end
  end

  desc '修改约标title'
  task :modify_loan_title => :environment do
    loan = Loan.find(1215)
    loan.title = "（约标）某公司土地及房产抵押，经营周转"
    loan.save
  end

end