use mysql;

-- MySQL 8.0 (MySQL 5.7 includes two root records: root@'%' and root@'localhost', but 8.0 has only one)
UPDATE user SET Host='%' WHERE User='root';
FLUSH PRIVILEGES;

SET PASSWORD FOR 'root'@'%' = '123456';
GRANT ALL ON *.* TO 'root'@'%' WITH GRANT OPTION;
FLUSH PRIVILEGES;
