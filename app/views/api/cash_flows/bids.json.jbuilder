json.bids @bids do |bid|
  json.title truncate(bid.loan.title, length:9)
  json.invest_month bid.invest_month
  json.amount bid.loan.amount
  json.interest bid.interest
  json.invest_amount bid.invest_amount
  json.status t(bid.status)
  json.created_at bid.created_at.try(:strftime, "%Y/%m/%d/ %H:%M")
end