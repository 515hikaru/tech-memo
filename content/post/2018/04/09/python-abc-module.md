---
title: "Abstract Base Classes with Python"
date: 2018-04-09T22:31:49+09:00
draft: false
categories: ["Python", "ProgrammingTips"]
---

最近は Java っぽい Python を書いている。いや、僕は Java を書いたことがないので本当に Java っぽいのかはよくわからないのだけれど。

そんなわけで、 `class` の使い方について最近学びが多い。 Effective Python で読んだメタクラスとかが早くも役に立っている。ということで今日は抽象クラスの使い方なんかをまとめておく。

# abc モジュール

abc って言われた時、「アルファベットの最初の3文字がどうかした?」と思ったけれど、これは "Abstract Base Classes" の略。日本語にすると抽象基底クラス。

いつも使えるわけではないが、


- 類似の処理をするクラス群がある
- クラスごとに固有のメソッドと共通のメソッドがある

という状況下において威力を発揮する。具体的には、

- 共通のメソッド及びパブリックメソッドは統一して抽象基底クラスで定義
    - 各種クラスは抽象基底クラスを継承して固有のメソッドのみを実装する

とすることでクラスが増えても固有のメソッドにのみ注力すればよい。

以下に具体例を用いてどんな利点があるのかを書くが、正確なことは[公式ドキュメントを見るべき](https://docs.python.jp/3/library/abc.html)だ。この記事書く必要なくない?

# 具体例

## 動物を鳴かせる

たとえばよくある例で `Dog` というクラスに鳴く(`bark`)というメソッドを定義することを考える[^1]。

[^1]: `@staticmethod` デコレータとかつけろよ、と怒らないでください。。。今の場合はつけるべきなのかもしれませんが、ここに書いているのは雑なコードなので。

```python
class Dog(object):
    def bark(self):
        print('わんわん')
```

こんなふうに定義して使っていたところ、動物は犬だけじゃなく猫も必要だということがわかった。ということで猫も定義しよう。

```python
class Cat(object):
    def meow(self):
        print('にゃー')
```

### この実装の問題

とここで次のようなユースケースで早速困る。

```python
def make_sound(animal):
    animal.bark()  # animal が Dog だったらOK, Cat だったらエラー
```

ということで、動物の鳴き声メソッドは統一するべきだとわかる。ここでは `sound` としよう。

## 複数のクラスのメソッドを統一

以下のように `Dog` と `Cat` を定義し直す。

```python
class Dog(object):
    def sound(self):
        print('わんわん')

class Cat(object):
    def sound(self):
        print('にゃー')
```

この実装だと上の `make_sound` 関数は下記の実装にすれば問題なく動く。

```python
def make_sound(animal):
    animal.sound()
```

## 他の動作を追加

しかし、動物は鳴く以外の動作もする。例えば、「走る」を実装しよう。といっても、本当に走らせるのではなくここでは文字を `print` するだけにする。

```python
class Dog(object):
    def sound(self):
        print('わんわん')
    def run(self):
      print('スタタタタ')

class Cat(object):
    def sound(self):
        print('にゃー')
    def run(self):
        print('スタタタタ')
```

おや? 犬も猫も走り方は一緒なのか音が同じだ[^2]。メソッドが同じになってしまった。

[^2]: ということにしておいてください。お願いします。

## 動物の追加

さらにここに、猿を加えなくてはならなくなった。そして猿は "ウキー" と鳴いて、"スタタタタ" と走る(としよう)。つまり `run` メソッドは3つのクラスにおいて共通のメソッドで、 `sound` は名前は同じだが実装は異なるメソッドになる。

こういう状況において、 `abc` モジュールを使ってみよう(やっと本題か。。。)

## abc モジュールを利用した実装

まず、 `Animal` という抽象クラスを作る。「動物」という名詞はあるが、「動物」という動物はいない。なので動物はインスタンス化させない。一方でここで考慮している動物は「鳴く」ことと「走る」ことはする。

なので、次のような実装にしよう。

```python

from abc import ABCMeta, abstractmethod

class Animal(object, metaclass=ABCMeta):
    @abstractmethod
    def sound(self):
      pass
    def run(self):
      print('スタタタタ')
```

こうすることで、まずインスタンス化できないクラスができた。

```python
Animal()  # =>TypeError: Can't instantiate abstract class Animal with abstract methods sound
```

次に `Monkey` を実装しよう。しかし筆者はうっかり `Monkey` の `sound` メソッドを実装し忘れてしまった。

```python
class Monkey(Animal):
    pass
```

このインスタンス化も失敗する。

```python
Monkey()  # => TypeError: Can't instantiate abstract class Monkey with abstract methods sound
```

`@abstractmethod` としているので、 `sound` メソッドが定義されていない場合エラーが発生する。定義していないと失敗するので `sound` メソッドを定義し忘れる心配がない[^3]。

[^3]: 欲を言えばインスタンス化じゃなく定義時にエラーが発生して欲しいと少し思うが、そこまで調べられていない。

さて、うっかりミスを Python に教えてもらったのでミスを正そう。

```python
class Monkey(Animal):
    def sound(self):
        print('ウキー')

Monkey().run()  # => スタタタタ
Monkey().sound()  # => ウキー
```

これで `Dog` や `Cat` も `Animal` を継承するようにすれば、全部の動物に `sound` メソッドと `run` メソッドが定義されている状態が保証できる。

```python
class Dog(Animal):
    def sound(self):
        print('わんわん')

class Cat(Animal):
    def sound(self):
        print('にゃー')
```

なお、ここで例えば `Dog` だから `bark()` とメソッド名を誤ってしまっても、やはりインスタンス化に失敗するので気付ける。

# 注意

ここでは動物の共通メソッドして `run` を例に挙げたが、実際には走らない動物が居たりするように、「本当に今後も作成するクラスについても共通のメソッドなのか」あるいは「今後作成するクラスについても共通の実装なのか」ということは常に念頭に置きたい。「なんかこの2つ一緒っぽいから共通化しようぜ」という雑い考えでやると痛い目を見る(見たことがある)。

ちなみに筆者はこれをデータを取得するクラス(データソースが MySQL になったり CSV になったり JSON になったりするが、最終的に `obj.load()` で `pandas.DataFrame` が帰ってくるようにしたい)においてこの実装を行った。データを取得し DataFrame にするまでが固有のメソッドで、 DataFrame にしたあとの処理が共通のメソッドになる。

# まとめ

- 抽象基底クラスというものがある
- クラスの定義に制限をかけることでインターフェースを統一できる
- 「共通メソッド」がある前提
    - その共通メソッドは本当に今後も共通なのか?

# 実行環境

- macOS High Sierra
- Python 3.6.5
