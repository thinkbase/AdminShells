use mysql;

-- MySQL 5.7
GRANT ALL ON *.* TO root@'%' IDENTIFIED BY '123456' WITH GRANT OPTION;
GRANT ALL ON *.* TO root@'localhost' IDENTIFIED BY '123456' WITH GRANT OPTION;

flush privileges;
