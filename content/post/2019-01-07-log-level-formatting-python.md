---
title: "Python のログ出力における文字列フォーマット"
date: 2019-01-06T22:03:38+09:00
draft: false
tags: ["Python"]
---

# 背景

デバッグログとかで、

```python
log.debug('foo = {}'.format(foo))
```

と書くことがあると思う。これについて Pylint が

```
W1202: Use % formatting in logging functions and pass the % parameters as arguments
```

と警告(Conventionではない)を出してくるのが気になっていた。[このStackoverflow](https://stackoverflow.com/questions/34619790/pylint-message-logging-format-interpolation)によれば、

```python
log.debug('foo = %s', foo)
```

と書けば良いようだが[^1]、なぜ警告を出してまでこれに統一したいのかがわからない。ので調べた。

[^1]: `"foo = %s" % foo` という %記法ではないことに注意。メソッドでも % 演算子でもなく、引数の区切り(`,`)である。

# .format() と % フォーマットの違い

Pylint にこの Warning が追加されたときの[プルリクエスト](https://bitbucket.org/logilab/pylint/pull-requests/169/add-new-warning-logging-format/diff)を見ると[^2]、

[^2]: Pylint って昔は BitBuclet 管理だったんだという気持ち。いまは [GitHub に移行した](https://github.com/PyCQA/pylint)らしい。

> Because the message will be evaluated (interpolated), even if the message will not be logged, due to a different warning level set. For instance, the following is always better than using .format.

とある。たとえば、 INFO 以上のレベルのログを表示する設定をしていたとき、 DEBUG レベルのログは「文字列の評価をするが表示はしない」という処理をする。ここで、

```python
log.debug('foo = {}'.format(foo))
```

のケースだと、 

* `"foo = ${foo}"` という文字列を作成
* ログレベルが低いので表示はしない
 
という処理の順番になる。これが % formatting: すなわち

```python
log.debug('foo = %s', foo)
```

のケースの場合は

* "foo = %s" という文字列のまま一旦放置
* ログレベルが低いので表示しない
* 文字列は評価しないまま次の行に行く

という処理になる。

今の場合、単に `foo` という変数を評価するだけなのでコストは低いが、これが `"foo = {}".format(too_expensive_func())` だと表示しない文字列を作るのに大きなコストを払ってしまう、というわけ。

# 結論

* logging で文字列をフォーマットするときは `%` フォーマットを使用するのが基本正しい
    * ただし `.format()` の functional な部分は使えない
* とはいっても PEP とかに明示的に書いてあるわけではない
