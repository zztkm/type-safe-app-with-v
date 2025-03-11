module main

import db.sqlite

// OrderNotFoundError は指定した order_id に対応する Order が見つからなかったことを表す
struct OrderNotFoundError {
	Error
}

struct OrderLineNotFoundError {
	Error
}

// QueryError はクエリ実行時にエラーが発生したことを表す
struct QueryError {
	Error
	msg string
}

fn (err QueryError) message() string {
	return 'クエリ実行時にエラーが発生しました: ${err.msg}'
}

struct OrderRepository {
	db &sqlite.DB
}

// find_by_id は order_id に対応する Order を返す
//
// NOTE: 本当は ?Order 型を返したいが、これだと Query 実行時にエラーが発生した場合に
// none を返すしかないので、エラーが発生したのか、Order が見つからなかったのか区別できない。
// そのため、QueryError と OrderNotFoundError を何が原因で row を取得できなかったのかを区別するような実装にしてみた。
// 参考書籍の Scala の例では、Option[Order] で定義していて、異常なデータを検出したときは例外を投げるようにしてあるが
// V には例外がないので、エラーを返すようにしている。
fn (r OrderRepository) find_by_id(order_id int) !Order {
	// TODO(zztkm): exec_map で取得するほうが良いかも
	order_row := r.db.exec_param('SELECT * FROM orders WHERE order_id = ?', order_id.str()) or {
		return QueryError{
			msg: 'orders テーブルから order_id に対応する row を取得できませんでした'
		}
	}
	if order_row.len == 0 {
		return OrderNotFoundError{}
	}

	order_line_rows := r.db.exec_param('SELECT * FROM order_lines WHERE order_id = ?',
		order_id.str()) or {
		return QueryError{
			msg: 'order_lines テーブルから order_id に対応する row を取得できませんでした'
		}
	}
	if order_line_rows.len == 0 {
		return OrderLineNotFoundError{}
	}
	return r.convert_row_to_order(order_row[0], order_line_rows)
}

fn (r OrderRepository) convert_row_to_order(order_row sqlite.Row, order_line_rows []sqlite.Row) !Order {
	status := order_row.vals[3]
	mut order_lines := []OrderLine{}
	for order_line in order_line_rows {
		order_lines << r.convert_row_to_order_line(order_line)
	}
	match status.to_lower() {
		'unconfirmed' {
			return UnconfirmedOrder{
				order_id:         order_row.vals[0].int()
				customer_id:      order_row.vals[1].int()
				shipping_address: order_row.vals[2]
				lines:            order_lines
			}
		}
		'confirmed' {
			return ConfirmedOrder{
				order_id:         order_row.vals[0].int()
				customer_id:      order_row.vals[1].int()
				shipping_address: order_row.vals[2]
				lines:            order_lines
				confirmed_at:     order_row.vals[4]
			}
		}
		'cancelled' {
			return CancelledOrder{
				order_id:         order_row.vals[0].int()
				customer_id:      order_row.vals[1].int()
				shipping_address: order_row.vals[2]
				lines:            order_lines
				confirmed_at:     order_row.vals[4]
				canceled_at:      order_row.vals[5]
				cancel_reason:    order_row.vals[6]
			}
		}
		'shipping' {
			return ShippingOrder{
				order_id:               order_row.vals[0].int()
				customer_id:            order_row.vals[1].int()
				shipping_address:       order_row.vals[2]
				lines:                  order_lines
				confirmed_at:           order_row.vals[4]
				shipping_started_at:    order_row.vals[7]
				shipped_by:             order_row.vals[8].int()
				scheduled_arrival_date: order_row.vals[9]
			}
		}
		else {
			return error('invalid status')
		}
	}
}

fn (r OrderRepository) convert_row_to_order_line(order_line_row sqlite.Row) OrderLine {
	return OrderLine{
		product_id: order_line_row.vals[2].int()
		quantity:   order_line_row.vals[3].int()
	}
}

// TODO: 現在の実装だと Order で order_id をダミーで定義しないといけないので、どうにかしたい
fn (r OrderRepository) insert(order Order) ! {
	query, params := r.convert_order_to_insert_query_with_params(order)
	r.db.exec_param_many(query, params) or {
		return QueryError{
			msg: 'orders テーブルへの挿入に失敗しました'
		}
	}
	order_id := int(r.db.last_insert_rowid())
	for order_line in order.lines {
		order_line_query, order_line_params := r.convert_order_line_to_insert_query_with_params(order_id,
			order_line)
		r.db.exec_param_many(order_line_query, order_line_params) or {
			return QueryError{
				msg: 'order_lines テーブルへの挿入に失敗しました'
			}
		}
	}
	return
}

fn (r OrderRepository) convert_order_to_insert_query_with_params(order Order) (string, []string) {
	match order {
		UnconfirmedOrder {
			query := 'INSERT INTO orders (customer_id, shipping_address, status) VALUES (?, ?, ?)'
			params := [
				order.customer_id.str(),
				order.shipping_address,
				'unconfirmed',
			]
			return query, params
		}
		ConfirmedOrder {
			query := 'INSERT INTO orders (customer_id, shipping_address, status, confirmed_at) VALUES (?, ?, ?, ?)'
			params := [
				order.customer_id.str(),
				order.shipping_address,
				'confirmed',
				order.confirmed_at,
			]
			return query, params
		}
		CancelledOrder {
			query := 'INSERT INTO orders (customer_id, shipping_address, status, confirmed_at, canceled_at, cancel_reason) VALUES (?, ?, ?, ?, ?, ?)'
			params := [
				order.customer_id.str(),
				order.shipping_address,
				'cancelled',
				order.confirmed_at,
				order.canceled_at,
				order.cancel_reason,
			]
			return query, params
		}
		ShippingOrder {
			query := 'INSERT INTO orders (customer_id, shipping_address, status, confirmed_at, shipping_started_at, shipped_by, scheduled_arrival_date) VALUES (?, ?, ?, ?, ?, ?, ?)'
			params := [
				order.customer_id.str(),
				order.shipping_address,
				'shipping',
				order.confirmed_at,
				order.shipping_started_at,
				order.shipped_by.str(),
				order.scheduled_arrival_date,
			]
			return query, params
		}
	}
}

fn (r OrderRepository) convert_order_line_to_insert_query_with_params(order_id int, order_line OrderLine) (string, []string) {
	query := 'INSERT INTO order_lines (order_id, product_id, quantity) VALUES (?, ?, ?)'
	params := [
		order_id.str(),
		order_line.product_id.str(),
		order_line.quantity.str(),
	]
	return query, params
}
