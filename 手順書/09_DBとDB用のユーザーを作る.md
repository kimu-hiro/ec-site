# 09 DB と、DB 用のユーザーを作る（Mac）

## 何のためか

08 で描いた「倉庫の設計図」の、**倉庫の建物と、倉庫の鍵**を作る段。
棚（表）は 10・11 で作る。09 は建物と鍵だけ。

```
MariaDB（Mac の倉庫番。もう入っている）
  ↓ 建てる
ec_site（倉庫＝DB）
  ↓ 合鍵を作る
ec_user（この倉庫だけ開けられる係）
```

- 新しく覚えること：SQL の「作る」命令（`CREATE`）と「鍵を渡す」命令（`GRANT`）
- 新しく入れるもの：無い（MariaDB はもう入っている）
- 作るのは **Mac の中だけ**。サーバー（エックスサーバー）は、
  支援員さんから DB 名・MySQL ユーザー名・パスワードをもらっている。
  つまり、サーバーの倉庫と鍵は**もうできている**ので、09 はやらない

### なぜフォルダは ec-site、DB は ec_site なのか

名前は似ているが別のもの。形のちがいは直し忘れではない。

```
ec-site/          ← フォルダ・GitHub（ハイフン）
  └ htdocs/
      └ ec_site/  ← 課題で決められた置き場所
ec_site           ← DB（MariaDB の中）
ec_user           ← DB 用のユーザー
```

- SQL では `-` は引き算の記号。DB 名に使うと、
  ``USE `ec-site`;`` のようにバッククォート（`` ` ``）で
  囲まないと `error in your SQL syntax near '-site'` が出る
- 07 のコーディング規約で、スネークケース
  （snake_case、単語を `_` でつなぐ書き方）と決めている
- フォルダと GitHub がハイフンなのは、URL やコマンドで
  打ちやすいからの慣例

### なぜ root（親鍵）で PHP からつながないのか

MariaDB には最初から `root` という、全部の倉庫を開けられる親鍵がある。
PHP からも root でつなげるが、そうしない。

| 鍵 | 開けられる所 | もし盗まれたら |
|---|---|---|
| root | 全部の倉庫（DAM の DB もふくむ） | 全部やられる |
| ec_user | `ec_site` だけ | `ec_site` だけですむ |

必要な所だけ開けられる鍵を渡すことを、**最小権限**
（least privilege、least＝いちばん少ない、privilege＝権限）と言う。
サーバーでもらった MySQL ユーザーも、この形になっている。

### なぜ `setup.sql` にまだ書かないのか

`setup.sql`（表を作る SQL をまとめた紙）は 10 から作り、git に入れる。
09 の命令は、そこには入れずに、ターミナルで直接打つ。

- 鍵を作る命令には、**パスワードがそのまま入る**。
  GitHub の `ec-site` は Public（だれでも見られる）なので、git に入れない
- サーバーでは倉庫と鍵がもうあるので、09 の命令はサーバーでは使わない。
  `setup.sql` には、Mac でもサーバーでも同じに使える「表の作り方」だけを書く

## できあがりの形

ファイルは増えない。MariaDB の中に、倉庫と鍵が1つずつ増える。

```
MariaDB
  ├ （前からある DB たち）
  └ ec_site   ← 今日作る（中はまだ空）
ユーザー
  └ ec_user   ← 今日作る（ec_site だけ開けられる）
