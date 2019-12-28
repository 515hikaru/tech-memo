---
title: "DepHell のはじめかた"
date: 2019-12-28T21:22:59+09:00
draft: false
tags: ["BuildTool", "Python", "OSS"]
---

下記の Issue を見つけた。

[How to start? \(CALL FOR COMMUNITY ARTICLES\) · Issue \#348 · dephell/dephell](https://github.com/dephell/dephell/issues/348)

ちゃんと読んでいないが、 DepHell 自体は非常に高機能すぎてどこから、なにを、手を付ければ良いのかよくわからないというのはわたしも正直そう思っている。ただのコンバータとして使うこともできるし、テスト・Lint・開発環境の分離に利用することもできる。なにができるのだか正直よくわからない。

というわけで自分も [Quick Start](https://dephell.readthedocs.io/#quick-start) でも読んで勉強しようかと思った。

[このコメント](https://github.com/dephell/dephell/issues/348#issuecomment-569315064) には DepHell が他のツールとは違う、あるいは DepHell ならではの変わった機能の一部が掲出されているっぽい。特に、

> 1. Quick start with zero knowledge in packaging. dephell deps convert --from=imports --to=setup.py is a really magic and underestimated thing. It can do a package from nothing!

これが気になったので実際にやってみた。 numpy が必要なソースコードを用意する。

```python
import numpy as np

print(np.array([1, 2, 3]))
```

次に、`dephell deps convert --from=imports --to=pyproject.toml` を実行する。そうすると pyproject.toml が次のように生成された。

```toml
[tool]
[tool.poetry]
# ... 中略
[tool.poetry.dependencies]
python = "*"
numpy = "*"
```

最近さすがに見なくなったが、まれに requirements.txt さえない Python プロジェクトに出会った経験はあるので、そういうツールがあったときにこれは使えるんじゃなかろうか。
