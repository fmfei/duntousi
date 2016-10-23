json.loans @loans do |loan|
  json.id loan.id
  json.title loan.title
  json.amount loan.amount
  json.available_amount loan.available_amount
  json.months loan.months
  json.interest loan.interest
  json.repay_style loan.repay_style
  json.repaying (loan.available_amount == 0)
  json.desc loan.desc
  json.state loan.state.name
end