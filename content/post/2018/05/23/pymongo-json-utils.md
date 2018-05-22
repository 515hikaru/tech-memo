---
title: "PymongoのBSONとJSONの変換"
date: 2018-05-23T00:15:00+09:00
draft: false
---

なんかちょっとしたメモ。ちょっとしたことをしたいのにちょっとしたことを書きたくなるくらい `pymongo` は「ようわからん」と思っている時間が長かった。

# 背景

テストをするために特定のデータのみを持っているデータベースをテストを実行するたびに作る必要があった。そこで、必要なデータを `mongoexport` コマンドで JSON ファイルにし、その JSON を MongoDB にインサートする関数を作ろうと考えた。

コードにするとこんな感じ。

```python
import unittest

class TestSomeCase(unittest.TestCase):
  @classmethod
  def setUpClass(cls):
    # ここにデータをインサートする処理

  def test_case1(self):
    # テスト ...
```

# BSON と JSON の変換

## mongoexport の生成物

`mongoexport` コマンドで出力されるのは、JSON にはできるけれど、じつはそのままの形式ではインサートができない。

実際に MongoDB にインサートしてそれをファイル化してみる。今回は雑に JSON を作ってそれを MongoDB に入れた。データの中身に全く意味はない。

```python
import json
import pymongo
import gridfs

def main():
    obj = {
        'foo': 123,
        'bar': 'poyopoyo'
        }
    lists = [obj] * 100
    client = pymongo.MongoClient('mongodb://localhost:27017/test')
    db = client.get_database()
    fs =gridfs.GridFS(db)
    fs.put(json.dumps(lists).encode())

if __name__ == '__main__':
    main()
```

このスクリプトを実行すると、GridFSを用いて 100 個のオブジェクトが入っているリストが生成できる。

筆者の環境で、 `mongoexport` を実行すると下記のようになった。

```
$ mongoexport --jsonArray -d test -c fs.files --out=fsfiles.json
2018-05-22T23:58:26.066+0900	connected to: localhost
2018-05-22T23:58:26.068+0900	exported 1 record
$ cat fsfiles.json
[{"_id":{"$oid":"5b042e2e420def1997501078"},"md5":"6894371a887c8cdde38936c1de883b99","chunkSize":261120,"length":3300,"uploadDate":{"$date":"2018-05-22T14:50:22.789Z"}}]
```

## JSON の適切なオブジェクトへの変換

この `"$oid":"..."` などが曲者で、これは実際には MongoDB の中では `"_id" : ObjectId("5b042e2e420def1997501078")` というペアで格納されているデータになる。この JSON ファイルを直接 `load` した GridFS にインサートしようとしても失敗する。

実際に、さきほどインサートしたデータを `db.dropDatabase()` し、さきほどダンプした `fsfiles.json` と `fschunks.json` を使用してインサートしよう。

以下のスクリプトは動かない。

```python
import json
import pymongo


def main():
    client = pymongo.MongoClient(host='localhost', port=27017)
    database = client.test

    with open('./fsfiles.json', 'r') as file:
        fsfiles = json.load(file)

    database.fs.files.insert_many(fsfiles)


if __name__ == '__main__':
    main()  # bson.errors.InvalidDocument: key '$oid' must not start with '$'
```

インサートする前に `json` を `bson` に変更する必要がある。

## json_util

さすがに `pymongo` には用意されている。 `bson.json_util.loads` 関数がそれだ。[ドドキュメントはこちら](https://github.com/mongodb/mongo-python-driver/blob/master/bson/json_util.py)

ドキュメントのコードをそのまま借りると、要はこういうことができる:

```python
>>> from bson.json_util import loads
>>> loads('[{"foo": [1, 2]}, {"bar": {"hello": "world"}}, {"code": {"$scope": {}, "$code": "function x() { return 1; }"}}, {"bin": {"$type": "80", "$binary": "AQIDBA=="}}]')
[{u'foo': [1, 2]}, {u'bar': {u'hello': u'world'}}, {u'code': Code('function x() { return 1; }', {})}, {u'bin': Binary('...', 128)}]
```

`$` で始まるキーを適切に MongoDB にインサートできる形式にしてくれる。これをつかって実際にインサートするには次のような処理をかけば良い:

```python
import json
import pymongo
from bson.json_util import loads



def main():
    client = pymongo.MongoClient(host='localhost', port=27017)
    database = client.test

    with open('./fsfiles.json', 'r') as file:
        fsfiles = json.load(file)

    fs_bson = loads(json.dumps(fsfiles))  # loads は文字列のみを受け付けるので1回 JSON 文字列に dump している
    database.fs.files.insert_many(fs_bson)


if __name__ == '__main__':
    main()
```

これでエラーが起きずにインサートできる。

# まとめ

- `mongoexport` コマンドを利用すると JSON 形式でダンプできる。
- しかしそのままインサートしてもデータベースを復元できない。 `pymongo` の場合は `bson.json_util` に定義されている関数を利用して変換をかける必要がある。
- `bson.json_util.load` がほしいな。。。
