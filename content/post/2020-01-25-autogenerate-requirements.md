---
title: "requirements.txtの自動生成 〜Pythonスクリプトから依存パッケージを抽出する〜"
date: 2020-01-25T00:00:00+09:00
draft: false
tags: ["Python", "DepHell"]
---

# この記事の概要

- `dephell` コマンドを使うと Python パッケージの依存関係記述ファイルの相互変換ができる
  - setup.py から requirements.txt を作るとか
- プロジェクトの Python パッケージの `import` を読み取って適切なフォーマットに変換できる
- 依存関係が掲載されていないプロジェクトでも使えるのでオススメ

# はじめに

データの前処理や可視化はどうやったの？みたいな話で Jupyter Notebook が残っているけど、特に requirements.txt とか setup.py が残ってない、みたいなケースがままあると思います。

もはや依存関係のバージョンの同定は不可能ですし、ほとんどの場合システムに組み込むとかしないので「動けばいい（再現すればいい）」のですが、そもそも動かすために依存するライブラリの一覧を作るのが一苦労です。ノートブックを開いて[^1]、import 文からサードパーティのライブラリを特定して、requirements.txt を作る単純作業になります。

[^1]: ほとんどの場合、ノートは 1 つではなく複数でしょう。

そんなつまらない作業、自動化したいよな〜思うことでしょう。そんなときに使えるのが[DepHell](https://github.com/dephell/dephell)です。下記 1 コマンドだけで、スクリプトの import 文から requirements.txt を作ってくれます。

```
$ dephell deps convert --from=imports --to=requirements.txt
```

# 実施手順

下記プロジェクトを例に説明します。

[515hikaru/create\-requirement\-from\-imports](https://github.com/515hikaru/create-requirement-from-imports)

上記リポジトリにはサンプルとして[僕がなんとなく書いた](https://github.com/515hikaru/create-requirement-from-imports/blob/master/notebook/load_data.ipynb)ノートブックが置いてあります。このサンプルでは下記のように import をしています。

- 先頭のセルで pandas の import
- 関数内で matplotlib の import（動的インポート）
- ノートの後半で PyTorch(torch)と sklearn の import

もちろん（？）プロジェクトには requirements.txt もなんにもありません。この状態から、requirements.txt を作ります。

## DepHell のインストール

まずはコマンドをインストールしましょう。Python3.6 以上が必要です。公式のインストール方法に従います。

```
curl -L dephell.org/install | python3
```

ちなみに現時点では Windows はサポートできていないようです[^2]。

[^2]: https://github.com/dephell/dephell/issues/343

## Jupyter Notebook をスクリプトに変換

.ipynb ファイルは `jupyter nbconvert` コマンドで Python スクリプト形式に変換できます。もちろん、ブラウザでダウンロードする方法もありますが、たくさんノートブックがあるときはコマンドの方が楽に変換できるでしょう。

```
$ jupyter nbconvert --to script notebook/load_data.ipynb
```

これで notebook/load_data.py ができるはずです。

## いざ変換

変換する前に、Python のパッケージであることを示すために `__init__.py` を置く必要があります。

```
$ touch notebook/__init__.py
```

あとは変換コマンドを実行するだけです。

```
$ dephell deps convert --from imports --to requirements.txt
$ cat requirements.txt
matplotlib
pandas
scikit-learn
torch
```

ノートブックに登場していたすべての外部パッケージがリストアップされました。

あとはバージョンを固定するなり、このままリポジトリに add するなり、好きにしましょう。

# 終わりに

サンプルはたった 4 つだったので手動でやってもたかが知れていますが、実際の現場では複数のモジュールを使っていたりしてあとから全容を把握するのは結構大変ということはあると思います。

DepHell が依存関係の記述の一助になれば幸いです。
