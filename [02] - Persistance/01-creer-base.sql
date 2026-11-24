-- À exécuter UNE fois : phpMyAdmin (XAMPP) > onglet SQL, ou client mysql en root.
-- Les tables sont ensuite créées automatiquement par Hibernate (spring.jpa.hibernate.ddl-auto=update).
CREATE DATABASE IF NOT EXISTS user_management
  CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE USER IF NOT EXISTS 'app'@'localhost'  IDENTIFIED BY 'mot_de_passe_app';
CREATE USER IF NOT EXISTS 'app'@'127.0.0.1' IDENTIFIED BY 'mot_de_passe_app';
GRANT ALL PRIVILEGES ON user_management.* TO 'app'@'localhost';
GRANT ALL PRIVILEGES ON user_management.* TO 'app'@'127.0.0.1';
FLUSH PRIVILEGES;
