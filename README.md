# 型を活用した安全なアプリケーション開発 with V

このプログラムは n 月刊ラムダノート Vol.4, No.3 に掲載されている「#2 型を活用した安全なアプリケーション開発（佐藤有斗）」の説明を V 言語で実践するものです。

書籍のサンプルコードは Scala で書かれていますが、自分の理のために別言語で写経してみました。
https://www.lambdanote.com/products/n-vol-4-no-3-2024

## 必要なもの

- V 言語
  - 基本最新版であれば問題ないと思います
  - SQLite library: https://modules.vlang.io/db.sqlite.html
- Go 言語
  - sqldef を go mod で管理しています

## 実行方法

※ Linux (Ubuntu 24.04) でのみ動作確認しています。

まだ DB 準備をしていない場合は以下のコマンドで DB を準備してください。

```bash
make migration
```

アプリ実行 (といっても単発のプログラムでサーバーアプリケーション化はしていません)

```bash
v run .
```

## v-analyzer

VSCode などで V 言語をあつかう際には、v-analyzer (V 言語用の Language Server) を使うとよいです。

インストールなどは以下のリンクを参照してください。

https://github.com/vlang/v-analyzer

## Format

```bash
make fmt
```

## 参考資料

V 言語の参考リンクはソースコード中に適宜記載しています。
その他の参考資料は以下のリンクを参照してください。

- [sqldef](https://github.com/sqldef/sqldef)
- [Go 1.24で入ったGo製ツールの管理機能が便利だったのでおすすめしたい](https://blog.syum.ai/entry/2025/03/01/235814)
