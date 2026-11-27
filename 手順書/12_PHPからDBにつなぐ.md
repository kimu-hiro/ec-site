# 12 PHP から DB につなぎ、1行だけ画面に出す

## 何のためか

11 までで、倉庫（`ec_site`）と棚（5つの表）ができた。
でも、今それを見られるのは**ターミナルの中だけ**。

12 は、**お店の側（PHP）から倉庫をのぞく**、
最初の1本の線を通す段。

```
ブラウザ
  ↓ 住所を頼む
PHP（htdocs/ec_site/…）
  ↓ ここをつなぐのが 12
MariaDB（ec_site の棚）
```

- 新しく覚えること：PDO（PHP Data Objects）＝PHP から DB に
  つなぐための、標準の道具
- 新しく入れるもの：無い（PDO は PHP に最初から入っている）

### なぜ「1行だけ」なのか

ログイン画面も商品一覧も、やることは同じ。
「つないで、SQL を投げて、返ってきた物を画面に出す」。

その**いちばん短い形**を先に通しておけば、13 から先で
画面がうまく出ないとき、「つなぎ」は疑わなくて済む。

### 3つの置き場所（07 の規約で決めたこと）

```
htdocs/ec_site/   ← ブラウザから開く（Controller）
include/model/      ← DB とやり取りする部品（Model）
include/config/     ← 変わらない値（const.php）
```

12 では、最初に**捨てるファイル1つ**で動かしてから、
この置き場所に引っ越す。いきなり3つに分けない。

## 決めること：パスワードをどこに置くか

DB につなぐには4つの値が要る。

```
DB の名前      ec_site
つなぐ人       ec_user
パスワード     （自分で決めたもの）
どこの機械か   localhost
```

このうち**パスワードだけ**が、人に見せてはいけない値。
GitHub の `ec-site` は Public。上げると世界中から読める。
しかもサーバー側のパスワードは支援員さんからもらった物で、
自分だけの問題では済まない。

やり方は3つ。**ひろしが選ぶ。**

| 案 | やること | 良い所 | 困る所 |
|---|---|---|---
| A | `const.php` を git に入れず、`const.php.example`（値を空にした見本）だけ入れる | いちばん安全。現場でよく使う形 | 採点者が clone しても、そのままでは動かない |
| B | `const.php` は git に入れ、パスワードだけ別ファイル（例：`db_password.php`）にして、そちらを git に入れない | 定数ファイルは見せられる | ファイルが2つに分かれて、読む人が迷う |
| C | 全部 git に入れる | 手間なし | **パスワードが公開される。選ばない** |

- A か B にする。どちらでも課題の「定数は `const.php` に
  まとめる」は満たせる
- git に入れないファイルは `.gitignore` に1行足す
  （`sftp.json` と同じやり方）
- Mac とサーバーで**値がちがう**（Mac は `ec_user`、
  サーバーは支援員さんからもらった名前）

## できあがりの形

```
ec-site/
  ├ htdocs/ec_site/
  │    └ db_test.php     ← 1で作って、最後に消す
  └ include/
       ├ config/
       │    └ const.php  ← 5で作る（git に入れるかは別）
       └ model/
            └ db.php     ← 5で作る（つなぐ部品）
```

## 1. つながるかだけ試す

まず、**捨てる前提のファイル**を1つ作る。

`htdocs/ec_site/db_test.php`

やることは1つだけ。「つながったら、つながったと表示する」。

ヒント：

- 調べる言葉：`PHP PDO MySQL 接続`
- 形は `$pdo = new PDO(DSN, ユーザー名, パスワード);`
- うまくいかなかったときに備えて、`try` と `catch` で囲む

```php
try {
    // ここでつなぐ
    print "つながりました";
} catch (PDOException $e) {
    print "つながりません：" . $e->getMessage();
}
```

- `PDOException`＝PDO が投げるエラーの入れ物
- `getMessage()`＝エラーの文を取り出す
- **この2行があるかないかで、12 の難しさが変わる**。
  無いと、失敗したとき真っ白な画面しか出ない

動かすのは 01 と同じ小さなサーバー。

```bash
php -S localhost:8000 -t htdocs
```

ブラウザで `http://localhost:8000/ec_site/db_test.php`。

## 2. DSN を組み立てる

`new PDO()` の1つ目に渡すのが DSN。

- DSN＝Data Source Name＝「どの倉庫に、どうつなぐか」を1本の
  文字列にしたもの

