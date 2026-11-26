-- ec_site の表を作る紙


DROP TABLE IF EXISTS 表の名前;
-- 上記コマンドは作っている間だけ便利。データが入ったら**危ない**ので、そのとき外すかどうかを決める

CREATE TABLE users(
    user_id int auto_increment  not null,
    user_name varchar(100) unique not null,
    password_hash varchar(255) not null,
    create_date date not null default current_date,
    update_date datetime not null default current_timestamp on update current_timestamp,
    primary key (user_id)
);