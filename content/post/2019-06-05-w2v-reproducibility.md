---
title: "gensimのWord2Vecモデルで次元圧縮の再現性を確保する"
date: 2019-06-05T21:37:46+09:00
draft: false
tags: ["Machine Learning", "Data Preprocessing"]
---

乱数のシードを固定することで、毎回同じ乱数を生成し、内部で乱数は使っているけれども複数回実行しても毎回同じ結果を返すようにしたい、というニーズはあると思います。たとえば scikit-learn では乱数を固定したい場合インスタンス生成時や関数の利用時に `random_state` などのキーワード引数が用意されていて、その数字を整数値で固定すれば(同じシード値を使っている限り)同じ結果になります。

一方、gensimのword2vecを使ってみたトコロ、単に`seed`というキーワード引数に整数値を指定するだけでは、学習の再現性を担保することができなかったので少し調査をしました。

コードの docstring に全部やるべきことが書かれていたのでそれをそのまま引用します。

```
seed : int, optional
    Seed for the random number generator. Initial vectors for each word are seeded with a hash of
    the concatenation of word + `str(seed)`. Note that for a fully deterministically-reproducible run,
    you must also limit the model to a single worker thread (`workers=1`), to eliminate ordering jitter
    from OS thread scheduling. (In Python 3, reproducibility between interpreter launches also requires
    use of the `PYTHONHASHSEED` environment variable to control hash randomization).
```

`Note` 以降が重要で、2つの要素があります。

1. OSのスレッドの挙動に左右されないためにワーカーを1に制限する
2. Python3 の Hash 関数に使用される乱数の制御のために `PYTHONHASHSEED` を整数値で指定する

1 については特に言うことはないでしょう。並行実行をすると順序が実行するごとに前後することがあるため、並行実行させないようにということです。わたしが現在使っている文章数では `workers=1` に指定して致命的にパフォーマンスが落ちるといったことはないので、普通に指定しています。

2 のほうがわたしは知らなかったです。gensimのWord2VecはPython(3)のHash関数を利用しており、その乱数を制御するのは(おそらく)Pythonコードレベルではなくより低レベルなレイヤーで処理をしなければならないのでしょう。ということで `PYTHONHASHSEED=1 python foo.py` とかやるとこの Hash 関数も何度実行しても同じ結果を返すようになるはずです。

とりあえずこれで解決したのでわたしとしてはこれ以上クビをつっこむ気はないのですが、書きながらもう少し調べてもよかったかもなと思いました。
