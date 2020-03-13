---
title: "org-capture のメモ"
date: 2020-03-14T02:21:31+09:00
draft: false
tags: ["Emacs"]
---

# Emacs Org-mode

また謎の Emacs 熱が浮上したので Emacs の Org mode の設定をしてみた。人生何回目だろうか。

org-capture を使う。

# org-capture

簡単にいうと、メモをとるためのもの。設定例。

```elisp
;;; org-capture
(setq org-capture-templates
      '(("t" "Todo" entry (file+headline "~/dev/github.com/515hikaru/org-memo/remind.org" "■Capture") "* REMIND %? (wrote on %U)")
        ("k" "Knowledge" entry (file+headline "~/dev/github.com/515hikaru/org-memo/knowledge.org" "TOP") "* %?\n  # Wrote on %U")
        ("n" "News" entry (file+headline "~/dev/github.com/515hikaru/org-memo/news.org" "NEWS") "* %?\n  # Wrote on %U")
        ("p" "Technology" entry (file+headline "~/dev/github.com/515hikaru/org-memo/techs.org" "Techs") "* %?\n  # Wrote on %U")
        ("w" "Work" entry (file+headline "~/dev/github.com/515hikaru/org-memo/work.org" "Work") "* %?\n  # Wrote on %U")))
```

これで

- Todo 用メモ
- knowledge 用メモ
- ニュース用メモ
- 技術系メモ
- 仕事関連メモ

のメモ用テンプレートを作成している。まだ使っていないので効果は未知数。

# TODO/DONE では物足りない

個人的に、TODO/DONE では TODO リストは物足りなくて、「一度起票したけど実施しなかったもの」というカテゴリが必要だと思っている。例えば Nulab の Backlog はステータス:完了、完了理由: 対応しない というものがあり、すごく良いと思っている。

org-mode でも表現できる。というのも TODO/DONE 以外のキーワードを登録できる。

[モーレツ\! Org mode 教室 その5: TODOを管理する – mhatta's mumbo jumbo](https://www.mhatta.org/wp/2018/08/27/org-mode-101-5/)

というわけで、早速 `CANCELED` なるキーワードを追加してみた。

```elisp
;;; TODO
(setq org-todo-keywords
      '((sequence "TODO(t)" "WAIT(w)" "REMIND(r)" "|" "DONE(d)" "SOMEDAY(s)" "CANCELED(c)")))
```

これで `Shift + left` や `Shift + right` とかで `CANCELED` なども選択できるようになる。
