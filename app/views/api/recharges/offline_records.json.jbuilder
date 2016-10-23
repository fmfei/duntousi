json.orders @offline_recharges do |order|
  json.amount order.amount.round(2)
  json.bank_name order.bank_name
  json.created_at order.created_at
  json.status order.status_name
end