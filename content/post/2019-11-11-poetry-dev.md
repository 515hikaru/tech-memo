---
title: "Poetry についてのメモ"
date: 2019-11-11T00:00:00+09:00
draft: false
tags: ["Python", "BuildTool", "OSS"]
---

## `publish` できないオプションがほしい

- [Add support for disabling package publish · Issue \#1537 · sdispater/poetry](https://github.com/sdispater/poetry/issues/1537)
- ぼくもほしい
- たぶん次のようなステップを踏む
  - `exclude` で代用できないか調査をする
  - 代用できるならそうコメントをして workaroud として報告する
  - できないなら機能追加の PR を出す

### テストしようとしたけど publish ができない

- [Upload to PyPI silently fail · Issue \#858 · sdispater/poetry](https://github.com/sdispater/poetry/issues/858)
- https://test.pypi.org/legacy と https://test.pypi.org/legacy/ で挙動が変わるってお前...

## 結論

ちょっとはまったけどテストはできた。

- `publish` オプションはほしい
- `exclude` を `["**/*"]` と指定しても一応ソースコードの公開は避けられる
- しかしメタデータは公開される恐れがある
    - `poetry build` の結果、 whl ファイルは作成しないが tar.gz は作られる
    - この `tar.gz` の中に `pyproject.toml` や `setup.py` および `PKG-INFO` が混入する
    - あともし `exclude` を指定する **前に** `poetry build` を実行してしまっていた場合は、生成された tar.gz や .whl をアップロードしてしまう

という旨を一応コメントに書いた。自分で実装しようかなと思っているが、結局今日も手を動かさずに終わった。
