json.orders @pay_orders do |order|
  json.amount order.amount.round(2)
  json.created_at order.created_at
  json.status "充值成功"
end