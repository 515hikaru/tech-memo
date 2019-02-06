---
title: "pecoとghqの組み合わせをpowershellでもやりたい"
date: 2019-02-07T00:00:00+09:00
draft: false
---

# 背景

`ghq` というコマンドを使いリポジトリを管理し始めた。その後、`peco` というコマンドと組み合わせるといいよみたいな記事が大量に出てきて試してみたらわたしも便利だと感じたので利用することにした。

`ghq get` で手に入れたリポジトリのどれかに `ghq look` したい[^1]というときはよくあって、それを `peco` でできると便利。具体的には次のようにする。

```bash
function ghq-peco {
    ghq look $(ghq list | peco)
}
```

[^1]: あまり関係ないけど、このコマンドに `look` という命名ができるのすごいセンスがあると思う。わたしには `look` という命名はできない。

これを Windows でもやりたいと思った。最近 `cmd.exe` はあんまり使わないので PowerShell で。

[この記事によると](https://qiita.com/bitnz/items/400bb6a0b124b8b3d398)、PowerShell における `~/.bashrc` に相当するものは `%UserProfile%\Documents\WindowsPowerShell\profile.ps1` らしい。ということでこのファイルに以下のように記述。

```ps1
function ghq-peco {
    ghq.exe look $(ghq list | peco.exe)
}
```

今回は外部コマンドだらけだったのでだいたい `.bashrc` と同じ。意外。

これで PowerShell を必要ならば再起動して、 `ghq-peco` と入力すると、 `ghq` コマンドで管理しているリポジトリに `look` できるはずだ。