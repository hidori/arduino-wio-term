# WioTerm 開発ガイド

## 概要

WioTerm は、Wio Terminal で動作する Arduino アプリケーションプロジェクト。
UART 接続された装置と対話的なテキスト入出力を行うためのアプリケーション。

## 実行環境

- 対応ボード: Wio Terminal
- 依存ライブラリ: lvgl 8.3.11
- LVGL 設定ファイル: ~/Arduino/libraries/lv_conf.h

## 機能仕様

### 主な機能

- シリアル通信
- vt100 エミュレーション
- 80x25 文字表示
- フォントサイズの変更
- 拡大縮小表示
- 仮想キーボード

### 入出力

- シリアル入出力
- 画面表示
- 仮想キーボード入力
- 拡大縮小表示

## 開発方針

- 実装は Wio Terminal 向けに必要な範囲へ限定する。
- 対象外ボード向けの設定や説明を残さない。
- Makefile と arduino-cli.yaml の設定は Wio Terminal 向けターゲットに合わせる。

## ビルドと確認

- 使用するビルドターゲット: `make build/wio-terminal`
- 使用するデプロイターゲット: `make deploy/wio-terminal`
- 依存ライブラリを導入する場合は、`make install/lib` を実行して `lvgl 8.3.11` を導入する。
- LVGL を使用する場合は、公式の Arduino 向け手順に従い `lv_conf.h` を `~/Arduino/libraries/` に配置する。
- 変更後は、事前準備として `make install` を実行したうえで、`make build/wio-terminal` を実行して確認する。

## アーキテクチャ

MVC 様の構成を採用する。

* Model
  * シリアル通信の状態や受信データを保持する
* View
  * 画面表示や仮想キーボードの描画を行う
* Controller
  * 明確な Controller は存在せず、loop() 関数が Controller 相当の責務を担う

## 実装方針

* 動的メモリ確保・解放は極力避ける
* 各種バッファはグローバル変数もしくはスタティック変数で確保する

### シリアル通信

###
