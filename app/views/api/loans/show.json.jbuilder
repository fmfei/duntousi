json.id @loan.id
json.amount @loan.amount
json.available_amount @loan.available_amount
json.process @loan.progress
json.title @loan.title[0, 20]
json.interest @loan.interest
json.months @loan.months
json.desc @loan.desc
json.repay_style @loan.repay_style
json.gender @loan.borrower.info.gender
json.marry @loan.borrower.info.marriage.try(:name).to_s
json.wenhua @loan.borrower.info.education.try(:name).to_s
json.income @loan.borrower.info.income
json.shebao (@loan.borrower.info.social_security_id.present? ? '有' : '无')
json.house (@loan.borrower.info.housing.present? ? '有' : '无')
json.car (@loan.borrower.info.car.present? ? '有' : '无')
json.state @loan.state.name
json.files @identifications do |file|
  json.category file[:category]
  json.desc file[:desc]
end
json.bids @bids do |bid|
  json.mobile bid[:mobile]
  json.invest_amount bid[:invest_amount]
  json.created_at bid[:created_at]
  json.invest_type bid[:invest_type]
end