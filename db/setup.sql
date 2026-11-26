-- ec_site の表を作る紙


DROP TABLE IF EXISTS 表の名前;
-- 上記コマンドは作っている間だけ便利。データが入ったら**危ない**ので、そのとき外すかどうかを決める

CREATE TABLE users(
    user_id INT AUTO_INCREMENT NOT NULL,
    user_name VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    create_date DATE NOT NULL DEFAULT CURRENT_DATE,
    update_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id)
);
