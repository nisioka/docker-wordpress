# docker-wordpress

WordPressをdocker上で動かす。  
WordPress本体とMySql(MariaDB)をdocker-composeで接続起動させる。

## in develop

### できること

- localhostでの動作を想定。
  - 自己署名でのhttps接続できるように。(うまくいかないよう。httpでの接続が可能ならそれが無難。)
  - パスワードとかベタ書き。
- phpmyadmin 導入済み
- Search-Replace-DB-master の導入も想定。
  - [ install_here.txt](Search-Replace-DB-master%2F%20install_here.txt) にインストールすればDB置換等ができる。

### 移行方法

構築済みのWordPressサイトをローカルにコピーする場合、以下の手順で行う。
1. WPbukupプラグインでバックアップが取られていることを想定。
  - [backup_wp-content](backup_wp-content) にwp-contentに置くべきバックアップファイルを配置する。
  - 画像ファイルをcdnに置いてたりしている場合も落としてきて[uploads](backup_wp-content%2Fuploads)に置く。(後でDBのURL変更作業も必要)
2. [install_here.txt](Search-Replace-DB-master%2F%20install_here.txt)に従って[Search-Replace-DB-master](https://interconnectit.com/search-and-replace-for-wordpress-databases/)をインストール
3. docker-compose up -d でコンテナを起動。
4. アクセスできる。
  - http://localhost でwordpress
  - https://localhost でwordpress(自己署名SSL)
  - http://localhost:3001 でphpmyadmin
  - http://localhost/Search-Replace-DB-master でSearch-Replace-DB-master
    - 適宜コンテンツのパスを「http://localhost」に置換したりする。 

