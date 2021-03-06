---
title: "昨日は成功したビルドが今日は通らなかった"
date: 2019-01-16T22:30:09+09:00
draft: false
tags: ["Python", "Development Environment"]
---

世の中簡単なことばかりではないし、様々な依存関係により一部が崩壊すると芋づる式にほかの部分まで破壊されることがある。そして、それは予想もしない形で現れたりもする。

そんなわけで今日は昨日まで壊れていなかったものが、今朝になって壊れたので直すという仕事をしていた。

# 背景

- 問題が起きたのはPythonにより実装されているWebAPIサーバー
- パッケージの管理はCondaにより行っている
    - バージョン番号は `yaml` ファイルで固定
- 毎朝 docker build と各種テストを実施
- 昨日成功していたテストが今朝のビルドでは失敗していることに気づく

# 結論

- パッケージのバージョンは変わっていなかったが昨日から今日にかけてで**依存関係**が変わっておりAnacondaのC++関連のツール(特にコンパイラ)がインストールされた
- 昨日までOSのパッケージマネージャーでインストールされた `g++` でコンパイルしていたモジュールがAnacondaのC++のコンパイラでコンパイルされた
    - `PATH` を早い段階で `export` していたためAnaconda環境の実行ファイルが優先された[^1]
- 昨日とは別のコンパイラがツール(具体的にはMecab)をビルドした
- 昨日とビルド内容が異なり結合テストで失敗してしまった

なんでバージョン番号が変わっていないのに依存関係が変わるのか、本当にわからない。しかし現実には変わっていた。

[^1]: そもそもC++で書かれたツールをビルドするときに `$(conda info --root)/envs/env_name/bin` に `PATH` が通っていることがおかしい、というのはそれはそうなんだ。だけどまぁ、そこまで書いた人が考えなかったんだろう(あるいは興味がなかったのか)。

# 過程

この結論を得るまでの過程を簡単に書く。

## テストが失敗していることに気づく

朝起きてすぐにCIが失敗していることに気づいた。このときは詳細は追わず、どうせリトライすれば直るやろと思っていてあとでリトライしようと思っていた。

## ～午前いっぱい

午前中にどうも再現性があることを知る。自分の開発用のマシンでも再現したからだ。

再現条件をいろいろとチェックをした。マシンを変える、昨日ビルドしたコンテナを使うなど。そうすると昨日ビルドしたイメージ[^2]は成功し、今日ビルドしたイメージでは失敗するということがわかった。コードは昨日のビルド成功時点から一切変わっていないことを確認したので、docker build 中が怪しいのではないかと思い至る。

[^2]: Docker イメージ

docker build を昨日の成功したジョブと今朝の失敗したログで見比べると使っているコンパイラが変わっている部分があることに気づいた(ログをダンプして `diff` コマンドで比較したりテキストエディタで開いて見比べたりした)。ここで調査対象をDockerビルド中の依存関係に絞る。なんとなくAnacondaが怪しいと思う。

## 午後から夕方にかけて

昨日ビルドしたイメージを `pull` してきて、今日作ったイメージと中身を比べる。やはり昨日までは `$(conda info --root)/envs/env_name/bin` 配下にC++のコンパイラがない(今日の分にはある)。

ローカルの開発マシンで `conda env create --file conda_env.yaml` をし、自分のマシンにもC++のコンパイラがインストールされることを確かめる。

ということはC++のコンパイラをremoveすればすべて丸く収まるのではないかと思い、[ググって見つけたStackOverflowの質問](https://stackoverflow.com/questions/47804231/errors-appearing-in-terminal-after-updating-anaconda)を参考にコマンドをたたく。

```
$ conda remove gcc_linux-64 gcc_impl_linux-64 binutils_linux-64 binutils_impl_linux-64
```

するとほかに依存しているKerasは依存関係の都合で `REMOVE` されると警告をされ、NumPyなどはダウングレード[^3]される。なのでC++コンパイラのアンインストールは断念した。

[^3]: バージョン番号変わらないんだけど、なぜがダウングレードと言われた。

# まとめ

改めてまとめ。

- Anacondaのパッケージはバージョン番号を固定するだけじゃなくリビジョン番号まで指定しないと依存関係が変化することがあるようだ
    - 少なくともわたしは一度は経験した
- `PATH` を不用意に通すと依存関係が増えたことにより思いもよらぬところで影響を及ぼすことがある
- 昨日と今日の違いは、自分たちが作っていなくても他者と自分たちの意図しない共同作業で作ってしまうことがある

# 小言

Anacondaのパッケージレポジトリのバージョン管理方法がよくわからない。そもそもなぜバージョン番号は変わっていないのに依存関係を変えるのか。 `numpy==1.14.5=**` の `**` 部分の変更で依存関係の変更をするって結構大きな変更ではないか。

とかいろいろ思ったけどタダ乗りさせてもらっている身分なのであまり大きな声でも言えないな、という自覚がある。

事情がありAnaconda Cloudのパッケージを使わせてもらっているのだけど、やっぱりPyPIのほうがいいなと、わたしは改めて思った。