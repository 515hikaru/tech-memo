---
title: "UbuntuでDjangoアプリケーションを動かす"
date: 2017-07-31T00:00:00+09:00
draft: false
tags: ["fromQiita", "Django"]
---

AWS のUbuntu インスタンスを使用して Django アプリケーションを AWS へデプロイする方法をまとめておく。

普段やっていることをそのまま書いた。AWS と銘打っているが AWS 以外でも大差はないと思うし、そもそも `ssh` 後の操作しか書いていない。

# 前提

* ubuntu16.04 LTS を使用していること
* AWSのインスタンスに ssh できること
* `sudo` できること
* ユーザー名は `ubuntu` として書く
* 管理者権限が必要なコマンドには `sudo` を書いた(はず)
* SELinux 関連の操作については書かない

# Nginx のインストール

1. インストール

    ```
    $ sudo apt-get install nginx
    ```

1. Nginx の設定をする。基本は `/etc/nginx/conf.d/site.conf` を編集すればよい
    * `/etc/nginx/nginx.conf` は状況によるので省略
    * 以下は `conf.d/site.conf` の1例

    ```
    server {
        listen  80;
        server_name example.com;
        charset     utf-8;

        location /static {
            alias /home/ubuntu/opt/repo/static;
        }

        location / {
            proxy_pass http://127.0.0.1:8080;
        }
    }
    ```


1. `sudo nginx -t` で問題なければ Nginx を実行する。

    ```
    $ sudo systemctl start nginx
    ```

4. `sudo systemctl status nginx` で `active` になっていればok

5.  `sudo systemctl enable nginx` しておく

# Python環境セットアップ

1. まずは Pyenv 経由で使用したい Python の version をインストールする。
    * `/usr/local/.pyenv` に Pyenv をインストール
    
    ```
    $ git clone https://github.com/pyenv/pyenv /usr/local/.pyenv
    $ echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bashrc
    $ echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bashrc
    echo 'eval "$(pyenv init -)"' >> ~/.bashrc
    ```

2. `pyenv install -l` で求めているPythonを探し、インストール
    * 必要なら `pyenv-virtualenv` などをインストールして仮想環境を作る

# Djangoアプリのセットアップ

1. 動作させたいアプリケーションを (お好みでディレクトリを作りその中に) `git clone` をする

    ```
    $ mkdir opt
    $ cd opt
    $ git clone ${REPO_URL}
    ```

1. `pip install -r requirements.txt` や (必要なら) `npm install` などで依存関係を解消し、アプリケーションを動かせる状態にする。

1. `pip install uwsgi` を実行しインストール(上の `requirements.txt` に含めておくことが望ましい)

1. `python manage.py collectstatic` をして静的ファイルを本番環境のディレクトリに配備
    * 上のNginxの設定例は `settings.py` に `STATIC_ROOT = os.path.join(BASE_DIR, 'static')` と書かれていることを前提にしている 

1. `uwsgi --http :8080 --wsgi-file ${PROJECT_NAME}/wsgi.py` を実行

1. ブラウザからアクセスしたり `curl` のレスポンスを確認するなどして、アプリが使用できるか、静的ファイルにアクセスできているかどうかを確認する

1. アプリが起動していることが確認できたらひとまず `uwsgi` プロセスを切る

# systemctlの設定

1. 無事アプリが動いたら Systemd 管理にする

2. `/etc/systemd/system/${SERVICE_NAME}.service` に次のような内容を書く

    ```
   [Unit]
   Description=uWSGI service for webapp
   [Service]
   User=root
   ExecStart=/usr/local/.pyenv/versions/path/to/uwsgi --http :8080 --wsgi-file ${PROJECT_NAME}/wsgi.py --chdir /home/ubuntu/opt/${REPO_NAME} --touch-reload .uwsgi-reload.txt --logto /var/log/uwsgi/uwsgi.log
   [Install]
   WantedBy=multi-user.target
   ```

3. ログファイルを作るために `sudo mkdir /var/log/uwsgi` をしておく

4. `sudo systemctl start ${SERVICE_NAME}` を実行

5. エラーなく起動すれば `sudo systemctl enable ${SERVICE_NAME}` を実行
