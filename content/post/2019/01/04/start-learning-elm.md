---
title: "Elmの勉強を始めた"
date: 2019-01-04T22:42:27+09:00
draft: false
categories: ["Studying"]
---

# Elm 書き始めた

フロントエンドをやりたいなぁとずっとぼんやりと思っていたけど結局 Vue.js も React もなんか手を出すきになれずボサッとしていたら年が明けていた。なので Elm を始めた。

[Elm \- A delightful language for reliable webapps](https://elm-lang.org/)

もともと Haskell は勉強したことがあったので構文にはそこまで違和感を感じず、一方で動く場所がターミナルでなくブラウザだというのが面白い。しかも `elm` コマンドをインストールすれば `elm reactor` でささっと動作確認ができるし、HTML にしたければ `elm make src/Main.elm` とやればぱっとできてしまう。非常にとっつきやすいと感じた。

また、[オンラインエディタ](https://ellie-app.com/)があって、開発環境を整備しなくてもブラウザで体験もできる。Elm Guide からもリンクされている[elm-architecture-turorial](https://github.com/evancz/elm-architecture-tutorial)を Fork して演習問題を解くとか、勉強する環境はかなりお膳立てされている。

## インストール

`elm` コマンドをインストールするには Elm Guide にしたがってインストーラーをダウンロードしてもいいし、

```
npm install -g elm
```

としてもよい。 `elm-format` というフォーマッタもあって、 Emacs から使えるようにしている。

## 進捗

まだCmd/Subとかがよくわかっていないけど、[Elm Guide の日本語翻訳プロジェクト](https://guide.elm-lang.jp/)を半分くらい読んだので、最初のサンプルであるカウンターを拡張して、アニメ「やがて君になる」の第N話のあらすじを表示するアプリとかを試しに作ってみている。

# 今後

普通に JavaScript を勉強しないとなぁという気持ちもあるといえばあるのだけど、一度にいろんなことをやるのもあれなので一旦 Elm でいろいろと作ってみようかなと思った。やっぱりブラウザで動くとなると自分もやっていて面白い。
