+++
title = "pnovel-mode つくった"
author = ["515hikaru"]
date = 2020-08-02T00:00:00+09:00
tags = ["Emacs", "pnovel"]
draft = false
stylesheet = "post.css"
+++

## pnovel-mode を作った {#pnovel-mode-を作った}

初めて Emacs の major-mode を作った。

[515hikaru/pnovel-mode: Emacs major mode for pnovel](https://github.com/515hikaru/pnovel-mode)

といっても、自分でお作法を勉強して作ったというよりも、簡単なシンタックスハイライトの追加をできる機構を使っただけ。更に言うと、 bd\_gfngfn さんの satysfi.el を大いに参考にした。ほとんどパクリかもしれない。

[gfngfn/satysfi.el: An Emacs major mode for SATySFi](https://github.com/gfngfn/satysfi.el)


## やったこと {#やったこと}


### シンタックスハイライト {#シンタックスハイライト}

Emacs には Generic Modes というモードがあって、次のようなことが簡単にできる。

-   コメント記法の登録
-   キーワードの登録
-   正規表現を用いたシンタックスハイライトのカスタマイズ

詳細は [Generic Modes - GNU Emacs Lisp Reference Manual](https://www.gnu.org/software/emacs/manual/html%5Fnode/elisp/Generic-Modes.html)

下記は pnovel-mode の引用。

```emacs-lisp
(define-generic-mode pnovel-mode
  '("%")
  '("newline" "newpage")
  '(("# .*" . font-lock-warning-face)
    ("`.*`" . font-lock-doc-face))
  nil nil
  "Major mode for pnovel")
```

上記で、

-   `%` はコメント記法
-   newline と newpage はキーワード
-   `#` から始まる行は font-lock-warning-face で表示
-   `` `` `` に囲まれている文字は font-lock-doc-face で表示

といったことを指定している。


### Emacs でコンパイル {#emacs-でコンパイル}

さすがに Emacs でコマンド実行結果を表示してみたくなったので、次のようなコマンドを定義した。

```emacs-lisp
(defvar pnovel-command "npx pnovel")

(defun pnovel-mode/pnovel-compile ()
  (interactive)
  (progn
    (message "Compiling '%s'" buffer-file-name)
    (async-shell-command (format "%s %s\n" pnovel-command buffer-file-name))))
```

これで現在のバッファに対して `npx pnovel` を実行し、その結果を表示してくれる。

{{< figure src="/images/example.png" >}}

（左が原文、右が実行結果）


## まとめ {#まとめ}

結構簡単に major-mode もどきは作れるので、自分でナニカフォーマットを作ったときはカジュアルに `define-generic-mode` してしまおう。
