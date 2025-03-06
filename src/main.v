// このプログラムは n 月刊ラムダノート Vol.4, No.3 に掲載されている
// 「#2 型を活用した安全なアプリケーション開発（佐藤有斗）」の説明を V 言語で実践するものです。
// 書籍のサンプルコードは Scala で書かれていますが、自分の理のために別言語で写経してみました。
// https://www.lambdanote.com/products/n-vol-4-no-3-2024

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

// 確定済みの注文
struct ConfirmedOrder {
    BaseOrder
    confirmed_at string @[required]
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
    confirmed_order := ConfirmedOrder{
        BaseOrder: BaseOrder{
            order_id: "123",
            customer_id: "456",
            shipping_address: "東京都千代田区",
            lines: [
                OrderLine{product_id: "789", quantity: 1},
                OrderLine{product_id: "101", quantity: 2},
            ]
        },
        confirmed_at: "2021-01-01T00:00:00Z",
    }

    println(get_order_status(confirmed_order))
}
