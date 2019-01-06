---
title: "Pytestの簡単なTips"
date: 2018-10-14T21:09:09+09:00
draft: false
categories: ["Python", "Testing"]
---

# Pytest の Tips

完全に自分用メモレベルで書いておく。普段開発をしていて、こういうことできないかな、と思ったことを調べた結果をまとめておくだけ。


# 特定のテストクラスのみ実行したい

普段 `unittest` ベースのテストの書き方をしているので、テストメソッドはクラスに属している。なのでこのクラスのテストのみ実行したいことはたまにある。これはコマンドラインからクラスを指定するだけでいい。

たとえば、次のようなテストファイル `test_file.py` という名前で存在しているとしよう。

```python
import unittest

class TestFoo(unittest.TestCase):
    def test_foo(self):
        self.assertEqual(1, 1)

class TestBar(unittest.TestCase):
    def test_bar(self):
        self.assertEqual(1, 1)
```

このとき、次のようにクラスを `test_file.py::<class_name>` という形で指定すれば指定のクラスのテストだけ実施できる。

```
$ pytest path/to/test_file.py::TestFoo
```

上の例の場合は `TestFoo` に属している `test_foo` メソッドで定義されているテストのみ実行される。


# 特定のメソッドのみ実行したい

ひとつのクラスに複数のテストが存在していて、だいたいひとつ失敗すると全部失敗する(そして失敗するのも成功するのもそれなりに時間がかかる)ので、成功するか失敗するのかわからない場合はひとつだけ実行したい、という状況があった。

こんなときは `mark` をつける。テストファイルを下記のように用意をする。


```python
import unittest

import pytest

class TestFoo(unittest.TestCase):
    def test_foo(self):
        self.assertEqual(1, 1)

    @pytest.mark.foo
    def test_foo2(self):
        self.assertEqual(2, 2)

class TestBar(unittest.TestCase):
    def test_bar(self):
        self.assertEqual(1, 1)
```

この `@pytest.mark.foo` で `foo` というマークがついた状態になっている。`pytest` コマンドの `-m` オプションでこの `foo` マークを指定する。

```
$ pytest -m foo test_file.py
============================================================ test session starts ============================================================
platform darwin -- Python 3.6.5, pytest-3.8.1, py-1.6.0, pluggy-0.7.1
rootdir: /Users/hikaru/blogs/tech-memo, inifile:
collected 3 items / 2 deselected

hoge.py .                                                                                                                             [100%]

================================================== 1 passed, 2 deselected in 0.02 seconds ===================================================
```

この `collected 3 items / 2 deselected` のように、 1 つだけが選択される。つまりこの `foo` マークがついているテストのみが実行されたことになる。

ちなみにクラスをまたいでも、同じマーク(ここでは `foo`)をつければ同時に実行できる。


# Warning summary を消す

Warning は基本消すべきではないが、ものによっては大量の警告が出てエラーの内容がわからないほど出てしまうこともある。

ということで Warning Summary を出さないようにしたいが、これは `-p no:warnings` オプションを指定すればよい。

```
$ pytest -p no:warnings path/to/test_file.py
```

# 参考

* [Warnings Capture — pytest documentation](https://docs.pytest.org/en/latest/warnings.html)
* [python \- How to test single file under pytest \- Stack Overflow](https://stackoverflow.com/questions/34833327/how-to-test-single-file-under-pytest/34833355)
