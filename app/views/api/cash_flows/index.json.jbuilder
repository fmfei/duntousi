json.cash_flows @cash_flows do |cash_flow|
  json.created_at cash_flow.created_at.try(:strftime, "%Y/%m/%d/ %H:%M")
  json.description cash_flow.description.to_s
  json.amount rmb(cash_flow.amount)
  json.available rmb(cash_flow.available_of_user(current_user))
end