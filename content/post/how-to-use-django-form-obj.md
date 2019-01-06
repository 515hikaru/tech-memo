---
title: "DjangoのFormオブジェクトの使い方Tips"
date: 2017-12-28T00:00:00+09:00
draft: false
tags: ["Python", "Django", "Web App"]
---

# Django とは

[Django](https://www.djangoproject.com/) とは, Python の Web フレームワークです. Ruby でいうところの Rails [^1]に相当するフレームワークで, Git ホスティングサービスの[Bitbucket](bitbucket.org) や最近「インスタ映え」で話題の Instagram にも利用されています[^2].

[^1]: 実は Rails 使ったことないんですが.

[^2]: 出展: http://djangoproject.jp/whouses/

この記事を書いている人も Django を使って Web アプリを作ったり作らなかったりしています.

<!-- more -->

# Form オブジェクト

Django には当然いくつもの機能があるのですが, 筆者が一番ググるのが表題の Form オブジェクトについてです.

Form オブジェクトは, 処理をするのに必要十分なデータが含まれているか, 不適切なデータが入っていないかをチェック(Validation)したり, HTML を自動生成したり, データベースの定義から Form を生成したりといろんなことができます.

いろんなことができるので, こういうことできないかな? と思った時に StackOverflow をたくさん漁るのは僕だけではないはず...

そんなわけで今まで StackOverflow で得てきた知見のいくつかを書いておくことにしました. 体系的な解説というよりは, Tips 寄せ集めとして, やりたいこととその方法を書いていく感じです.

#### Form のフィールドを可変にしたい

複数入力可能なフィールドを作りたいことはよくあるでしょう. クラス変数を動的に増やせばいいのでコンストラクタで増やします.

以下は `value_i` という名前のフィールドを可変にする方法です.

```python
from django import forms

class SampleForm(forms.Form):

  def __init__(self, num, *args, **kwargs):
    super().__init__(*args, **kwargs)
    for i in range(num):
      self['value_{}'.format(i)] = forms.IntegerField(...)
      # ...
```

これで `num` 個 `value` のフィールドができます.

#### Form の type 要素を指定したい

Form オブジェクトの定義で指定できます. 例えば, HTML では隠したい要素は, `forms.SomeField(widget=forms.HiddenInput)` などとするだけです.

他にも, `forms.RadioSelect`, `forms.CheckboxInput` など, HTML の様々な要素に指定できます.

#### Form の初期化をしたい

コンストラクタに `initial` キーワード引数で辞書を渡せば初期化できます. `foo` と `bar` をフィールドに持つ Form オブジェクトなら,

```python
...
form = SomeForm(initial={'foo': some_value, 'bar': some_value})
```

とします. 初期値を完全に固定したい場合は, フォームの定義の時点で初期化する方法もあります.

```python
from django import forms

class SampleForm(forms.Form):
  foo = forms.IntegerField(initial=10)

```

他にも, コンストラクタの中で `self['foo'].initial = 10` などとするやり方もありますが, 若干正攻法ではない気がします[^3].

[^3]: 根拠はない.

#### このオブジェクトにどんなメソッドがあるか知りたい

これは Form オブジェクトに限った話でないどころか, Python 全般に通じる話ですが, `dir()` という組み込み関数があります. `dir(foo)` は `foo` が参照しているオブジェクトの属性をすべて表示する関数です.

例えば, 次のような出力が得られます.

```
>>> dir(1)

['__abs__', '__add__', '__and__', '__bool__', '__ceil__', '__class__', '__delattr__', '__dir__', '__divmod__', '__doc__', '__eq__', '__float__', '__floor__', '__floordiv__', '__format__', '__ge__', '__getattribute__', '__getnewargs__', '__gt__', '__hash__', '__index__', '__init__', '__init_subclass__', '__int__', '__invert__', '__le__', '__lshift__', '__lt__', '__mod__', '__mul__', '__ne__', '__neg__', '__new__', '__or__', '__pos__', '__pow__', '__radd__', '__rand__', '__rdivmod__', '__reduce__', '__reduce_ex__', '__repr__', '__rfloordiv__', '__rlshift__', '__rmod__', '__rmul__', '__ror__', '__round__', '__rpow__', '__rrshift__', '__rshift__', '__rsub__', '__rtruediv__', '__rxor__', '__setattr__', '__sizeof__', '__str__', '__sub__', '__subclasshook__', '__truediv__', '__trunc__', '__xor__', 'bit_length', 'conjugate', 'denominator', 'from_bytes', 'imag', 'numerator', 'real', 'to_bytes']

>>> dir('a')

['__add__', '__class__', '__contains__', '__delattr__', '__dir__', '__doc__', '__eq__', '__format__', '__ge__', '__getattribute__', '__getitem__', '__getnewargs__', '__gt__', '__hash__', '__init__', '__init_subclass__', '__iter__', '__le__', '__len__', '__lt__', '__mod__', '__mul__', '__ne__', '__new__', '__reduce__', '__reduce_ex__', '__repr__', '__rmod__', '__rmul__', '__setattr__', '__sizeof__', '__str__', '__subclasshook__', 'capitalize', 'casefold', 'center', 'count', 'encode', 'endswith', 'expandtabs', 'find', 'format', 'format_map', 'index', 'isalnum', 'isalpha', 'isdecimal', 'isdigit', 'isidentifier', 'islower', 'isnumeric', 'isprintable', 'isspace', 'istitle', 'isupper', 'join', 'ljust', 'lower', 'lstrip', 'maketrans', 'partition', 'replace', 'rfind', 'rindex', 'rjust', 'rpartition', 'rsplit', 'rstrip', 'split', 'splitlines', 'startswith', 'strip', 'swapcase', 'title', 'translate', 'upper', 'zfill']

>>> class Foo():

...  foo = 1

... 

>>> f = Foo()

>>> dir(f)

['__class__', '__delattr__', '__dict__', '__dir__', '__doc__', '__eq__', '__format__', '__ge__', '__getattribute__', '__gt__', '__hash__', '__init__', '__init_subclass__', '__le__', '__lt__', '__module__', '__ne__', '__new__', '__reduce__', '__reduce_ex__', '__repr__', '__setattr__', '__sizeof__', '__str__', '__subclasshook__', '__weakref__', 'foo']
```

これを利用して, どんなメソッドがあるのか調べることができます. 特に Form オブジェクトは覚えきれないくらいメソッドがあるので, `python manage.py shell` で自分で定義した Form オブジェクトを呼び, `dir()` 関数を使ってどのメソッドが何を返すか色々と調べてみるといいと思います.

### あとがき

意外と Form オブジェクトに絞ると, その時は問題解決に一生懸命になっているので色々と解決策を考えるんですが, あとからまとめようとすると意外と数がすくないことがわかりました.

他にも, モデル定義がらみでは

- モデル定義からフォームを自動生成する
- モデル定義から作ったフォームから, モデルをデータベースに登録する
- モデルを初期化データに使う

などがパッと思い浮かびます. 全部 StackOverflow に書いてあったような.

あと,

- `forms.RadioSelect` などは `subwidget` 内のメソッドを探索することで HTML の小細工がしやすくなる

というのが最近の発見です. これは Django 1.11 系統以降じゃないと使えないかもしれません(未確認ですが, 1.10では使えなかったので).

自分の復習にもなるし, ちまちまとこういう記事を書いていきたいと思いつつなかなか手が動かない1年でした.
