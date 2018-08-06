# ESET Remote Administrator on Docker Compose

## イメージをビルドする

### コンポーネントの配置

まず、ESET Remote Administratorのコンポーネントをダウンロードして、展開しておく。
そして、サーバーとWebコンソールのファイルを、適当に配置する。

```sh
$ mv Component_Linux_x64/era.war eraconsole/
$ ls eraconsole
Dockerfile  era.war  tomcat.sh
$ mv Component_Linux_x64/Server-Linux-x86_64.sh eraserver/
$ ls eraserver
Dockerfile  eraserver.sh  Server-Linux-x86_64.sh
```

### MySQL ODBCのダウンロード

[ここ](https://dev.mysql.com/downloads/connector/odbc/5.3.html)からMySQL ODBCをダウンロードする。（バージョン5系統でないと動かないので注意。）
そして、`eraserver`以下に配置する。

```sh
$ ls eraserver/
Dockerfile  eraserver.sh  mysql-connector-odbc-5.3.10-linux-ubuntu16.04-x86-64bit  Server-Linux-x86_64.sh
```

### MySQLの立ち上げ

セットアップ中にMySQLへ接続するため、先にMySQLのインスタンスを立ち上げておく。
一時的に、MySQLにアクセスできるように、`ufw`でファイアウォールを開けておく。

```sh
# ufw allow 3306
```

### イメージのビルド

ホストのIPアドレスに合わせて、`eraserver/Dockerfile`の以下のIPアドレスを適宜変更する。

```
RUN echo "172.17.0.1 mysql" >> /etc/hosts && \
    /tmp/Server-Linux-x86_64.sh \
        --skip-license \
        --db-driver=MySQL \
        --db-type="MySQL Server" \
        --db-hostname=${DB_HOST} \
        --db-port=${DB_PORT} \
        --db-admin-username=${DB_ADMIN_USER} \
        --db-admin-password=${DB_ADMIN_PASS} \
        --db-user-username=${DB_USER} \
        --db-user-password=${DB_PASS} \
        --server-root-password=${ERA_ADMIN_PASS} \
        --cert-hostname=${ERA_HOST_NAMES} \
        --locale=ja-JP
```

あとは、ビルドが終わるのを待てば良い。

```sh
$ docker-compose build
...
$ docker-compose up -d
```

最後に、ファイアウォールをもとに戻しておく。

```sh
$ sudo ufw delete allow 3306
```

## デプロイ

- `ufw`で使うポートのファイアウォールを開ける
- `apache`か`nginx`などのリバースプロキシで、コンソールにアクセスできるようにする

## メモ

- イメージのビルド中は、専用のネットワークが用いられるため、他のイメージを参照できない
  - `network_mode: host`なども使えない
    - IPで指定すればホストにアクセス可能だが、ファイアウォールを開けておく必要がある
- `/etc/hosts`がDockerに管理されているために、変更できない
  - 永続的に変更するには、`docker-compose.yaml`に`extra_hosts`を追加する
    - ビルド時だけ参照するには、RUNの中では変更が保持されるので、`echo "..." > /etc/hosts && ...`が使える
- ESET Remote Administratorのインストーラが`/bin/systemctl`を叩くとエラーが発生する
  - https://forum.eset.com/topic/14670-installation-issue-failed-to-connect-to-bus/
- コンソールは`localhost`にサーバーがある前提でコネクションを行う
  - `eraconsole/tomcat.sh`にあるように、`WEB-INF`以下の`EraWebServerConfig.properties`を無理やり書き換えればよい
- 過去に使用していたデータベースからのマイグレーションであれば、`ProductInstanceID`という環境変数を指定すればよいらしい
  - 詳しくは`eraserver/eraserver.sh`をベースに調査が必要
