---
title: "DockerHub と GitHub を連携して Docker Image を自動 push する"
date: 2020-04-30T23:02:46+09:00
draft: false
tags: ["BuildTool"]
---

DockerHub にイメージを push するのが、いつの間にか自動でできるようになってたらしい。

ちょっと GitLab CI のビルド環境にお手製のスクリプトを使いたかったんだけど、そんなすごいものでもないので PyPI にアップとか面倒だから、お手製の Docker Image を作って DockerHub に置くことにした。 GitLab Registry でもよかったんだけど、手癖でお手製スクリプトのリポジトリを GitHub に作ってしまったのでそうなった。

[![515hikaru/concatenate - GitHub](https://gh-card.dev/repos/515hikaru/concatenate.svg)](https://github.com/515hikaru/concatenate)

詳しい手順はググれば出てくるし、ググらなくても雰囲気でできる。

### いいところ

リポジトリ直下に `Dockerfile` をドンとおくだけなのでほとんど設定がいらない。簡単。設定もほとんど不要で、デフォルト設定で master に push すれば最新の latest が生成されるという形。 tag push したときに〜とかは設定が必要なんだろうけど、あまり詳しく調べていない。

### よくないところ

正直 GitLab Registry でいい。
