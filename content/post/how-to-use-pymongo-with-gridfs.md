---
title: "MongoDBをPythonで操作する with GridFS"
date: 2018-04-26T22:00:19+09:00
draft: false
categories: ["Python", "Package", "DataBase"]
---

# Python から MongoDB(with GridFS)を操作する

MongoDB は `bson` という `json` のような形式でデータを保存できるデータベース。あまり背景は知らないのだけれど、MySQL のような RDBMS(Relational Database Management System)とは異なる思想のデータベース。

今回は Python から MongoDB を使う方法についてごにょごにょと書く。

# モジュールの構成

Python から MongoDB を活用するには `pymongo` というモジュールを利用するのがよい。あまりドキュメントが親切ではないので、ちょいちょい GitHub を見ながら大体の構成を把握する。

[mongodb/mongo\-python\-driver: PyMongo \- the Python driver for MongoDB](https://github.com/mongodb/mongo-python-driver)

提供されているモジュールは `bson`, `gridfs`, `pymongo` である。直接データベースをつなぐのに必要なものが定義されているのが `pymongo` で、GridFS というファイルシステムを利用する場合は `gridfs` を利用する必要がある。

# とりあえず使う

とりあえず使うには `pymongo` をインストールするのと MongoDB を用意する必要がある。

`pymongo` のインストールは `pip` でいい。

```
$ pip install pymongo
```

MongoDB を用意するのは、ホストにインストールしてもいいが、 Docker コンテナをひょいっと立てるのが楽。

```
$ docker run -p 27017:27017 mongo:3.6.3
```

この状態で、次のスクリプトを実行してもエラーが出なければ正常に MongoDB が稼働している。

```python
import pymongo

def main():
    client = pymongo.MongoClient(host='localhost', port=27017)
    print(client.server_info())

if __name__ == '__main__':
    main()
```

# GridFSを使いインサート

GridFS を利用してインサートするサンプル。

`gridfs.GridFS` はコンストラクタに MongoDB のデータベースオブジェクトを入れればよい。

```python
import pymongo
import gridfs

def main():
    client = pymongo.MongoClient(host='localhost', port=27017)
    database = client.testdb
    fs = gridfs.GridFS(database)

if __name__ == '__main__':
    main()

```

```python
import pymongo
import gridfs


def main():
    client = pymongo.MongoClient(host='localhost', port=27017)
    database = client.testdb
    fs = gridfs.GridFS(database)
    string = b'Hello, World!!'
    a = fs.put(string)

if __name__ == '__main__':
    main()

```

この状態でオブジェクトが `testdb` の `fs.files` コレクションに次のような形式のデータがはいる。

```
{
  "_id" : ObjectId("5ae1ac3fe5a5f02ee0763c31"),
  "md5" : "d66305ee66a6afc5b7ef7c6810a6f467",
  "chunkSize" : 261120,
  "length" : 14,
  "uploadDate" : ISODate("2018-04-26T10:38:55.705Z")
}
```

# データを取り出す

せっかくなので上記のデータを取り出すスクリプトを書いてみる。ここではオブジェクト ID がわかっている前提で書く。

```python
import pymongo
import bson
import gridfs

def main():
    client = pymongo.MongoClient(host='localhost', port=27017)
    database = client.testdb
    fs = gridfs.GridFS(database)
    id_str = '5ae1ac3fe5a5f02ee0763c31'  # 環境によってこの id が変わる
    get_obj = fs.get(bson.objectid.ObjectId(id_str))
    print(get_obj.read())  # b'Hello, World!'

if __name__ == '__main__':
    main()

```

`bson.objectid.ObjectId` id 文字列を入れてデータ型を変換しないと `fs.get` が動かないので注意。

実際には GridFS をデータ分析基盤として活用するためには `metadata` の設計などいろいろと考えることがあるのでもっと複雑になり、あんまり書きすぎるといろいろとまずいのでこれくらいにしておく。

# 検証環境

- Windows 10 Pro
- Docker for Windows
- Python 3.6.5
  - pymongo 3.6.1
- MongoDB 3.6.3
