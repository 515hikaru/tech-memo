---
title: "Python プロジェクトの依存関係を管理するツールありすぎるやろ"
date: 2019-10-19T02:26:35+09:00
draft: false
tags: ["Python", "Development Environment"]
---

## プロジェクト管理

最近は Python プロジェクトの依存関係の管理には Poetry を使っている。

[GitHub \- sdispater/poetry: Python dependency management and packaging made easy\.](https://github.com/sdispater/poetry)

理由はだいたい pyproject.toml にある。実は pyproject.toml は Poetry の専売特許 **ではなく**、そもそも [PEP で仕様が定められていて](https://www.python.org/dev/peps/pep-0518/)、pyproject.toml を使うパッケージ管理ツールを作るのは自由だ。例えば、 flit というものがあるらしい。わたしは使ったことがないけれど。

[GitHub \- takluyver/flit: Simplified packaging of Python modules](https://github.com/takluyver/flit)

JavaScript にも Yarn と NPM があるが、それらは同じ package.json というプロジェクトの設定ファイルを読む。だから Poetry と flit は Yarn と NPM と同じような関係にあると考えればいいと思う。

## ツールの乱立

一方で、この関係にないのが Pipenv だ。 Pipenv は Pipfile という pyproject.toml とは別の形式のファイルを読む。Pipenv が登場したときはこれでやっと大統一が図られるかと思ったけど、どうしてか Python はパッケージ管理の方法が乱立してしまう運命にあるらしい。他の言語でここまで乱立しているって正直聞いたことがないんだけど。

もう乱立しているのを諦めて、相互に変換できるようにしようというプロジェクトもある。 DepHell がそれだ。

[GitHub \- dephell/dephell: Python project management\. Manage packages: convert between formats, lock, install, resolve, isolate, test, build graph, show outdated, audit\. Manage venvs, build package, bump version\.](https://github.com/dephell/dephell)

例えば `requirements.txt` から `pyproject.toml` を作ることができる。逆もできる。自分のお好みのツールを使うことを阻害しない(DepHell doesn't try to replace your favorite tools)という上で All in one solution を目指しているらしい。ぶっちゃけどんなツールなのかイマイチわかっていないが、この間 pyproject.toml で管理しているのにどうしても setup.py が必要な状況があり[^1]、変換するためだけに使った。

[^1]: `pip install -e` をするために setup.py が必要だった。今も必要なのかはわからない。

## ちょっとはまとめてほしい

そんなこんなで色々あるんだけど、今回紹介していない Anaconda (`conda` コマンド)とか、古き良き `virtualenv` コマンド + requirements.txt とかも考えると本当にパッケージの管理するツールが多い。なんか考えるだけで疲れてくる。

せめて Yarn と NPM みたいに二大巨頭くらいになってくれないかなと思っている。無理か。
