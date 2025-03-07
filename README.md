# 型を活用した安全なアプリケーション開発 with V

このプログラムは n 月刊ラムダノート Vol.4, No.3 に掲載されている「#2 型を活用した安全なアプリケーション開発（佐藤有斗）」の説明を V 言語で実践するものです。

書籍のサンプルコードは Scala で書かれていますが、自分の理のために別言語で写経してみました。
https://www.lambdanote.com/products/n-vol-4-no-3-2024

## 実行方法

```bash
v run .
```

## v-analyzer

VSCode などで V 言語をあつかう際には、v-analyzer (V 言語用の Language Server) を使うとよいです。

インストールなどは以下のリンクを参照してください。

https://github.com/vlang/v-analyzer

## Format

```bash
v fmt -w .
```
