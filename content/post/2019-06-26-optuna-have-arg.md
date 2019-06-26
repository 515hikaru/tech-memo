---
title: "Optunaの目的関数に引数をもたせたい"
date: 2019-06-26T22:26:53+09:00
draft: false
tags: ["Python", "Machine Learning"]
---

# Optuna

[Optuna \- A hyperparameter optimization framework](https://optuna.org/)

ハイパーパラメータを最適化するフレームワーク。詳細は公式ドキュメントなりをみていただければ。わたしは[GitHubのREADME](https://github.com/pfnet/optuna)を読んだだけで使ってみた状態なので、以下に書くことが行儀の良いやり方なのかはしりません。

# やりたいこと

READMEのコードには、

```python
# Define an objective function to be minimized.
def objective(trial):
    # ... 省略


study = optuna.create_study()  # Create a new study.
study.optimize(objective, n_trials=100)  # Invoke optimization of the objective function.
```

と書かれている。ここで、 `study.optimize` は関数オブジェクトを受け取っている。言い換えると `objective` は　`trial : optuna.Trial` というただひとつの引数だけを受付ける関数であるという前提がある。

一方で、いろいろな事情で最適化を複数回実行したいとか、オプション引数に合わせて目的関数を変えたいなとか思うことがあるだろう。しかし目的関数は `trial` 以外の引数は取らないから、たとえば `is_hoge` みたいなフラグ変数を作るのは難しそうだ。

と、そこでPythonは関数がファーストオブジェクトであることを思い出して、高階関数を書けばいいだけだったと思い至った。

# サンプル例

下記の [Optuna のランディングページ](https://optuna.org/) のQuick Startにあるサンプルコードを使う。

```python
import optuna

def objective(trial):
    x = trial.suggest_uniform('x', -10, 10)
    return (x - 2) ** 2

study = optuna.create_study()
study.optimize(objective, n_trials=100)

print(study.best_params)
```

たとえば、 `(x - 2) ** n` を最適化するように変えてみよう。

```python
import optuna

def objective_variable_degree(n):

    def objective(trial):
        x = trial.suggest_uniform('x', -10, 10)
        return (x - 2) ** n

    return objective
```

こんな感じで `objective_variable_degree` が引数を受け取った結果帰ってくるのが `objective` 関数であればよい。

ためしに、4次の多項式を最適化してみた。3次にしなかった理由は単に-10に近づくだけでつまらなかったので...。下記のコードを書いて適切に実行した。といってもサンプルから受け取る関数の名前を変えただけである。

```python
study = optuna.create_study()
study.optimize(objective_variable_degree(4), n_trials=100)

print(study.best_params)
```

次のような出力が得られる。

```
[I 2019-06-26 22:50:03,850] Finished trial#0 resulted in value: 6052.213452475149. Current best value is 6052.213452475149 with parameters: {'x': -6.820202562342194}.
[I 2019-06-26 22:50:03,865] Finished trial#1 resulted in value: 10725.225690223175. Current best value is 6052.213452475149 with parameters: {'x': -6.820202562342194}.
[I 2019-06-26 22:50:03,891] Finished trial#2 resulted in value: 1403.2146449107272. Current best value is 1403.2146449107272 with parameters: {'x': 8.120417202779894}.

... 中略　...

[I 2019-06-26 22:50:06,396] Finished trial#97 resulted in value: 198.58743888360596. Current best value is 5.240658892491164e-11 with parameters: {'x': 1.9973094165081346}.
[I 2019-06-26 22:50:06,431] Finished trial#98 resulted in value: 44.84344891326348. Current best value is 5.240658892491164e-11 with parameters: {'x': 1.9973094165081346}.
[I 2019-06-26 22:50:06,465] Finished trial#99 resulted in value: 3.433404666025541. Current best value is 5.240658892491164e-11 with parameters: {'x': 1.9973094165081346}.

{'x': 1.9973094165081346}
```

無事 2.0 に近い値が出てきた。めでたしめでたし。
