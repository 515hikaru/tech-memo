---
title: "Elm で静的サイト"
date: 2019-04-10T00:00:00+09:00
draft: false
tags: ["Elm", "BuildTool"]
---

Elm で静的サイトの構築をしている。

[515hikaru/mypage: My profile page](https://github.com/515hikaru/mypage)

まだ画像とかロゴとかCSSとかCSSとかアニメーションとかを真面目に書いていないのでもう少し頑張りたい。とりあえず左側の箱をクリックすると切り替わることや、左は切り替えだけで右にしかリンクがないことは非自明だなと自分でも思っている。まだURL貼りたい完成度ではないので、見たければてきとうに辿ってください。

相も変わらず Netlify で配信はしている。

# 目的

## フロントエンド開発を経験するため

もともとわたしはあまり JavaScript が読めない。これは ES2015 以降とか以前とかそういう話ではなく、単純に書いた量が足りない。そしてフロントエンドのエコシステム[^1]は上澄みだけユーザーとして使わせてもらっている、という感じだ。

[^1]: npm, yarn などのパッケージマネージャ、Webpack, Parcel などのビルドツール、などなど

つまり、フロントエンド開発をやってみるとして[^2]、

* JavaScript/TypeScript というプログラミング言語の壁
* React/Vue.js/Angular などのフレームワークの壁
* npm(yarn), Webpack などのツール群の壁

という 3 種類の壁が存在することになる。これら全ての壁を同時に攻略するのは正直言ってやってられないと思っている。

[^2]: ちなみにフロントエンドエンジニアになりたいわけでは決してない。ただ Web 開発で生きていくのにフロントエンドについて何も知らないのは問題だと感じることが幾度もあった。

## Elm にした理由

そこで、わたしは Elm に目をつけた。Elm を書いている大きな目的のひとつは、フロントエンドのエコシステムに **深入りはせず** にフロントエンド開発の仕組みを知ることだ。より具体的には、SPA を書く方法を知るとかだ。もちろんこの選択をした理由はわたしの過去のプログラミング経験や目にしたコミュニティが基になっている:

* 一時期 Haskell を学んだ経験がある(Elm のシンタックスには見慣れていた)
* 日本人によるドキュメントの翻訳が活発([Elm Guide](https://guide.elm-lang.jp/))
    * 最近は[本も出版された](https://www.amazon.co.jp/%E5%9F%BA%E7%A4%8E%E3%81%8B%E3%82%89%E3%82%8F%E3%81%8B%E3%82%8B-Elm-%E9%B3%A5%E5%B1%85-%E9%99%BD%E4%BB%8B/dp/4863542224/ref=sr_1_fkmrnull_1?__mk_ja_JP=%E3%82%AB%E3%82%BF%E3%82%AB%E3%83%8A&keywords=%E5%9F%BA%E7%A4%8E%E3%81%8B%E3%82%89%E3%82%8F%E3%81%8B%E3%82%8BElm&qid=1554824157&s=gateway&sr=8-1-fkmrnull)

# 開発環境周り

## 開発サーバー & ビルド & デプロイ

Parcel におまかせしている。package.json に

```json
{
  "scripts": {
    "dev-install": "yarn install -D",
    "start": "parcel index.html",
    "check-format": "elm-format --validate src/*",
    "build": "parcel build -d public index.html",
    "deploy": "yarn run build && netlify deploy --prod"
  },
  ...
}
```

というようなスクリプトを定義しておいて、 `yarn start` で開発サーバーが立ち上がるし、 `yarn run deploy` で手動デプロイもできるようになっている。

といっても今は Netlify で push するたびにデプロイしてもらうようにしている。 `yarn run build` で `public/` に成果物が生成されるので、それを公開するようにしている。 `netlify.toml` を書いていないのでコード化できていない。

## CI

テストはまだ書けていない。Elm 0.19 でのテストの書き方をよく知らない。

とりあえず今は Travis CI で `elm-format` がちゃんとできているかだけチェックしている: 上の package.json で `yarn run check-format` を呼ぶだけのビルドジョブだ。

```yaml
language: node_js

node_js:
  - "stable"
  - "lts/*"


before_install:
  - curl -o- -L https://yarnpkg.com/install.sh | bash -s -- --version 1.15.2
  - export PATH="$HOME/.yarn/bin:$PATH"

script:
  - yarn
  - yarn run check-format
```

ちなみに、こういうのは早めにやったほうがいい。

# 今後の展望 -- Elm で何をするか

まずはペラ1枚だけどカウンターアプリのように動く、というサイトを作ってみることから始めている。正直言ってコードはめちゃくちゃ雑なのだが...

次に、ToDoリストアプリでもいいからなんらかのSPAを作る、というのが当面のゴールだろう。あるいは Vue.js 入門とかを Elm で実装するとかも面白いかな、なんて思ったり思わなかったりしている。こういう書き方をするときはたいてい実現されない。

ちなみに、Elm のいいところとかはわたしが書かなくてもいろんな人が言っている/書いているので今更書かないけれど、個人的にはHaskellよいもとっつきやすいと思う。
