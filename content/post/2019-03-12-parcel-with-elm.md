---
title: "Parcel with Elm"
date: 2019-03-12T23:00:00+09:00
draft: false
tags: ["Elm", "BuildTool"]
---
[parcel-bundler/parcel: 📦🚀 Blazing fast, zero configuration web application bundler](https://github.com/parcel-bundler/parcel) というビルドツールがある。何気なく公式のドキュメントを読んでいたら、Elm でも使えるということで使ってみた。

[このページ](https://en.parceljs.org/elm.html)[^1]に Elm での使い方が簡単に書いてある。まだ内容が少ないのでコントリビュートチャンスかもしれない。でも(Elmが)マイナ言語なので、需要も少ないかもしれない。

[^1]: 英語版にリンクを貼るが、日本語訳のPRを出している人もいる。この記事が書かれた日の時点ではElmのページはまだ翻訳されていない。

# 使うまで

[🚀 Getting Started](https://en.parceljs.org/getting_started.html)を参考に使えるようにする。わたしは `yarn` でやった。

```
yarn global add parcel-bundler
mkdir parcel-test
yarn init -y
```

`parcel-test` の直下に `index.html` と `index.js` と `Main.elm` を作る。

```html
<!-- index.html -->

<html>
  <body>
    <main></main>
    <script src="./index.js"></script>
  </body>
</html>
```

```js
// index.js

import { Elm } from './Main.elm'

Elm.Main.init({
  node: document.querySelector('main')
})
```

```elm
-- Main.elm
module Main exposing (main)

import Browser
import Html exposing (h1, text)

main =
  h1 [] [ text "Hello, Elm!" ]
```

そして、 `parcel index.html` とやるとよしなに `parcel` がしてくれる。

`index.js` の `from ...` のパスを書き換えれば `./src/Main.elm` とかにファイルをおいても当然ビルドできる。`elm reactor` とかでも普通に開発に使えるが、とりあえず導入が簡単すぎて感動したので簡単にメモをした。
