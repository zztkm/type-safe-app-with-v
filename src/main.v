module main

// NOTE: required fields: https://docs.vlang.io/structs.html#required-fields
// この属性がついたフィールドは、構造体を初期化する際に必ず明示的に初期化する必要がある。
// すべてのフィールドにつけたいと思うと面倒だなと思ったけど、Copilot が自動生成してくれるので特に問題ないかもしれない...

// 注文明細
struct OrderLine {
    product_id string @[required]
    quantity int @[required]
}

// ベースとなる注文データ構造
struct BaseOrder {
    order_id string @[required]
    customer_id string @[required]
    shipping_address string @[required]
    lines []OrderLine @[required]
}

// 未確定の注文
struct UnconfirmedOrder {
    BaseOrder
}

// 確定処理
fn (o UnconfirmedOrder) confirm(now string) ConfirmedOrder {
    return ConfirmedOrder{
        BaseOrder: o.BaseOrder,
        confirmed_at: now,
    }
}

// 確定済みの注文
struct ConfirmedOrder {
    BaseOrder
    confirmed_at string @[required]
}

// キャンセル処理
fn (o ConfirmedOrder) cancel(cancel_reason string, now string) CancelledOrder{
    return CancelledOrder{
        BaseOrder: o.BaseOrder,
        confirmed_at: o.confirmed_at,
        canceled_at: now,
        cancel_reason: cancel_reason,
    }
}

// キャンセル済みの注文
struct CancelledOrder {
    BaseOrder
    confirmed_at string @[required]
    canceled_at string @[required]
    cancel_reason string @[required]
}

// 発送済みの注文
struct ShippingOrder {
    BaseOrder
    confirmed_at string @[required]
    shipped_at string @[required]
    // 配送会社 ID
    shipping_company_id string @[required]
    // 発送開始日時
    shipping_started_at string @[required]
    // 到着予定日
    estimated_arrival_at string @[required]
}

// https://docs.vlang.io/type-declarations.html#sum-types
type Order = UnconfirmedOrder | ConfirmedOrder | CancelledOrder | ShippingOrder

// https://docs.vlang.io/statements-&-expressions.html#match
// match は sumtype でも使える
// Order に型を追加したときに、追加された型の処理を忘れるとコンパイルエラーになってくれるので安心
fn get_order_status(order Order) string {
    return match order {
        UnconfirmedOrder{ "未確定" }
        ConfirmedOrder { "確定済" }
        CancelledOrder { "キャンセル済" }
        ShippingOrder { "発送済" }
    }
}

fn main() {
    // すべてのフィールドを明示的に初期化する必要がある
    // 初期化していないフィールドがあるとコンパイルエラーになる (v-analyzer で警告が出る)
    repo := OrderReopository{}

    order_id := "123"
    cancel_reason := "もっと安い商品を見つけた"

    cancel_order_use_case := CancelOrderUseCase{
        repository: repo,
    }

    // キャンセル処理実行
    cancel_order_use_case.execute(order_id, cancel_reason) or {
        println("キャンセル処理に失敗しました: ${err}")
        return
    }
    println("キャンセルの処理が完了しました")
}
