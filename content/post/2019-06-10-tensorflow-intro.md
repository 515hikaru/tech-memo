---
title: "今更ながらTensorflowの入門書を読んだ"
date: 2019-06-10T00:42:35+09:00
draft: false
tags: ["Machine Learning", "Python"]
---

今更かよと思われるかもしれないが、Tensorflowの入門書をしばし読んでいた。

[TensorFlow&Kerasプログラミング実装ハンドブック \| チーム・カルポ \|本 \| 通販 \| Amazon](https://www.amazon.co.jp/TensorFlow-Keras%E3%83%97%E3%83%AD%E3%82%B0%E3%83%A9%E3%83%9F%E3%83%B3%E3%82%B0%E5%AE%9F%E8%A3%85%E3%83%8F%E3%83%B3%E3%83%89%E3%83%96%E3%83%83%E3%82%AF-%E3%83%81%E3%83%BC%E3%83%A0%E3%83%BB%E3%82%AB%E3%83%AB%E3%83%9D/dp/4798055417/ref=sr_1_9?__mk_ja_JP=%E3%82%AB%E3%82%BF%E3%82%AB%E3%83%8A&keywords=tensorflow&qid=1560091692&s=gateway&sr=8-9)

まず、実はわたしは実務でニューラルネットワークを利用したことがほとんどない。今まであまり縁がなかった[^1]。

[^1]: データ量が少ない、次元数が少ない、プロジェクトの時間がない、計算時間が短くないといけない、この推論結果になった理由が説明できないといけないなど様々な理由でニューラルネットワークを利用したモデルを使うことはほとんどなかった。

Tensorflow の書き方が特殊なことくらいは知っていたが、わたしは基本的に Keras のバックエンドを Tensorflow にして間接的に利用していたくらいで低レベルAPIを直に触ったコードをたくさん書いた経験がなかった。なので、ページをめくって写経していくとだいたい何となくつかめてくる、そんな経験をしたくてこの本を読んで、コードを写経して実行してを繰り返していた。

## 読んだ理由・モチベーション

読んだ理由は、低レベルAPIと高レベルAPIの違いを体感したかったというのが一番のモチベーションだ。もちろん、ほとんど使ったことのなかったニューラルネットワークの基礎をある程度学びたいというモチベーションもあったが、それは当然のこととしている。

この本の中には(多分)低レベルAPIという言葉は出てこないが、今のTensorflowは低レベルAPI(以前のバージョンからある自分で計算グラフを定義して Session を立てて計算を実行する方式)と高レベルAPI(Kerasのようにモデルのインスタンスを作成して、メソッドを使ってモデルを定義し、sklearnのように学習や推論を実行する方法)との2種類がある。この本では低レベルAPIの使い方が解説されている。

はっきり言って、高レベルAPIと低レベルAPIの違いやどういう操作が低レベルAPIだとやりやすくて、どういう操作が高レベルAPIだとやりやすいのかというのはわたしは現時点でもあまり説明できない。買った当初は何もわかっていなかったので、この本を手に取った理由のひとつに、低レベルAPIの利用経験を踏んで高レベルAPIとの差を体感したいというモチベーションがあった。

今は少しわかっているけど、 `Sequential` モデルでできないことも今はできたりするみたいだから、わたし自身高レベルAPIを使いこなせているわけではない。そんな状態。

## 感想

結論から言うと、写経するには非常に良いと思った。どんな解説があったのが正直ちゃんと読んでいない部分もあるが、どうやって計算を実行するか(Define and Run)から始まり、ロジスティック回帰や線形回帰など初等的な例、TensorBoardによる可視化、ニューラルネットワークなど前書いたコードで得た知識がちゃんと次の節でも生きるようになっており、写経が苦じゃなかった。むしろ自分が書ける範囲が徐々に広がっていくのが体感できて、フレームワークの使い方を学んでいるという感じがした。

だた一部行儀が悪いなと思うコードも散見されたので、ある程度Pythonでコードを書いた経験は必要かもしれない。

```python
for i in range(100):
  # なんか処理
  i += 1
  if i % 10 == 0:
    print(i, 'some string')  # ログ
```

みたいなコードがあり、さすがに `for` ブロックの中で、 `i` を書き換えるのは行儀悪いだろ...と思ったがそれ以外が覚えていない。あとJupyter Notebook前提になっている(よくある)のでスクリプト化したり、クラスのメソッドでグラフを定義したりするときに `tf.Graph()` インスタンスをどう制御すればいいとか、そういう話は一切なかった。わたしはこのへんてきとうにやっている。

ずっと写経ばかりしていたわけじゃないけど、結構サクサクと進んだのでそんな難しい本でもないと思う。ちょっと誤差逆伝搬のところは数式のフォントが読みづらかったので[『深層学習』(岡谷貫之、講談社MLPシリーズ)](https://www.amazon.co.jp/%E6%B7%B1%E5%B1%A4%E5%AD%A6%E7%BF%92-%E6%A9%9F%E6%A2%B0%E5%AD%A6%E7%BF%92%E3%83%97%E3%83%AD%E3%83%95%E3%82%A7%E3%83%83%E3%82%B7%E3%83%A7%E3%83%8A%E3%83%AB%E3%82%B7%E3%83%AA%E3%83%BC%E3%82%BA-%E5%B2%A1%E8%B0%B7-%E8%B2%B4%E4%B9%8B/dp/4061529021/ref=sr_1_1?__mk_ja_JP=%E3%82%AB%E3%82%BF%E3%82%AB%E3%83%8A&keywords=%E6%B7%B1%E5%B1%A4%E5%AD%A6%E7%BF%92&qid=1560094450&s=gateway&sr=8-1)を読んだけど、たぶんだいたい同じことが書いてあった。どっちのほうがわかりやすいかは比べてないけど。数式を少し真面目に追ったが正直覚えていない。たしかどのニューロンにどの変数が依存しているのかを考えつつ2回chain ruleを使うのがポイントだったと思う。

## まとめ

正直他の本をほとんど読んでいないし比較しようもないのだけど、Tensorflow何も知らなくてもだいたいどんなフレームワークかわかるのでいいんじゃないかなと思う。わたしみたいにほとんど低レベルAPI使ったことない初心者向き。

これを読んでだんだんTensorflowのドキュメントの言っていることがわかるようになってきたかなーという感じ。低レベルAPIでごりごり色々と書かされるせいで高レベルAPIへのモチベーションも湧く。みんなも高レベルAPI使おう。