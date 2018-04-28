---
title: "Haskell-jp もくもく会で勉強したことメモ"
date: 2018-04-29T00:00:00+09:00
draft: false
categories: ["Haskell", "Studying"]
---

[Haskell-jp もくもく会](https://haskell-jp.connpass.com/event/82494/)に参加してきた。

そこで勉強したメモ書きをここにあげておく。ちなみに読んでいた本は[『Haskell入門』](http://gihyo.jp/book/2017/978-4-7741-9237-6)

# FizzBuzz

条件分岐とかガード節とか `case` 文とかの確認に FizzBuzz をとりあえず書いた。2 章を読んでいると永遠に進めない気がした、という気持ちになったのでこれを書くことで文法を完全に理解したと思い込むことにした。

実際にはもちろんちょいちょい 2 章も参照しつつ進めました。

```haskell
-- FizzBuzz
import Control.Monad -- use forM

fizzBuzz :: Int -> String
fizzBuzz x = case x of n | n `mod` 15 == 0 -> "FizzBuzz"
                         | n `mod` 5 == 0 -> "Buzz"
                         | n `mod` 3 == 0 -> "Fizz"
                         | otherwise -> show n

doFizzBuzz :: [Int] -> [String]
doFizzBuzz xs = [fizzBuzz x | x <- xs]

main :: IO[()]
main = forM (doFizzBuzz [1..100]) putStrLn
```

Python のクセでリスト内包してしまったが、 `doFizzBuzz` は `map` でいいと書き終えてから気づく。

```haskell
doFizzBuzz :: [Int] -> [String]
doFizzBuzz = map fizzBuzz
```

# 型コンストラクタと型変数

## カインド

- `:t` では型をチェックする
  - 型は式と式の組み合わせを規定するもの
- `:k`, `:kind` はカインドをチェックする
  - カインドは型の組み合わせを規定するもの

```haskell
Prelude> :k Int
Int :: *
Prelude> :k String
String :: *
Prelude> :k (->)
(->) :: * -> * -> *
Prelude> :k IO
IO :: * -> *
```

`undefined` はどのような型付きでも定義できる (`undefined :: a` だから)が、カインドの規定を満たせていない場合は正しい型でないのでエラーになる。

```haskell
Prelude> :t undefined :: Int
undefined :: Int :: Int
Prelude> :t undefined :: Int Double

<interactive>:1:14: error:
    • Expecting one fewer argument to ‘Int’
      Expected kind ‘* -> *’, but ‘Int’ has kind ‘*’
    • In an expression type signature: Int Double
      In the expression: undefined :: Int Double
Prelude> :t undefined :: Maybe

<interactive>:1:14: error:
    • Expecting one more argument to ‘Maybe’
      Expected a type, but ‘Maybe’ has kind ‘* -> *’
    • In an expression type signature: Maybe
      In the expression: undefined :: Maybe
Prelude> :k Maybe
Maybe :: * -> *
Prelude> :t undefined :: Maybe Int
undefined :: Maybe Int :: Maybe Int
```

## 型変数

```haskell
Prelude> :t id
id :: a -> a
```

とかの `a` の部分。型は `Int` とかのように限定もできるし、汎用的な処理なら `a` とか `b` とかで変数化して定義する。

型変数には制約をかけることができる。例えば `show` は、

```haskell
Prelude> :t show
show :: Show a => a -> String
```

という型を持つ。ここで `a` を `Show` という型クラスに属するものに制限している。

型変数にもカインドがある。 `fmap` という関数を例にとる。

```haskell
Prelude> :t fmap
fmap :: Functor f => (a -> b) -> f a -> f b
```

`fmap` は `a` `b` `f` という 3 つの型変数を持っていて `a` と `b` は関数の引数や戻り値に使われているので kind は `*` である。`f` は型引数 `a` をとっているので `* -> *` である。

具体的には `a` や `b` は `Int` や `Char` が入り、 `f` には `Maybe` や `[]` や `IO` が入る。

# 代数的データ型

他の言語でのクラス定義などに相当する機能。ユーザー定義型。英語では Algebraic Data Type なので ADT と表記されることもあるみたい。

```
data 型コンストラクタ名 = データコンストラクタ名 フィールドの型1 フィールドの型2 ...`
```

とすればつくれる。

```haskell
Prelude> data Employee = NewEmployee Integer Bool String deriving (Show)
Prelude> :t NewEmployee
NewEmployee :: Integer -> Bool -> String -> Employee
-- パターンマッチで束縛できる
Prelude> NewEmployee age isManager name = employee
Prelude> age
39
Prelude> isManager
False
Prelude> name
"Subhash Knot"
```

`CmdOption` という型が `Integral` と `Bool` と `String` のいずれもサポートする場合。

```haskell
data CmdOption = COptInt Integer
               | COptBool Bool
               | COptStr String
               deriving(Show)

coptToInt :: CmdOption -> Int
coptToInt (COptInt n     ) = fromIntegral n
coptToInt (COptStr x     ) = read x
coptToInt (COptBool True ) = 1
coptToInt (COptBool False) = 0

main :: IO()
main = do
  let opt1 = COptInt 120
  let opt2 = COptStr "0x78"
  let opt3 = COptBool False
  print $ map coptToInt [opt1, opt2, opt3]
```

# レコード記法

上述のやり方だとフィールドは定義できてもフィールドの名前がなかった。 Haskell ではレコード記法で名前をつけられる。上述の `Employee` のフィールドに適切な名前をつける。

```haskell
-- sample08.hs
data Employee = NewEmployee { employeeAge :: Integer
                            , employeeIsManager :: Bool
                            , employeeName :: String
                            } deriving(Show)

employee :: Employee
employee = NewEmployee { employeeName = "515hikaru"
                       , employeeAge = 25
                       , employeeIsManager = False
                       }

main :: IO()
main = print employee
```

このとき、 `Employee` を定義した時点で関数 `employeeAge`, `employeeName`, `employeeIsManager` が定義される。

```haskell
Prelude> :l sample08.hs
[1 of 1] Compiling Main             ( sample08.hs, interpreted )
Ok, modules loaded: Main.
*Main> :t employeeAge
employeeAge :: Employee -> Integer
*Main> :t employeeIsManager
employeeIsManager :: Employee -> Bool
*Main> :t employeeName
employeeName :: Employee -> String
*Main>
```

よって、データを `employee` からフィールドの値をとるにはこの関数を作用させればよい。オブジェクト指向言語であれば値へのアクセスは `obj.property` などの記法が多いが、 Haskell では `property obj` という順番であることに留意。

```haskell
data Employee = NewEmployee { employeeAge :: Integer
                            , employeeIsManager :: Bool
                            , employeeName :: String
                            } deriving(Show)

employee :: Employee
employee = NewEmployee { employeeName = "515hikaru"
                       , employeeAge = 25
                       , employeeIsManager = False
                       }

main :: IO()
main = do
  putStrLn $ employeeName employee
  putStrLn $ show $ employeeAge employee
  putStrLn $ show $ employeeIsManager employee
-- 515hikaru 25 False
```

あくまでも通常の関数なので名前の衝突も起こりうることにも注意。

# 再帰的な定義

二分木による辞書を代数的データ型で実現する。

```haskell
-- sample09.hs
data TreeDict k v = TDEmpty
                  | TDNode k v (TreeDict k v) (TreeDict k v)
                  deriving(Show)

-- k: key は Ord の型制約をつける
insert :: Ord k => k -> v -> TreeDict k v -> TreeDict k v
-- 空 Node にアクセスする際には自身に insert し空 Node をぶら下げる
insert k v TDEmpty = TDNode k v TDEmpty TDEmpty
insert k v (TDNode k' v' l r)
  | k < k'    = TDNode k' v' (insert k v l) r  -- 挿入元が挿入先より小さいので左にぶら下げる
  | k > k'    = TDNode k' v' l              (insert k v r) -- 挿入元が挿入先より大きいので右にぶら下げる
  | otherwise = TDNode k' v  l              r  -- キーが同じなので上書き
```

ちょっと使ってみる。

```haskell
Prelude> :l sample09.hs
[1 of 1] Compiling Main             ( sample09.hs, interpreted )
Ok, modules loaded: Main.
*Main> let hoge = insert 32 "foo" TDEmpty
*Main> hoge
TDNode 32 "foo" TDEmpty TDEmpty
*Main> insert 43 "bar" hoge
TDNode 32 "foo" TDEmpty (TDNode 43 "bar" TDEmpty TDEmpty)
```

`hoge` に `43` , `bar` をインサートすると、 `hoge` のひだりに `43, bar` のノードが入り、そのノードに `TDEmpty` がまた左右に下がる。

`insert` とか `lookup'` とかを実装。

```haskell
data TreeDict k v = TDEmpty
                  | TDNode k v (TreeDict k v) (TreeDict k v)
                  deriving(Show)

-- k: key は Ord の型制約をつける
insert :: Ord k => k -> v -> TreeDict k v -> TreeDict k v
-- 空 Node にアクセスする際には自身に insert し空 Node をぶら下げる
insert k v TDEmpty = TDNode k v TDEmpty TDEmpty
insert k v (TDNode k' v' l r)
  | k < k'    = TDNode k' v' (insert k v l) r  -- 挿入元が挿入先より小さいので左にぶら下げる
  | k > k'    = TDNode k' v' l              (insert k v r) -- 挿入元が挿入先より大きいので右にぶら下げる
  | otherwise = TDNode k' v  l              r  -- キーが同じなので上書き

dict :: TreeDict String Integer
dict = insert "hiratara" 39
     . insert "shu1" 0
     . insert "masahiko" 63
     $ TDEmpty

lookup' :: Ord k => k -> TreeDict k v -> Maybe v
lookup' _ TDEmpty = Nothing
lookup' k (TDNode k' v' l r)
  | k < k'    = lookup' k l
  | k > k'    = lookup' k r
  | otherwise = Just v'

main :: IO()
main = do
  print $ lookup' "hiratara" dict
  print $ lookup' "shu1" dict
  print $ lookup' "foo" dict
```

もちろん[標準ライブラリ](http://hackage.haskell.org/package/containers-0.5.11.0/docs/Data-Map.html)にある。

# 感想

全然交流とかはしなかったけど、Haskellの本を数時間ずっと読んでいるみたいな時間はなかなか自分では取れないのでよかった。

思っていたよりは進まなかったけど、よくあることなので気にしないことにします。あと本当はモナドの章を読もうと思って参加したんだけどそれ以前の思い出しとかしかできなかったのは仕様です。

次の節が型クラスの節くらいまで読んだので、そのうち型クラスの節とかモナドの章とかも頑張ります。
