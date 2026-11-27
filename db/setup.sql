-- ec_site の表を作る紙。
-- テーブルは作る時には主側から、消す時には従属側から行う。
DROP TABLE IF EXISTS carts;
DROP TABLE IF EXISTS photos;
DROP TABLE IF EXISTS stocks;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS users;
-- 上記コマンドは作っている間だけ便利。データが入ったら**危ない**ので、そのとき外す

CREATE TABLE users(
    user_id INT AUTO_INCREMENT NOT NULL,
    user_name VARCHAR(100) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    create_date DATE DEFAULT CURRENT_DATE NOT NULL,
    update_date DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP NOT NULL,
    PRIMARY KEY (user_id),
    UNIQUE KEY(user_name)
);
-- DATEは日付のみ。DATETIMEは日時。DEFAULTで自動で添付。ON UPDATE 〇〇で動きがあれば逐一〇〇に更新される

CREATE TABLE products(
    product_id INT AUTO_INCREMENT NOT NULL,
    product_name VARCHAR(255) NOT NULL,
    price INT NOT NULL,
    public_flg BOOLEAN NOT NULL,
    create_date DATE DEFAULT CURRENT_DATE NOT NULL,
    update_date DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP NOT NULL,
    PRIMARY KEY(product_id)
);

CREATE TABLE stocks(
    stock_id INT AUTO_INCREMENT NOT NULL,
    product_id INT NOT NULL,
    stock_qty INT NOT NULL,
    create_date DATE DEFAULT CURRENT_DATE NOT NULL,
    update_date DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP NOT NULL,
    PRIMARY KEY(stock_id),
    FOREIGN KEY(product_id) REFERENCES products(product_id) 
);

CREATE TABLE photos(
    photo_id INT AUTO_INCREMENT NOT NULL,
    product_id INT NOT NULL,
    photo_path VARCHAR(255) NOT NULL,
    create_date DATE DEFAULT CURRENT_DATE NOT NULL,
    update_date DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP NOT NULL,
    PRIMARY KEY(photo_id),
    FOREIGN KEY(product_id) REFERENCES products(product_id)
);

CREATE TABLE carts(
    cart_id INT AUTO_INCREMENT NOT NULL,
    user_id INT NOT NULL,
    product_id INT NOT NULL,
    product_qty INT NOT NULL,
    create_date DATE DEFAULT CURRENT_DATE NOT NULL,
    update_date DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP NOT NULL,
    PRIMARY KEY(cart_id),
    FOREIGN KEY(user_id) REFERENCES users(user_id),
    FOREIGN KEY(product_id) REFERENCES products(product_id),
    UNIQUE KEY unique_user_product(user_id,product_id)
    -- UNIQUE KEYをまとめて書くことで複合キーになる
    -- また、名前をつける(unique_user_product)とエラー時に原因が特定しやすくなる
);
