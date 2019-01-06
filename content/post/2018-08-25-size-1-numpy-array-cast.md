---
title: "numpyの配列のキャスト"
date: 2018-08-25T01:08:04+09:00
draft: false
tags: ["Python", "NumPy"]
---

# 検証環境

- Python 3.6.5
- NumPy: 1.15.1

なおいずれのコードも `import numpy as np` をしていることを前提に書いている。

# 本題

驚いた話。1次元配列を適当に用意する。

```python
>>> a = np.array([1])
True
>>> a.shape == (1, )
True
```

これをてきとうに `float` とかにキャストしてみる。

```python
>>> float(a)
1.0
```

... ん？

```python
>>> type(float(a))
<class 'float'>
>>> type(a)
<class 'numpy.ndarray'>
```

なんと `numpy.ndarray` 型(配列)だった `a`  が `float` でキャストすることで Python の `float` 型になっている。

では、多次元配列だとどうなるのだろうか。

```python
>>> b = np.array([1, 2])
>>> b.shape
(2,)
>>> float(b)
Traceback (most recent call last):
  File "<stdin>", line 1, in <module>
TypeError: only size-1 arrays can be converted to Python scalars
```

エラーになった。ご丁寧に、Python のスカラーに変換するのはサイズが1の配列である必要があるとのエラーメッセージも残して。

ということは `[[1]]` というのもキャストできるのだろう。実際、

```python
>>> c = np.array([[1]])
>>> c
array([[1]])
>>> c.shape
(1, 1)
>>> c.size
1
>>> float(c)
1.0
```

となった。

# わかること

- NumPy の配列は **サイズが1の場合のみ** `int` や `float` により **Python の数値型** にキャストできる上にその結果は Python の数値型
- NumPy の配列は **サイズが1でない場合** 数値型へのキャストはできない
    - 型には **サイズの情報がないにもかかわらず** サイズの違いで `TypeError` が送出されるかが変わる

ちなみに 0 次元配列とかいうさらにアレなやつもあるみたいです。Twitterで雑につぶやいていたら教えてくれました。こちらについては使ったことがないのでノーコメント。

直感的に考えると(0次元配列はわからないけれど) サイズが 1 か 1でないかで挙動が変わるのはおかしい気がしてならない。どうしてこんな仕様なんだろうか。わたしは NumPy のことがよくわからない(あまり使っていないので当然)。

# ちなみに

`str` でキャストしてみた。

```python
>>> a = np.array([3])
>>> float(a)
3.0
>>> str(a)
'[3]'
```

あ、 `str` かけるとちゃんと配列っぽいのね。そうなのね。。。もう勘弁してくれ。。。。
