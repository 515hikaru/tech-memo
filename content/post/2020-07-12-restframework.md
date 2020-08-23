+++
title = "Django Restframework Serialzier の read_only および write_only"
author = ["515hikaru"]
date = 2020-07-12T17:00:00+09:00
draft = true
stylesheet = "post.css"
+++

Django には djang-rest-framework という拡張があり、Django で API を提供するときはよく使われていると思う。

[![encode/django-rest-framework - GitHub](https://gh-card.dev/repos/encode/django-rest-framework.svg?fullname=)](https://github.com/encode/django-rest-framework)

以後長いので django-rest-framework を単に rest-framework と書くことにする。

この rest-framework の基本的なオブジェクトとして Serializer というものがある。Serializer は Django 本体の Form オブジェクトに近くて、入力の validation だったり、値の取得・加工などをこなすオブジェクトだ。

例えばこんな風に使う。

```python
# serializer.py
from rest_framework import serializers

class GreetingSerializer(serializers.Serializer):
    name = serializers.CharField(max_length=100)
```

```python
from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework.viewsets import ViewSet

from .serializer import GreetingSerializer


class GreetingViewset(ViewSet):

    def create(self, request):
        serializer = GreetingSerializer(data=request.data)
        if not serializer.is_valid():
            return Response({'message': 'What\'s your name?'})
        name = serializer.data['name']
        return Response({'message': f'Hello, {name}!'})
```

これで然るべきところに `{"name": "515hikaru"}` を POST すると `{"message": "Hello, 515hikaru!"}` が帰ってくる。`name` が空で送信したりすると、`"What's your name?"` が帰ってくる。

というのが基本的な使い方。でも実は Serializer って JSON を返すときにもふつうに使える。入力と出力の JSON の形式が違うなんてことはふつうにあるだろう。