```

## 1. 倉庫番が起きているか確かめる

```bash
brew services list
```

- `brew services`：Homebrew で入れた物を、裏で動かし続ける係の一覧

`mariadb` の行が `started` なら OK。

`started` でなければ、起こす。

```bash
brew services start mariadb
```

## 2. 倉庫番に話しかける

```bash
mariadb
```

Homebrew の MariaDB は、Mac のユーザー名で、パスワードなしで入れる
（Mac にログインしている人＝本人、とみなす仕組み）。

入れると、こう出る。

```
MariaDB [(none)]>
```

- `(none)`：今どの倉庫も選んでいない、という意味
- ここから先は SQL を打つ場所。ターミナルのコマンドとはちがう
- 抜けるときは `exit`

入れなかったら、「つまずいたら」の表を見る。

## 3. 今ある倉庫を見る

```sql
SHOW DATABASES;
```

- SQL は、**最後の `;`（セミコロン）までが1つの命令**。
  `;` を忘れると、`->` が出て続きを待つ。そのときは `;` だけ打って Enter

`ec_site` がまだ無いことを確かめる。

見覚えのない倉庫が並ぶが、**MariaDB が自分の仕事に使う棚**。消さない。

```
DAM                ← 自分の DAM プロジェクト
information_schema ← DB の案内板（どんな表・列があるか。読むだけ）
mysql              ← 鍵の名簿（ユーザーと権限）
performance_schema ← 速さの計測器
sys                ← 計測器を読みやすくした窓口
test               ← 中身なしの空部屋（入れたときにできる名残）
```

## 4. 倉庫を作る

倉庫の名前は `ec_site`。
文字の種類は `utf8mb4` にする（日本語も絵文字も入る。059 の風呂勉で話した）。

ヒント：

- 調べる言葉：`MariaDB CREATE DATABASE CHARACTER SET`
- 命令の形は `CREATE DATABASE 倉庫の名前 …;`

作ったら、もう一度 `SHOW DATABASES;` で、`ec_site` が出るか確かめる。

## 5. 鍵（ユーザー）を作る

ユーザーの名前は `ec_user`。パスワードは**自分で決める**。

- パスワードは、この手順書にも、git にも、PARA にも Notion にも書かない。
  Mac の「パスワード」アプリに控える（サーバーの情報と同じ扱い）
- Claude にも見せない。画面を貼るときは、パスワードの所を消してから

命令の形：

```sql
CREATE USER 'ec_user'@'localhost' IDENTIFIED BY 'ここに決めたパスワード';
```

| 部分 | 意味 |
|---|---|
| `'ec_user'` | 鍵の名前 |
| `@'localhost'` | この Mac の中からだけ使える鍵（外の機械からは使えない） |
| `IDENTIFIED BY` | identified＝本人と確かめる。「このパスワードで本人と確かめる」 |

## 6. 鍵に、開けられる倉庫を教える

5 で作っただけの鍵は、まだどの倉庫も開けられない。
「`ec_site` の中なら何でもしてよい」と教える。

ヒント：

- 調べる言葉：`MariaDB GRANT ALL PRIVILEGES`
- `ec_site` の中の全部の表、は `ec_site.*` と書く
  （`*` ＝ 全部。`*.*` にすると全部の倉庫になってしまうので注意）

## 7. 鍵で入れるか確かめる

いったん `exit` で抜けて、今度は `ec_user` で入る。

```bash
mariadb -u ec_user -p
```

- `-u`：user ＝ 入る人の名前
- `-p`：password ＝ パスワードを聞いてもらう
  （`-p` のあとにパスワードを続けて書かない。画面と履歴に残るため）

入れたら、倉庫を見る。

```sql
SHOW DATABASES;
```

`ec_site` と、`information_schema`（どのユーザーにも見える、DB の案内板）
だけが出れば OK。**DAM の DB などが見えない**のが、最小権限になっている印。

## 8. Claude に見せる

7 の `SHOW DATABASES;` の画面を貼る（パスワードは写っていないはず）。

## つまずいたら

| 困ったこと | 直し方 |
|---|---|
| `mariadb` で `Access denied` | `sudo mariadb` で入る（`sudo`＝superuser do＝親の権限で動かす。Mac のログインパスワードを聞かれる） |
| `Can't connect to local server through socket` | 倉庫番が寝ている。手順 1 の `brew services start mariadb` |
| `->` が出て止まった | `;` を忘れている。`;` だけ打って Enter |
| `ERROR 1064 … syntax` で `near 'DATABASE'` | 命令の綴りちがい。倉庫の一覧は `DATABASE` ではなく `SHOW DATABASES;`（複数形） |
| `ERROR 1007 … database exists` | もう作ってある。`SHOW DATABASES;` で確かめる |
| `ERROR 1396 … CREATE USER failed` | 同じ名前の鍵がもうある。`SELECT user, host FROM mysql.user;` で確かめる |
| 7 で `Access denied for user 'ec_user'` | パスワードの打ちまちがい、または 6 をやっていない |
| パスワードを忘れた | root で入って `ALTER USER 'ec_user'@'localhost' IDENTIFIED BY '新しいパスワード';` |

## できたら

- [ ] `ec_site` を作った（utf8mb4）
- [ ] `ec_user` を作り、パスワードを「パスワード」アプリに控えた
- [ ] `ec_user` に `ec_site` だけの権限を渡した
- [ ] `ec_user` で入って、`ec_site` だけが見えた
- [ ] Claude に見せた

git に入れるファイルは無い（手順書は Claude が入れる）。

できたら、かかった時間を Claude に伝える。
`00_全体の道のり.md` の表には Claude が書く。
