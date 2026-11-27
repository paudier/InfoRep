-- Schéma FotoSharing (version 3)
-- La base (fotoshare) et l'utilisateur applicatif sont créés par l'image MariaDB (variables MARIADB_*).
-- Placé dans /docker-entrypoint-initdb.d/, ce script s'exécute UNE FOIS, au premier démarrage (volume vide).
-- Il n'y a donc ni CREATE DATABASE ni USE : le script s'applique à la base courante.

-- 1. Utilisateur
CREATE TABLE IF NOT EXISTS utilisateur (
  id            BIGINT AUTO_INCREMENT PRIMARY KEY,
  username      VARCHAR(50)  NOT NULL UNIQUE,
  email         VARCHAR(100) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL,                       -- BCrypt (60 caractères), jamais le mot de passe
  role          ENUM('USER','ADMIN','MODERATOR') NOT NULL DEFAULT 'USER',
  enabled       BOOLEAN      NOT NULL DEFAULT TRUE,          -- FALSE = compte désactivé (ban), données conservées
  created_at    TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 2. Photo
CREATE TABLE IF NOT EXISTS photo (
  id                 BIGINT AUTO_INCREMENT PRIMARY KEY,
  title              VARCHAR(100) NOT NULL,
  description        TEXT,
  original_filename  VARCHAR(255),                           -- affichage uniquement, jamais utilisé comme chemin
  storage_filename   VARCHAR(255) NOT NULL UNIQUE,           -- UUID + extension, nom sur le disque
  thumbnail_filename VARCHAR(255) UNIQUE,                    -- miniature (UUID), NULL si non générée
  content_type       VARCHAR(50)  NOT NULL,                  -- type MIME détecté (image/jpeg, image/png...)
  size_bytes         BIGINT       NOT NULL,
  visibility         ENUM('PRIVATE','PUBLIC') NOT NULL DEFAULT 'PRIVATE',
  owner_id           BIGINT       NOT NULL,
  created_at         TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_photo_owner FOREIGN KEY (owner_id) REFERENCES utilisateur(id) ON DELETE CASCADE,
  INDEX idx_photo_owner (owner_id),
  INDEX idx_photo_visibility_created (visibility, created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 3. Album (visible de son propriétaire seulement ; chaque photo garde ses propres droits)
CREATE TABLE IF NOT EXISTS album (
  id          BIGINT AUTO_INCREMENT PRIMARY KEY,
  name        VARCHAR(100) NOT NULL,
  description TEXT,
  owner_id    BIGINT       NOT NULL,
  created_at  TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_album_owner FOREIGN KEY (owner_id) REFERENCES utilisateur(id) ON DELETE CASCADE,
  INDEX idx_album_owner (owner_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 4. Liaison Album - Photo
CREATE TABLE IF NOT EXISTS album_photo (
  album_id BIGINT NOT NULL,
  photo_id BIGINT NOT NULL,
  PRIMARY KEY (album_id, photo_id),
  CONSTRAINT fk_ap_album FOREIGN KEY (album_id) REFERENCES album(id) ON DELETE CASCADE,
  CONSTRAINT fk_ap_photo FOREIGN KEY (photo_id) REFERENCES photo(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 5. Partage (un seul partage par couple photo / utilisateur)
CREATE TABLE IF NOT EXISTS partage (
  id               BIGINT AUTO_INCREMENT PRIMARY KEY,
  photo_id         BIGINT NOT NULL,
  user_id          BIGINT NOT NULL,
  permission_level ENUM('READ','COMMENT','ADMIN') NOT NULL DEFAULT 'READ',
  created_at       TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_partage_photo FOREIGN KEY (photo_id) REFERENCES photo(id) ON DELETE CASCADE,
  CONSTRAINT fk_partage_user  FOREIGN KEY (user_id)  REFERENCES utilisateur(id) ON DELETE CASCADE,
  UNIQUE KEY uk_photo_user (photo_id, user_id),
  INDEX idx_partage_user (user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 6. Commentaire
CREATE TABLE IF NOT EXISTS commentaire (
  id         BIGINT AUTO_INCREMENT PRIMARY KEY,
  text       TEXT   NOT NULL,
  photo_id   BIGINT NOT NULL,
  author_id  BIGINT NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_comm_photo  FOREIGN KEY (photo_id)  REFERENCES photo(id) ON DELETE CASCADE,
  CONSTRAINT fk_comm_author FOREIGN KEY (author_id) REFERENCES utilisateur(id) ON DELETE CASCADE,
  INDEX idx_comm_photo (photo_id, created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
