---
title: "交差検証中に訓練データに対してのみAugmentationを実施する"
date: 2019-07-01T00:00:00+09:00
draft: false
tags: ["scikit-learn", "Python", "Machine Learning"]
---

# 背景

scikit-learn の`GridSearchCV`など cross validation を実施する時に、`.fit()`メソッドに渡した`X`と`y`に対して指定した cross validation の方法で training データセットと validation データセットに分割してくれます。例えば、`cv=5`を指定すればデータセットを 5 分割して、1 回のパラメータで 5 つモデルを作り、評価指標を計算してくれるでしょう。

ところで、Data Augmentation を実施しているときなど、training データセットは増やしたいが validation データセットは増やしたくないときがあります。しかし、そうしたときもそのまま`.fit(X, y)`に Augmentation で増やしたデータも渡してしまうと、正しくモデルが validation されなくなってしまいます。

## 具体例

上の説明だけではよくわからないと思うので、もう少しモチベーションを書きます。実際、`GridSearchCV`に対して何も考えずにデータを渡すと次のように、意図しない Leakage が発生することがあります。

```python
import numpy as np
from sklearn.model_selection import GridSearchCV
from sklearn.ensemble import RandomForestClassifier

def load_augment_data(X, y):
    # ... X や y になんらかのノイズを加えて返すような処理
    return aug_X, aug_y

origin_X, origin_y = load_origin_data()
aug_X, aug_y = load_augment_data(origin_X, origin_y)  # 増やした分のデータ
# 元のデータと増やした分のデータを結合させる
X = np.concatenate((origin_X, aug_X))
y = np.concatenate((origin_y, aug_y))
params = [{...}]  # 本当にグリッドサーチするときはパラメータの探索範囲を指定する
grid_search = GridSearchCV(RandomForestClassifier(), param_grid=params)
grid_search.fit(X, y)  # LEAKAGE!!
```

