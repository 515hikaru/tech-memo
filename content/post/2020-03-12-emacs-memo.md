---
title: "Emacsにした設定"
date: 2020-03-12T23:00:00+09:00
draft: false
tags: ["Emacs"]
---

### Projectile

プロジェクト管理のための Projectile を導入した

[![bbatsov/projectile - GitHub](https://gh-card.dev/repos/bbatsov/projectile.svg)](https://github.com/bbatsov/projectile)

単に導入するだけなら package.el に書くだけなのだけれど、ghq で管理しているリポジトリたちを自動でプロジェクトと認識してほしくて、少し工夫が必要だった。とは言え、[こちらの質問](https://emacs.stackexchange.com/questions/32634/how-can-the-list-of-projects-used-by-projectile-be-manually-updated)を参考にして下記のコードを書いた。


```lisp
;;; projectile
(projectile-mode +1)
(define-key projectile-mode-map (kbd "C-c p") 'projectile-command-map)
(with-eval-after-load 'magit
  (setq magit-repository-directories
        '(;; Directory containing project root directories
          ("~/dev/"      . 3))))
  (with-eval-after-load 'projectile
    (when (require 'magit nil t)
    (mapc #'projectile-add-known-project
          (mapcar #'file-name-as-directory (magit-list-repos)))
    ;; Optionally write to persistent `projectile-known-projects-file'
    (projectile-save-known-projects)))
```


これで `~/dev/github.com/515hikaru/tech-memo` のようなプロジェクトは全て自動でプロジェクト認定される。要するに `ghq get` したリポジトリは全て検索対象になる。

### テーマ、見栄えなど

[Emacsモダン化計画 \-かわEmacs編\- \- Qiita](https://qiita.com/Ladicle/items/feb5f9dce9adf89652cf)

上記記事から、

- doom-emacs-theme
- doom-modeline
- rainbow-delimiters

を拝借した。ほとんど公式リポジトリのままの設定をしてある。

### easy-hugo

この記事は Markdown で書いて Hugo で HTML にしているわけだけど、その Hugo の操作を Emacs からやれるぞというパッケージ。

[![masasam/emacs-easy-hugo - GitHub](https://gh-card.dev/repos/masasam/emacs-easy-hugo.svg)](https://github.com/masasam/emacs-easy-hugo)

いまは2つ Hugo のプロジェクトがあるので複数ブログの設定をしてある(方法はREADMEに書いてある）。

