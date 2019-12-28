---
title: "Poetryについてもろもろ"
date: 2019-11-10T00:00:00+09:00
draft: false
tags: ["Python", "BuildTool", "OSS"]
---

最近の技術的な活動としては、Poetryのリポジトリからの通知にひたすら目を通すということをやっている。わたし自身はPoetryに結構期待をしていて、これからのPythonのプロジェクト管理のデファクトスタンダード的な立ち位置になってほしいと考えている。

<blockquote class="twitter-tweet"><p lang="ja" dir="ltr">そもそも俺が知ってるだけで<br>・virtualenv<br>・pyenv-virtualenv<br>・conda<br>・pipenv <br>・poetry<br>・dephell<br>・flit<br>くらいあっていや〜お腹いっぱいって感じだけどさ。。。</p>&mdash; 515ひかる (@515hikaru) <a href="https://twitter.com/515hikaru/status/1190964598964277249?ref_src=twsrc%5Etfw">November 3, 2019</a></blockquote> <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>
<blockquote class="twitter-tweet"><p lang="ja" dir="ltr">わたしは本命Poetry、大穴DepHellくらいの気持ちでBetしてます</p>&mdash; 515ひかる (@515hikaru) <a href="https://twitter.com/515hikaru/status/1190966298248769536?ref_src=twsrc%5Etfw">November 3, 2019</a></blockquote> <script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>

## Why Poetry?

なぜ Poetry なのか。いくつか理由がある。

* 依存関係の管理とパッケージングに関してのツールであり、その他の機能をなるべく持たない方針
    * Node.js の `npm` の npm-scripte のような機能を実装する提案があったが、[棄却されている](https://github.com/sdispater/poetry/pull/591#issuecomment-504762152)
* pyproject.toml など比較的最近採用された規格を利用しており、独自規格を利用していない
    * requirements.txt も setupy.py も同時に置き換えられている
* プロジェクト管理が Node.js でいう npm/yarn, Ruby でいう Bundler のような使用感が少しずつ実現されつつある（とわたしは感じる）

ちなみに [pyflow](https://github.com/David-OConnor/pyflow) というツールもあり、これにも少し未来を感じるけどまだ紹介するには時期尚早な感じがする[^1]。

[^1]: こちらも [PEP 518](https://www.python.org/dev/peps/pep-0518/) で制定された pyproject.toml に加えて、[PEP 582](https://www.python.org/dev/peps/pep-0582/)で制定された `__pypackages__` を採用するなど独自規格でなく、Python 公式が制定している規格の範囲内で実現しようとしているツールである。


## Why not Pipenv?

なぜ [Pipenv](https://github.com/pypa/pipenv) ではないのかについても簡単に書いておく。

* Pipfile は PEP で規格が規定されていない独自規格であり、実装が仕様という状態になっている
* requirements.txt を置き換えているのみで、setup.py のレイヤーはサポートしていない
* 2019年11月10日時点で最新リリースが[2018年11月26日版](https://github.com/pypa/pipenv/releases/tag/v2018.11.26)であり、リリースが停滞している状態にある
    * 最新版からmasterへのコミットは600コミット以上あるのにどういういこと

## 最近のPoetryの開発

最近の Poetry でわたしの興味の対象になっているトピックを書く。なおバージョンは 1.0.0b4 である。

### プロジェクトに使う Python を選べるようになった

`poetry env use ${Python処理系へのパス}` でそのプロジェクトに使う Python のバージョンを選べるようになった。もう 3.6 のプロジェクトで poetry を使うときは 3.6 に poetry をインストールし、 3.7 のプロジェクトで poetry を使うときは 3.7 にも poetry をインストールしないといけない、なんて面倒はしなくてよくなった。

### コマンドラインオプションのバグが直った

```
$ poetry run python --help
```

とやると、以前は `poetry run` の help が表示されてしまう[バグがあった](https://github.com/sdispater/poetry/issues/1500)。

しかし今は、`python --help` が表示されるように修正された。

## 終わりに

他にもいろいろ思っていることはあるのだけど、とりあえずここまで。

Poetry の PR は結構たまっていて、正直あまり見られていないような気がしている。もしかすると、 [1.0 マイルストーン](https://github.com/sdispater/poetry/milestone/1)にあるような Issue を優先的にしかかっているのかもしれない。

しかし GitHub は Git ホスティング、SNS というツールとしては安定性も高くいいと思うんだけど、プロジェクト管理にはとんと向いていない気がする。まぁ、「悪いほうが良い」のだろうか。
