module main

struct CancelOrderUseCase {
	repository OrderReopository
}

fn (u CancelOrderUseCase) execute(order_id string, cancel_reason string) ! {
	order := u.repository.find_by_id(order_id) or { return error('order not found') }
	now := '2025-01-01T00:00:00Z'

	// ConfirmOrder 以外で cancel を呼ぼうとするとコンパイルエラーになるので
	// キャンセルできない状態に対してキャンセルしようとすることを防げて嬉しい
	match order {
		UnconfirmedOrder {
			return error('確定していないのでキャンセルできません')
		}
		ConfirmedOrder {
			order.cancel(cancel_reason, now)
			return
		}
		CancelledOrder {
			return error('キャンセル済の注文はキャンセルできません')
		}
		ShippingOrder {
			return error('発送済みの注文はキャンセルできません')
		}
	}
}