このコードだと、`.fit(X, y)`の内部ではもとのデータも Augment したデータも同列に扱われ、モデルの評価にも使われてしまいます。Augmentation は学習データをかさ増しするためのテクニックで、[Augment したデータを用いてモデルの性能を評価してはいけません](https://stackoverflow.com/questions/48029542/data-augmentation-in-test-validation-set)。したがって、このコードにおいて`GridSearchCV`は誤った評価に基づいて「最良」のモデルを返すことになります[^1]。

[^1]: これに類似した Linkage が『[Python ではじめる機械学習](https://www.amazon.co.jp/Python%E3%81%A7%E3%81%AF%E3%81%98%E3%82%81%E3%82%8B%E6%A9%9F%E6%A2%B0%E5%AD%A6%E7%BF%92-%E2%80%95scikit-learn%E3%81%A7%E5%AD%A6%E3%81%B6%E7%89%B9%E5%BE%B4%E9%87%8F%E3%82%A8%E3%83%B3%E3%82%B8%E3%83%8B%E3%82%A2%E3%83%AA%E3%83%B3%E3%82%B0%E3%81%A8%E6%A9%9F%E6%A2%B0%E5%AD%A6%E7%BF%92%E3%81%AE%E5%9F%BA%E7%A4%8E-Andreas-C-Muller/dp/4873117984/ref=sr_1_1?adgrpid=60120324664&gclid=CjwKCAjwxrzoBRBBEiwAbtX1n-6tdpGbQ6qjQmHwqbADMqiAroJGDciMuAS9MJ1-EDmQk8qaH6rF0xoCoKAQAvD_BwE&hvadid=338518119357&hvdev=c&hvlocphy=1009312&hvnetw=g&hvpos=1t1&hvqmt=e&hvrand=1002211770173419307&hvtargid=kwd-314655987025&hydadcr=27268_11561170&jp-ad-ap=0&keywords=python%E3%81%A7%E3%81%AF%E3%81%98%E3%82%81%E3%82%8B%E6%A9%9F%E6%A2%B0%E5%AD%A6%E7%BF%92&qid=1561300891&s=gateway&sr=8-1)』の 304-306 ページに掲載されています。なお、この記事で解説する方法はこの本の事例のコードの解決策として採用されているコードから筆者が着想し、具体化したものです。

簡単に言うと、`GridSearchCV`を使う場合、`.fit(X, y)`を呼ぶ段階で`X, y`に Augment したデータが混じっていてはマズイわけです。

ではどうすればいいのか? というのを可能な限り SciKit Learn やその周辺のフレームワークの枠組みに則って解決しようというのがこの記事の趣旨になります。

# 解決方法

一言で言えば、「Data Augmentation を(オーバー)サンプリングだと思い、imbalanced-learn の API を活用する」がこの記事で記載する内容です。

imbalanced-learn は本来不均衡データに対処するために、教師ラベルが多いデータを少ないデータに合わせて少なめにサンプリングしたり、逆に少ないデータを複数回サンプリングしたりするためのライブラリです。

言い換えると、データに合わせて**学習直前に多め/少なめにサンプリングする**ことを念頭においている処理で、当然**推論直前には何もしない**ことが期待されています。これを利用して、学習直前だけ Data Augmentation をし、validation 直前には何もしないパイプラインを実現します。

こうした一連の処理をよしなにやってくれるのが`imblearn.pipeline.Pipeline`です。微妙に本家 scikit-learn の`Estimator`や`Transformer`とは API が異なるため、imbalanced-learn の Pipeline クラスを利用します。[^2]。もし `sklearn.pipeline.Pipeline` を知らなければ[Python: scikit\-learn の Pipeline を使ってみる \- CUBE SUGAR CONTAINER](https://blog.amedama.jp/entry/2018/07/07/223257)などを参照してください

[^2]: 具体的には`.transform(X)`の返り値でコケます

## サンプル実装

ここではおなじみ iris データセットを使って cross validation 時にデータが学習直前にだけ増えているのかを確認します。

### やること

タイトルには Data Augmentation と書きましたが、ここではオーバーサンプリングをします。具体的には、学習に使う 1 つのレコードを 2 つにするというオーバーサンプリングをします。もちろん通常の機械学習の実験で実施しても全く意味のないサンプリングです。しかし、意図通りにデータを増やせていることが確認しやすいのでこのようにします。

#### 実装例

```python:augment.py
import numpy as np
import pandas as pd


class DoubleSmapler():
    def __init__(self, source, **kwargs):
        self.source = source
        self._indexes = None

    def _load_from_source(self):
        df = pd.read_csv(self.source)
        return df.iloc[:, :-1], df.iloc[:, -1]

    def fit(self, X, y):
        self._indexes = X.index
        return self

    def fit_resample(self, X, y):
        self.fit(X, y)
        augment_X, augment_y = self._load_from_source()
        add_X = augment_X.loc[self._indexes, :].values
        add_y = augment_y.loc[self._indexes, :].values

        return np.concatenate((X, add_X)), np.concatenate((y, add_y))

```

`.fit(X, y)`が渡された時に、`X`の index を保存します。これはサンプルなので単に index を保持していますが、真面目にやるならば学習データの ID 列を作って保持するのがいいでしょう。そうすると、`fit(X, y)`で渡されたレコードの ID をこのクラスは知っている(`self._indexes`に格納されている)ことになります。

そして`fit_resample(X, y)`が呼ばれたときに、外部からデータを読み込み`fit`のときに知った index と同じ index のものを外部データから抽出しています。それと`transform`にわたされた元のデータを連結させてサンプリングは終了です。

#### 前提

ちょっと脱線ですが、動かす前提を書いておきます。

このクラスを動かすには、次のような形式の iris データを CSV ファイル形式で持っていることを想定しています。

```csv
sepal length (cm),sepal width (cm),petal length (cm),petal width (cm),target
5.1,3.5,1.4,0.2,0
4.9,3.0,1.4,0.2,0
4.7,3.2,1.3,0.2,0
4.6,3.1,1.5,0.2,0
5.0,3.6,1.4,0.2,0
5.4,3.9,1.7,0.4,0
4.6,3.4,1.4,0.3,0
5.0,3.4,1.5,0.2,0
4.4,2.9,1.4,0.2,0
```

また`.fit(X, y)`で渡される`X`は`pd.DaraFrame`であることを想定しています。(`.index`で行数にアクセスしているので)

### 期待通り動作することを確認

では実際にこのクラスを使って、iris データを"学習データのみ 2 倍にして"学習できているのかを確認してみましょう。上記の iris.csv を読み込み、実際に学習をさせてみます。

```python
import numpy as np
import pandas as pd
from sklearn.ensemble import RandomForestClassifier
from sklearn.model_selection import cross_val_score
from imblearn.pipeline import Pipeline  # sklearn.pipeline ではないことに注意

from augment import DoubleSmapler

data = pd.read_csv('iris.csv')
X = data.iloc[:, :-1]
y = data.iloc[:, -1]

# データが増えていることを確認するためにデータ形式を表示するクラス
class Debugger():
    def fit(self, X, y=None):
        print('fit!')
        return self

    def transform(self, X, y=None):
        print('transform:', X.shape)
        return X

pipe = Pipeline(steps=[
    ('deb1', Debugger()),
    ('aug', DoubleSmapler(source='iris.csv')),
    ('deb2', Debugger()),
    ('rf', RandomForestClassifier()),
])
```

こんな感じでパイプラインを定義します。データが意図どおり増えている(パイプラインスタート時と学習直前時でちょうど 2 倍になっている)ことを確認するために、行列の形を表示するクラスを仕込みましたが、それ以外は変わったことは何もしていません。

これで cross validation を実施すると次のように表示されます。

```python
cross_val_score(pipe, X=X, y=y, cv=5)
```

```txt:表示
    fit!
    transform: (120, 4)
    fit!
    transform: (240, 4)
    transform: (30, 4)
    transform: (30, 4)
    (中略)
    array([0.96666667, 0.96666667, 0.93333333, 0.93333333, 1.        ])
```

こんな感じで学習のために使われるデータ(150 / 5 \* 4 = 120)は倍の 240 個になってから学習が実施され、推論のための 30 個はデータは増えないで 30 個のままで推論がなされました。

# まとめ

- augmentation をして得られたデータは cross validation 時の validation セットに加えてはならない
- cross validation をするときは imbalanced-learn の Sampler 実装を真似るなどして Augmentation を実施するクラス(もしくは関数)を作成する
- Pipeline に任せると**学習直前にのみ**Augmentation を実施し、**validation 直前には Augmentation を実施しない**という処理が**簡単に**実現できる

これ思いつくのに結構時間がかかった[^3]んですが、わりと当たり前のように行われているテクニックだったりするんでしょうか。

[^3]: Pipeline が学習直前には `.fit()` と `transform()` を実施し、Validation 時には `transform()` しか実施しないので `fit()` で受け取った学習データにしか augmentation を実行しないようにできないかと考え始めた。この問題ばかり考えていたわけじゃないが、この問題を意識してからこの着想を得るまでに 2 週間くらいはかかった気がする。