ヒント：

- 調べる言葉：`PDO DSN mysql charset utf8mb4`
- 形は `mysql:host=…;dbname=…;charset=…`
- 文字の種類は `utf8mb4`。**ここで指定を忘れると、
  日本語がうまく行き来しない**（09 の倉庫の設定とは別の、
  「通り道」の文字設定）

## 3. エラーを黙らせない

PDO は、何も言わないと**失敗しても黙っている**ことがある。
つないだ直後に、1行だけ設定を足す。

ヒント：

- 調べる言葉：`PDO setAttribute ERRMODE_EXCEPTION`
- 意味：エラーが起きたら黙らず、例外（Exception）を投げる
- これを入れると、1で書いた `catch` が仕事をしてくれる

## 4. 1行だけ画面に出す

つながったら、次は棚をのぞく。

まだ商品が1つも入っていない。**数を数える**のが簡単。

ヒント：

- 調べる言葉：`PDO query fetch` / `SQL COUNT`
- SQL は `SELECT COUNT(*) FROM products;`
- `0` と表示されれば大成功（「棚はあるが、中は空」）

数ではなく中身を1行出したいときは、先にターミナルから
テスト用のデータを1件入れる（入れた物は、あとで消す）。

- 調べる言葉：`SQL INSERT INTO 書き方`

## 5. 置き場所を正す

ここまでで動いたら、規約どおりの場所に引っ越す。

1. `include/config/const.php` を作り、4つの値を定数にする
   - 調べる言葉：`PHP define 定数` または `const`
   - 名前は全部大文字（規約どおり。例：`DB_NAME`）
2. `include/model/db.php` に、「つなぐ」仕事だけの関数を作る
   - 1つの関数には1つの仕事（規約）。つなぐだけにする
3. `db_test.php` から、2つを `require_once` で読んで動かす
   - 調べる言葉：`PHP require_once 相対パス`
   - 02 で作った `include/` を、ここで初めて使う

動いたら、`db_test.php` は消してよい（13 から本物のページを
作るため）。消す前に画面の写真を撮ると、記録になる。

## 6. git に入れる

**上で選んだ案のとおりに**入れる。

```bash
git status
```

- パスワードの入ったファイルが出ていないか、**目で確かめる**
- 出ていたら `.gitignore` に足し、`git rm --cached 名前`
  で台から降ろす（`--cached`＝ファイルは残して管理から外す）

```bash
git add .
git status
git commit -m "PHP から DB につないで1行出す"
git push
```

## つまずいたら

| 困ったこと | 直し方 |
|---|---
| 真っ白な画面 | PHP がエラーを隠している。`try`・`catch` を書いたか確認。小さなサーバーを動かしたターミナルにも、エラーが出ている |
| `SQLSTATE[HY000] [1045] Access denied` | ユーザー名かパスワードがちがう。ターミナルで `mariadb -u ec_user -p ec_site` が通るかを先に試す |
| `SQLSTATE[HY000] [2002] No such file or directory` | 倉庫番につなげていない。`brew services list` で確認。`host=localhost` を `host=127.0.0.1` にすると直ることがある（前者は Mac の中の通路、後者は網（ネットワーク）経由） |
| `SQLSTATE[HY000] [1049] Unknown database` | DB 名の打ちまちがい。`ec_site` |
| `Class "PDO" not found` | PHP の PDO が無効。`php -m \| grep pdo` で確認 |
| 日本語が化ける | DSN の `charset=utf8mb4` を忘れている |
| `Failed opening required …` | `require_once` のパスがちがう。`__DIR__` を使うと確実（調べる言葉：`PHP __DIR__`） |

## できたら

- [ ] ブラウザに「つながりました」が出た
- [ ] `SELECT COUNT(*)` の結果が画面に出た
- [ ] パスワードの置き場所を決めて、`.gitignore` に書いた
- [ ] `git status` に、パスワードのファイルが無いと確かめた
- [ ] `const.php` と `db.php` に分けた
- [ ] Claude に見せた
- [ ] かかった時間を Claude に伝える（00 の表に書く）

---

Claude が気になったこと：サーバー側の値は Mac とちがう。
「Mac では動くが、上げると動かない」が起きやすい。
サーバーに上げるのは 13 以降でよいが、`const.php` を
「値だけ差し替えれば動く形」にしておくと、あとが楽。
