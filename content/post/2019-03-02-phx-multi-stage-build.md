---
title: "Phoenixアプリの実行時にNodejsランタイムを環境にもたないようにしたい"
date: 2019-03-02T01:00:00+09:00
draft: false
tags: ["Elixir", "Docker"]
---

これさえできれば十分とは到底言えたものではないが、Phonenix アプリをプロダクション環境でもコンテナ化をする、ということを考えた時に最低限次のことを実現しようと思った:

    実行環境に Node JS の実行環境を持ちたくない！！

以下に理由を挙げるが、念の為に前提として、アプリケーションをデプロイする環境には不要ば場合であることを明示しておく。 `webpack --mode production` をした結果は使うけど `node` コマンドさえ Phoenix サーバーを起動するためには必要ないはずだ[^1]。

[^1]: どうも例外的な状況が全く存在しないわけではないようだ。

理由だが、単純な話だ。容量がかさむのと、セキュリティリスクが高まるからである。容量がかさむといろいろと不都合がある(開発にもデプロイにも)し、`node_modules` のファイルを抱え込むことは脆弱性をつく場所が増えることを意味する。必要のないものは可能な限り排除されているべきである。

しかし、前述のように `yarn`[^2] や `webpack` は必要なのでビルドするときには Node も Elixir もどちらの実行環境もコンテナの中に構築する必要があった。Node の実行環境を適切に排除するのは面倒だし、削除するべきファイルを全部洗い出すなんて至難の技だよな、などと思っていたところ、救世主に出会った。その名も、 Multi Stage Build である。

[^2]: `npm` でももちろん問題ないのだが、現在は `yarn` を使っている。


### Multi Stage Build

たとえば、次の記事で概要は把握できるだろう。

[Docker multi stage buildで変わるDockerfileの常識 \- Qiita](https://qiita.com/minamijoyo/items/711704e85b45ff5d6405)

要するに、`FROM` 文に名前をつけることで、別の `FROM` と区別をすることでビルド中のイメージとイメージの間でファイルのコピーができる。だからビルド時だけに必要な実行環境は一切破棄とかせず、ビルド結果だけを `COPY --from=<NAME> ..` で実行用のイメージに移せる。このベースイメージが異なってもいいし同じでもいい。だから例えばビルド時は Debian だけど実行時は Alpine みたいなこともできる[^3]。

[^3]: うまく動くことを保証するものではない。

### 実装サンプル

そんなわけで、Phoenixでも `webpack` でビルドした結果だけを `COPY --from=builder foo bar` で持ってこられないかと調査をしていた。実際にできたのでその Dockerfile の概要を下記に書く。このコードはそのまま動くとは限らないしそもそも一度も実行していないのでよろしく。

```Dockerfile
FROM elixir:1.8.1-slim as builder

RUN mkdir -p /src
COPY ./ /src/
WORKDIR /src

RUN apt-get update \
    && apt-get install -y --no-install-recommends curl apt-transport-https gnupg ca-certificates build-essential \
    && curl -sL https://deb.nodesource.com/setup_10.x | bash - \
    && curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
    && echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends nodejs yarn
RUN mix local.hex --force \  # 詳しい原因は調べてないけど `yarn install` に失敗するので phx の環境構築をしとく
    && mix local.rebar --force \
    && mix deps.get \
    && cd assets && yarn install && cd ../
    && cd assets && yarn install && yarn run webpack --mode production && cd ..
# ここまでがビルドステージ

FROM elixir:1.8.1-slim
RUN mkdir -p /src
COPY ./ /src/
WORKDIR /src
ENV MIX_ENV=prod
# ここでビルドステージの成果物を COPY している
COPY --from=builder /src/priv/static/ /src/priv/static/
RUN mix local.hex --force \
    && mix local.rebar --force \
    && mix deps.get --only prod \
    && mix compile \
    && mix phx.digest
CMD ["/src/setup.sh"]
```

要は `yarn run webpack --mode production` が `priv/static` 配下に成果物をアウトプットするように設定されているようだったので、上のステージは `node` や `yarn` を入れてビルドできるようにしてビルドを行う。その下のステージでは必要なビルド成果物を取得することと、Phoenix の実行環境の構築だけを行う。

これで `docker run -it $IMAGE_TAG bash` とかやって `node` とか `yarn` とかうっても command not found になる。人生で初めて command not found が嬉しいと思った。
