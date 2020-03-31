---
title: "pyproject.toml とは何か"
date: 2019-11-23T00:00:00+09:00
draft: false
tags: ["Python", "Poetry"]
---

# TL;DR

* pyproject.toml は PEP で提案されているパッケージのビルドに必要なデータを定義するファイルのフォーマット
    * setup.py や setup.cfg の機能を代替し、setuptools 以外のビルドツールを指定できるファイルとして提案
* ツールの設定を書くファイルとして pyproject.toml に対応するケースが増えつつある
* pyproject.toml がプロジェクト管理においてどのような役割を持つのかはそのプロジェクトが採用しているツール次第
* 状況に合わせてpyproject.tomlを使うべきか判断をしていくしかない

# Poetry の隆盛と pyproject.toml

しばらく前から [Poetry](https://github.com/sdispater/poetry) の名前をよく聞くようになりました。プロジェクトのパッケージの依存関係や、そのプロジェクトのPython実行環境を管理するツールです。Node.js でいう `npm` あるいは `yarn` コマンドのような、Ruby でいう `bundle` コマンドのようなツールです。

Poetry はたとえば `poetry new` などとしてプロジェクトの管理をする pyproject.toml という名前のファイルを作成し、そこに依存関係を記述します。では pyproject.toml という名前は Poetry の作者が名付けたのかと言うと、決してそうではありません[^2]。pyproject.toml はそもそも[PEP 518 \-\- Specifying Minimum Build System Requirements for Python Projects](https://www.python.org/dev/peps/pep-0518/#specification)[^1] で提案されているファイル名とフォーマットになります。なので、Poetry 以外のツールが pyproject.toml にかかれている設定を読み込むことも想定されています[^3]。

[^2]: わたしが知らないだけで PEP 518 の策定への議論に Poetry の作者が関わっている可能性は 0 ではないですが、そこまで調べられてはいません。

[^1]: PEP というのは Python の言語仕様やエコシステムへの提案や議論のまとめです。

[^3]: 使っている人にとっては何を当たり前な、と思うことかもしれません。しかし、Qiita で試しに "pyproject.toml" で検索してみたところ 8 件しかヒットしませんでした（Poetry は38件です）。まだそこまで知られているものではないと判断して書いています。

この記事では pyproject.toml が誕生した歴史については記述せず[^4]、現在どのようなツールが pyproject.toml に対応しているのかなどを書きます。もし pyproject.toml の経緯について知りたければ、下記の記事などが参考になると思います。

[^4]: Python のパッケージングの歴史は複雑で難解なのでわたしの経験では手に余ります。

* [Pythonとパッケージングと私](https://www.slideshare.net/aodag/python-79546865)
* [wheelのありがたさとAnacondaへの要望 \- YAMAGUCHI::weblog](https://ymotongpoo.hatenablog.com/entry/2017/02/02/182647)

# pyproject.toml を利用しているツール

pyproject.toml でそのプロジェクトの設定を書けるツールはいくつもあります。 Poetry のように、依存関係管理のツールが目立ちますが、それ以外のツールでも使えます。

## プロジェクトの依存関係管理・パッケージのビルドに関するツール

各種ツールの細かい思想や使いかたなどの話はしません。こんなツールもあるんだなと思っていただければ。

### [setuptools](https://github.com/pypa/setuptools)

デフォルトのツールです。setup.py を書くときに利用していると思います。最近は pyproject.toml のみで [pip によるインストールが可能](http://orolog.hatenablog.jp/entry/2019/03/24/223531)になったようです。

### [Poetry](https://github.com/sdispater/poetry)

冒頭にも話題に出した Poetry です。Poetry は pyproject.toml のみで依存関係の管理とパッケージのビルドを完結させるツールです。下記は README からの引用です。

> poetry is a tool to handle dependency installation as well as building and packaging of Python packages. It only needs one file to do all of that: the new, standardized pyproject.toml.
> In other words, poetry uses pyproject.toml to replace setup.py, requirements.txt, setup.cfg, MANIFEST.in and the newly added Pipfile.

pyproject.toml の tool セクションをフル活用して依存関係の整理、エントリーポイントの指定などを行うことができます。まだ 1.0 がリリースされていない（そしてまだ時間はかかりそう）ですが、堅実に開発を進めている印象です。

### [Flit](https://github.com/takluyver/flit)

Poetry と同じくビルドツールですが、かなり機能を省いています。例えば、 Poetry は `poetry add numpy` とすれば pyproject.toml に勝手に依存パッケージとして記述してくれますが、 Flit は pyproject.toml を手で編集する必要があります。

パッケージのビルドをするための最小限の機能を備えているツールなので、特に設定することや学ぶことも少なくて楽と感じる人もいるかもしれません。

### [DepHell](https://github.com/dephell/dephell)

DepHell は DepHell 自体にも仮想環境の構築などの機能を持ちながら、プロジェクトの管理方法を変換する機能も持っているツールです。例えば、requirements.txt と venv を使うことを前提にしていたプロジェクトで、 requirements.txt から pyproject.toml を作ったり、pyproject.toml から setup.py を作ったりすることができます。

最近は減ってきたとはいえ、たまに setup.py をどうしても書かなきゃいけないときがあるので、そういうときにわたしは重宝しています。便利なツールです。

### [Pyflow](https://github.com/David-OConnor/pyflow)

Rust 製の Python パッケージの依存管理ツールです。PEP 518 に加えてまだ Draft の [PEP 582](https://www.python.org/dev/peps/pep-0582/) も実装している意欲的な新興ツールです。正直使用感はそこまで把握できていませんが、こんなのもあるよということで。

## それ以外のツール

別に依存関係を管理するツールでなくても使えます。setup.cfg などに設定を書けるツールは、pyproject.toml の設定を読み込めるように対応しているものがあります。

有名なのはフォーマッタの [black](https://github.com/psf/black) でしょう。例えば、下記のような設定をすると black でフォーマットした Python コードの最大行長が 80 文字になります。

```toml:pyproject.toml
[tool.black]
line-length = 80
```

他にも [isort](https://github.com/timothycrosley/isort/issues/705) もフォーマット設定を pyproject.toml に書くことができます。

わたしは設定したことはありませんが、 [pylint は対応している](https://github.com/PyCQA/pylint/issues/617)ようです。 [flake8 はできていなさそう](https://gitlab.com/pycqa/flake8/issues/428)な雰囲気です。ほかのツールがどんな対応状況なのかは、例えば[この Issue](https://github.com/PyCQA/bandit/issues/550) のリンクからみることができます。

# pyproject.toml の書き方

さて、pyproject.toml に設定を書けるツールをいくつか見てきました。では pyproject.toml の書き方で標準的なものがあるのかというと、実はありません。ツールによってまちまちです。なので書き方は都度学ぶしかない、というのが回答になります。

## Poetry と Flit の比較

上に結論を書いてしまいましたが、例がないと実感がわかないかもしれません。どれほど違うものなのか1例を見てみましょう。

たとえば、 Poetry は依存関係を以下のように書きます。

```toml:pyproject.toml(Poetry)
[tool.poetry.dependencies]
python = "~2.7 || ^3.4"
cleo = "^0.7.6"
```

`tool.poetry.dependencies` セクションを作ってパッケージ名を key に、バージョン番号を value にしているわけです。

しかし Flit は下記のように依存関係をかきます。

```toml:pyproject.toml(Flit)
[tool.flit.metadata]
requires=[
    "flit_core>=2.0rc2",
    "requests",
    "docutils",
    "pytoml",
    "zipfile36; python_version in '3.3 3.4 3.5'",
]
requires-python=">=3.5"
```

Poetry とは全く違います。まずセクションではなく `requires` key ですし、その value はバージョン番号ではなく パッケージ名とバージョン番号の文字列の配列です。

同じ機能であってもツールごとによってどのように記述するのかは違います。なので、 pyproject.toml にどのように設定を書けばよいかは、そのツールのドキュメントを読みに行くしかありません。`tool` セクション配下は、同じファイルに設定を書くからと言って標準的なルールやガイドラインは現在は存在していません。

# まとめ

pyproject.toml は Node.js の package.json などのように、そのプロジェクトに関する様々なことを定義できるファイルとして存在しています。しかし現時点では pyproject.toml で何を設定できるのかは、そのプロジェクトがなんのツールを使っているのかに依存する、という状態になっています。Poetry で管理しているのであれば、pyproject.toml はビルドの依存関係やエントリーポイント、パッケージのメタ情報を管理するファイルになります。Poetry などは使わず、ただそのプロジェクトにおける black フォーマッタの設定だけを書くという使い方もできます。

対応しているツールは増えてきているとはいえ、まだまだ対応できていないツールもありますし、何より pyproject.toml にすべての設定を集約することで、本当にユーザーが嬉しいのかも疑問です[^5]。ここまで書いておいてなんですが、何がなんでも pyproject.toml を使うべきだとはわたしも思っていません。その存在を正しく認知し、そのプロジェクトと使いたいツールに合った設定ファイルを選択するべきだと思います。

[^5]: [このような意見](https://github.com/pytest-dev/pytest/issues/1556#issuecomment-219635007)もありますし、至極最もだと思います。Poetry のように pyproject.toml に多大な書き込みをするツールを使う場合は特にファイルの肥大は気になると思いますし、むしろ pyproject.toml は Poetry の設定を書くファイルと割り切るという判断もあるでしょう。
