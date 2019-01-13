---
title: "2019年が始まったのでEmacsを使い始めた"
date: 2019-01-06T19:00:00+09:00
draft: false
tags: ["Editor", "Emacs", "Development Environment"]
---

なんか何度も Emacs に入門しては結局使わなくなるを繰り返していたのだけど、 [Emacs JP が再始動された](https://emacs-jp.github.io/2019/01/01/reboot-emacs-jp)らしいし、自分も Elm をやってみようと思ってやっぱり [Haskell のときと同じように](https://blog.515hikaru.net/entry/2016/09/12/021206) Emacs で環境つくりたいよなと。そこでもうメインエディタを Emacs にしちゃえばいいか!w というノリで始めました。

`~/.emacs.d` はここ。まだ 3 日くらいしか経っていないので 120 行くらいしかないけれど。

[515hikaru/dotemacs: my configuration for emacs](https://github.com/515hikaru/dotemacs)

いろいろと野望はあるのだけれど、あんまり深入りしすぎない程度にやっていきたい。

# やったこと

- Elm の開発環境をセットアップ
- Rust の開発環境をセットアップ(後日大幅に変更予定[^1])
- [Pythonの開発環境をセットアップ](https://qiita.com/515hikaru/items/8b364b4d091459a85dc0)
- メモがすぐにとれるように open-junk-file を導入
- 利用するフォントを [Ricty Diminished Discord](https://www.rs.tus.ac.jp/yyusa/ricty_diminished.html) に変更

[^1]: https://github.com/515hikaru/dotemacs/issues/2

コード補完(company)も静的解析(flycheck)も動かしているけどまだまだという印象。やれることはまだまだたくさんあるし、やらないといけないことはまだまだたくさんある。

## lsp-mode

巷では [Language Server Protocol](https://microsoft.github.io/language-server-protocol/) が賑わせているのでいろいろ自分の開発環境にも導入をしてみたいのだけれど、少なくとも自分が 'lsp-mode python emacs' とかでググって日本語の記事は出てこなかった[^2]。ちなみに 'lsp python' とかでググったら Vim の設定をする記事は出てきた。読んでないけど。

[^2]: ので Qiita に記事を書いた。でも Qiita じゃなくここに書けばよかった気もする。同じことを二箇所に書いているのは気持ち悪いのでしないけど。

[emacs\-lsp/lsp\-mode](https://github.com/emacs-lsp/lsp-mode) は Python のみならず Rust, Haskell, Scala, Go, Go, C++ などなどいろいろな言語に対応している(詳細はリンク先の README を)ようなのと、`lsp-mode` とは別の実装もあるらしい[^3]。

[^3]: [emacs\-lsp/lsp\-mode: Emacs client/library for the Language Server Protocol](https://github.com/emacs-lsp/lsp-mode)

なんにせよ VSCode のような環境が Emacs のモードと Language Server があれば実現できる、というのはなかなかすごい気がする[^4]。[python\-language\-server](https://github.com/palantir/python-language-server) の実装は Python なのでわたしにも読めそうな気がするし。

[^4]: ずっと追っている人からすればこの感想は今更なのかもしれないが。

これからいろんな言語の開発環境を Language Server でやっていってみたいなと思う次第。

# 今後の課題

- [ein](https://github.com/millejoh/emacs-ipython-notebook)してみたいかも、[NumPyデータ処理入門](https://www.amazon.co.jp/%E7%8F%BE%E5%A0%B4%E3%81%A7%E4%BD%BF%E3%81%88%E3%82%8B-NumPy%E3%83%87%E3%83%BC%E3%82%BF%E5%87%A6%E7%90%86%E5%85%A5%E9%96%80-%E6%A9%9F%E6%A2%B0%E5%AD%A6%E7%BF%92%E3%83%BB%E3%83%87%E3%83%BC%E3%82%BF%E3%82%B5%E3%82%A4%E3%82%A8%E3%83%B3%E3%82%B9%E3%81%A7%E5%BD%B9%E7%AB%8B%E3%81%A4%E9%AB%98%E9%80%9F%E5%87%A6%E7%90%86%E6%89%8B%E6%B3%95-AI-TECHNOLOGY/dp/4798155918)が読みやすくなりそうだし。
- プロジェクトの管理、というより多数のファイルでひとつのプロダクト/ライブラリになっているような状況で開発を Emacs でやるにはどうするんだろう。正直 VSCode でもいいけど。


あとこれは一般的な話だが、自分がプラグインを作るというよりは既にあるプラグインを改善していく方に力を入れたい。全然 Emacs Lisp 書けないので微力だけれども[^5]。最近オーバーエンジニアリングしすぎていて疲れているので、既存のものの組み合わせでいい感じにしていきたい。

[^5]: それでも Vim script よりは書ける、と思う。
