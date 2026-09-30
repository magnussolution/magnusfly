CREATE TABLE IF NOT EXISTS pilot_profiles (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  username VARCHAR(32) NOT NULL,
  name VARCHAR(120) NOT NULL,
  email VARCHAR(190) NOT NULL,
  country VARCHAR(80) NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY pilot_profiles_username_unique (username),
  UNIQUE KEY pilot_profiles_email_unique (email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

ALTER TABLE tow_sessions
  ADD COLUMN pilot_username VARCHAR(32) NOT NULL AFTER code,
  ADD KEY tow_sessions_pilot_username_status_index (pilot_username, status, created_at);
