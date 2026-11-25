-- À exécuter une fois (phpMyAdmin > onglet SQL, ou client mysql en root).
-- Les tables sont créées par Hibernate (ddl-auto=update).
CREATE DATABASE IF NOT EXISTS gestusers_v4
  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE USER IF NOT EXISTS 'app'@'localhost'  IDENTIFIED BY 'mot_de_passe_app';
CREATE USER IF NOT EXISTS 'app'@'127.0.0.1' IDENTIFIED BY 'mot_de_passe_app';
GRANT ALL PRIVILEGES ON gestusers_v4.* TO 'app'@'localhost';
GRANT ALL PRIVILEGES ON gestusers_v4.* TO 'app'@'127.0.0.1';
FLUSH PRIVILEGES;
