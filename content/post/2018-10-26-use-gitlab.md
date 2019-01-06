---
title: "GitLabを使い倒す"
date: 2018-10-26T00:20:56+09:00
draft: false
tags: ["Development Environment"]
---

# GitLabの紹介

GitLabというツールがある。知っている人は聞き飽きたであろう解説をすると、Ruby on Rails製のWebアプリケーションで、ソースコード管理、Issueトラッカー 、コードレビュー機能、Docker Container Registry、CI/CDなど様々な機能を内包している[^1]。現在は[GitLab Inc.](https://about.gitlab.com/company/)が無料版のCommunity Editionの開発・サポートに加えて、[Enterprise Editionの提供](https://gitlab.com/gitlab-org/gitlab-ee)やSaaSとして提供されている[gitlab.com](https://gitlab.com)の運用を行っている。

[^1]: Kubernetesに関係する機能もあるみたいなんだけどよく知らない。

# GitHubとの違い

競合のGitHubと比較されることが多い。しかし、わたしの知る限り焦点がプライベートリポジトリが無制限で利用できるなど金銭面での比較のみしている場合が多い[^2]。しかしここでわたしが強調したいのはGitHubとGitLabは似たようなツールに見えてそもそも思想が根本的に異なるということだ。

[^2]: 確かに個人開発では資金源がないのに開発にお金をかけると赤字必須なので金銭面は重要ではある。

## GitHubの思想

GitHubは開発者のコラボレーション[^3]ツールである。開発者同士がGitHubで(たとえばソフトウェアを通して)つながり、意見交換をしたり、パッチを送り合ったりする。単にチームや組織での開発に限らず、見ず知らずの開発者同士のつながりも意図されたサービスである。早い話が開発者向けのSNSだ。

パッチを送るときも他者のリポジトリをForkして、自分が作ったリポジトリの差分をPullしてもらうよう依頼するから「プルリクエスト」である。

[^3]: 日本語だと協働だろうか。

## GitLabの思想

一方でGitLabはチームでの開発を重視している。不特定多数の開発者とつながることよりも、特定の知人同士(など)での開発がしやすい。リポジトリもForkするのではなく共有して別ブランチに自分の`feature`ブランチを切って、それをマージしてもらう(「マージリクエスト」)ことを主眼においている。

そのかわりモダンなソフトウェアを開発するために必要なすべてがGitLabから提供される。GitHubは他サービスとそれこそ協働することでモダンな開発を実現する。(CI/CDにCircle CIやTravis CIを設定して、カバレッジはCodeCovでとってと芋づる式に関係サービスが増える。Issueトラッカーも締め切りさえ設定できない)。GitLabはCI/CDはGitLab CIで行えるし、カバレッジはGitLab Pagesで閲覧できるしとGitLab以外の外部サービスを利用する必要がない。Issueトラッカーもデフォルトで色々とできる。

GitLabはまさしく、"A single application for the entire DevOps cycle." なのだ。

<iframe width="560" height="315" src="https://www.youtube.com/embed/MqL6BMOySIQ" frameborder="0" allow="autoplay; encrypted-media" allowfullscreen></iframe>

# GitLabを使いまくる

わたしは業務でGitLabを使いまくっている。GitLabと社内のチャットツールさえあれば仕事ができる。業務で利用するアプリケーションが少なければ少ないほどいいと思っている。

具体的には、

* Issues で課題の整理・経過の記録
* MR でコードレビュー
* CI/CD
    * pushされるごとに単体テスト
    * developに変更があるごとに結合テスト
    * developブランチのNightlyビルド
    * タグを打った時の自動ビルド
* ビルドした成果物は registry.gitlab.com にホスト

これらが単一のアプリケーションだけで実現できる。

# 余談

と、宣伝をしたがわたしは最近個人ではGitHubしか使っていない。理由は会社で使っているものを個人でも使っているとなんか仕事感が出てしまう。アカウントを変えても同じ。

あと外部サービスにしてもソースコードを公開している限りは外部サービス利用も無料であったりする[^4]。GitLabしか使わないのはそれはそれで意味のあることではあるのだけれど、外部サービスの使い方に慣れておくのも別に悪い経験ではない。というかOSS開発では普通に使われているし、そういうツールの使い方を全く知らないのもいかがなものかと思ってしまう。

[^4]: Travis CIなど。

ということで最近平日はGitLab、休日はGitHubを見るという生活をしている。これはこれでバランスが取れていていいんじゃないかと思っている。
