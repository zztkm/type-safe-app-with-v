module main

struct OrderReopository {}

// find_by_id は order_id に対応する Order を返す
fn (r OrderReopository) find_by_id(order_id string) ?Order {
	// ここではダミーのデータを返す
    return ConfirmedOrder{
        order_id: order_id,
        customer_id: "456",
        shipping_address: "東京都千代田区",
        lines: [
            OrderLine{product_id: "789", quantity: 1},
            OrderLine{product_id: "101", quantity: 2},
        ],
        confirmed_at: "2021-01-01T00:00:00Z",
    }
}
