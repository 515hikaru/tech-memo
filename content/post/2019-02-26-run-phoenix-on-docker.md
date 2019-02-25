---
title: "Phoenix API サーバーの Docker 化"
date: 2019-02-26T01:00:00+09:00
draft: false
tags: ["Elixir", "Docker"]
---

Postgres を `docker run -d --rm ...` して、 Phoenix サーバーを `mix phx.server` して、というのにだんだん「ムキーッ」ってなってきたので Docker コンテナ化をすることにした。

ちなみに JavaScript などフロントエンドの部分は今回はなかったので面倒がより少なかった。

## やること

- 開発環境用のコンテナを作る
  - いったんプロダクションコンテナのことは考えない
  - 頑張って容量削ったりもしない

`docker-compose up` とやると Phoenix サーバーと Postgres サーバーが立ち上がって `mix ecto.setup; mix phx.server` されるという状態をゴールにする。

## やったこと

### Dockerfile

まず Dockerfile を書く。

```dockerfile
FROM elixir:1.8.1

RUN mkdir -p /src
COPY ./ /src/
WORKDIR /src/
RUN mix local.hex --force \
    && mix local.rebar --force \
    && mix deps.get

ENV MIX_DEV=dev

EXPOSE 8000

CMD ["/src/setup.sh"]
```

全部 `COPY` している都合いろいろと不要なものも混じるので `.dockerignore` をいろいろ設定する。本当は `COPY` するファイルやディレクトリを逐一指定したほうがいいのかもしれない。

### shell

セットアップするシェルスクリプト(Dockerfile の `setup.sh`)を書く。といっても `mix` を使うだけ。

```sh
#!/bin/sh

mix ecto.setup
PORT=8000 mix phx.server  # デフォルトのポート番号は 4000
```

### docker-compose の設定

```yaml
version: "3"
services:
  postgres:
      image: "postgres:11.2"
      ports:
        - "5432:5432"
      environment:
          POSTGRES_USER: postgres
          POSTGRES_PASSWORD: postgres

  core_api:
      build: .
      ports:
        - "8000:8000"
      environment:
          POSTGRES_HOST: postgres
      depends_on:
        - postgres
      links:
        - postgres
```

もしかしたら `links` があれば `depends_on` は要らないかも。

### config/dev.exs の設定

Postgres のホスト名を links で指定した名前にする必要があるので、ここでちょこっとだけ Elixir のコードを書く。といってもほんとにちょこっとだけ。

データベースの設定の `hostname: "localhost"` を次のように指定。

```elixir
# config/dev.exs

host_name =
  case System.get_env("POSTGRES_HOST") do
    nil -> "localhost"
    x -> x
  end

# Configure your database
config :api, Api.Repo,
  username: "postgres",
  password: "postgres",
  database: "api_dev",
  hostname: "localhost",
  hostname: host_name,
  pool_size: 10
```

環境変数 `POSTGRES_HOST` があればその値を、なければ `"localhost"` を採用するパターンマッチを書いただけ。

## おわり

この状態で `docker-compose up` をやると無事に起動します。めでたしめでたし。