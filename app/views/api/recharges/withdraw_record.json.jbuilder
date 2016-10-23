json.orders @withdraws do |order|
  json.amount order.amount.round(2)
  json.fee order.fee.round(2)
  json.received_amount order.received_amount.round(2)
  json.card_number order.card_number
  json.created_at order.created_at
  json.status order.status
end
