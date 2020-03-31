---
title: "Emacsのlsp-mode使ってPythonの開発環境を構築した"
date: 2019-01-06T00:00:00+09:00
draft: false
tags: ["Emacs", "Anaconda", "Python"]
---

Emacs の Python の開発環境をググってみたけれど、自分向けの記事がなかったので自分向けの環境を自分で作ったという記事です。

# 前提

* OS: macOS 10.14
* Python の環境: Miniconda
    * `~/miniconda3` 配下にインストールしている
* 仮想環境の切り分けは `conda` で実施している
* Emacs: Homebrew Cask の Emacs

```console
$ brew cask install emacs
```

# やること

目標は自分が VSCode を使うときに利用している機能はすべて Emacs でも行えるようにすること。

* コードの補完
* Lint
* フォーマット
* 定義ジャンプ(今回は対象外)

よく知らないけど Language Server Protocol ってやつでなんとかなるんじゃないかな、と思ったので、 LSP を試すことにした。

# Python Language Server のインストール

[palantir/python\-language\-server: An implementation of the Language Server Protocol for Python](https://github.com/palantir/python-language-server) を利用する。

base 環境で下記コマンドを実行した。今回はコードフォーマッタに [black](https://github.com/ambv/black)も利用してみたかったので、`pyls-black` もインストールしている。

```console
pip install python-language-server
pip install pyls-black
```

# Emacs 側の設定

次のパッケージを使う

* lsp-mode (lsp-ui, company-lsp)
* conda.el

なおわたしはパッケージマネージャは package.el を利用し、パッケージの設定には `use-package` を使っていて、コード補完には `company` を使っている。

## lsp-mode

Python の Language Server を使うために Emacs の [lsp-mode](https://github.com/emacs-lsp/lsp-mode) を使う。[eglot](https://github.com/joaotavora/eglot) という別の実装もあるようだが、わたしは調査をしきれていない。

https://github.com/emacs-lsp/lsp-mode#installation などを参考に、 `lsp-mode` や `lsp-ui`, `company-lsp` の3つをインストール。下記のような設定をする。

```elisp:~/.emacs.d/init.el
(use-package lsp-mode
  :commands lsp)
(use-package company-lsp)
(use-package lsp-ui
  :config
  (add-hook 'lsp-mode-hook 'lsp-ui-mode))
```

### company の backend に追加

```elisp:~/.emacs.d/init.el
(use-package company
  :config
  (global-company-mode)
  (push 'company-lsp company-backends))
```

### python-mode の使用時に起動

lsp-mode が python-mode で有効になるように hook を設定する。

```elisp:~/.emacs.d/init.el
(use-package python-mode
  :config
  (add-hook 'python-mode-hook #'lsp))
```

## conda.el

[necaris/conda\.el: Emacs helper library \(and minor mode\) to work with conda environments](https://github.com/necaris/conda.el)

conda の仮想環境を Emacs から `activate` するために用いる。 `M-x package-install RET conda` をし、

```elisp:~/.emacs.d/init.el
(use-package conda
   :init
   (custom-set-variables '(conda-anaconda-home "~/miniconda3")))
```

などと書くと設定完了。

# 結果

若干手動操作が多いが、

* コードの補完
* conda 環境の切り替え
* pylint による lint (仮想環境ごとに pylint を手動インストールする必要があるが)
* コードフォーマット(`M-x lsp-format-buffer`)
* (マウスホバーやカーソルオンによる docstring や lint 内容の表示)

が実現できた。

![completion.gif](https://qiita-image-store.s3.amazonaws.com/0/69422/c9e144d1-b499-2f26-3f5f-cc3ee0992b2c.gif)

lsp についてよく知らなかったけれど、かなりカバー範囲が広いようだということがわかった。コード補完のみならず、lint や format、ドキュメントの表示までもカバー範囲のようだ。

## 課題

定義ジャンプがこの設定ではできないようなのだけど、わたしの設定が足りないのか否かはわかっていない。ただ大きなプロジェクトを Emacs で開発するモチベーションは現段階では湧いていないのでそのときは素直に VSCode を使おうと思う。

# 参考

参考になるかはわからないけれど、わたしの Emacs の設定。

[515hikaru/dotemacs: my configuration for emacs](https://github.com/515hikaru/dotemacs)
