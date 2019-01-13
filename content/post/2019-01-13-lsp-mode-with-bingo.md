---
title: "GolangのLanguageServerのbingoをEmacsのlsp-modeで動かす"
date: 2019-01-13T23:00:00+09:00
draft: false
tags: ["Editor", "Emacs", "Golang"]
---

# lsp-mode

[2019年からEmacsを使う](/2019-01-06-start-using-emacs-because-start-2019/)と言い出して、結局そんなに使えていないが、設定はちまちまと進めている。この3連休はEmacsでGolangの開発環境を作っていた。

gocodeで補完をする、という記事がいくらでも出てくるがわたしはLSPで行うことにしたのでLanguage Serverを探すことにした。理由は[Big Sky :: gocode やめます\(そして Language Server へ\)](https://mattn.kaoriya.net/software/lang/go/20181217000056.htm)を読んだからである。

# Language Serverの選定

そもそもGolangのLanguage Serverは現在3種類あるらしい[^1]。

[^1]: 当然Language Serverの実装はひとつになることが望ましい。少なくとも [go-langserver の README.md にはそう書いてある](https://github.com/sourcegraph/go-langserver#go-language-server-)。

[F\.A\.Q · saibing/bingo Wiki](https://github.com/saibing/bingo/wiki/F.A.Q#differences-between-go-langserver-bingo-golsp)

上記のWikiページによれば、

- [go-langserver](https://github.com/sourcegraph/go-langserver)
- [bingo](https://github.com/saibing/bingo)
- [golsp](https://github.com/golang/tools/blob/master/cmd/golsp/main.go)

の3種類がある。go-langserverはREADMEに「エディタと使いたいのであればbingoを使ってみてください」[^2]とある。また golsp は公式のようだがあまり情報が見当たらない。また、Emacsのlsp-modeのREADMEには対応Language Serverとしてbingoが挙げられている。そこでわたしもbingoを使ってみることにした。

[^2]: この記事執筆時点では次のように書かれている: If you want to use a Go language server with your editor in the meantime, try https://github.com/saibing/bingo, which is a partial fork of this repository with fixes for Go modules and other editor bugs.

# 環境構築

## bingo のインストール

[Install · saibing/bingo Wiki](https://github.com/saibing/bingo/wiki/Install)

ここをみてインストールした。たしか下記のような感じだったと思う。

```
go get -u https://github.com/saibing/bingo
# なにがしかのエラーが出るが無視
cd $GOPATH/src/github.com/saibing/bingo
GO111MODULE=on go install
```

## lsp-modeの設定

`go fmt` を保存前に実施したい、以外のことはlsp-modeが起動した段階で実現できていた(コード補完、ドキュメントの出力など)。実際それがlsp-modeの強みではある。

ということで保存する前に`lsp-format-buffer`を実行するようにhookを書いた。

```emacs-lisp
(use-package go-mode
  :commands go-mode
  :mode (("\\.go?\\'" . go-mode))
  :defer t
  :init
  (add-hook 'go-mode-hook #'lsp)
  :config
  ;; インデント関係の設定
  (setq indent-tabs-mode nil)
  (setq c-basic-offset 4)
  (setq tab-width 4)
  ;; 保存前に lsp-format-buffer
  (add-hook 'before-save-hook 'lsp-format-buffer))
```

lsp-modeのLanguage Serverの起動設定は https://github.com/emacs-lsp/lsp-mode/blob/master/lsp-clients.el をみればわかるようだ。このファイルを見れば設定を変えられそうだが、とりあえず今はデフォルトの挙動でいいかなと思っている。
