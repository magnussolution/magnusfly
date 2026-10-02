CREATE TABLE IF NOT EXISTS pilot_profiles (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  username VARCHAR(32) NOT NULL,
  name VARCHAR(120) NOT NULL,
  email VARCHAR(190) NOT NULL,
  country VARCHAR(80) NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY pilot_profiles_username_unique (username),
  UNIQUE KEY pilot_profiles_email_unique (email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS tow_sessions (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  code CHAR(6) NOT NULL,
  pilot_username VARCHAR(32) NOT NULL,
  driver_token CHAR(64) NOT NULL,
  pilot_token CHAR(64) DEFAULT NULL,
  status ENUM('waiting', 'active', 'ended') NOT NULL DEFAULT 'waiting',
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  accepted_at TIMESTAMP NULL DEFAULT NULL,
  ended_at TIMESTAMP NULL DEFAULT NULL,
  pilot_stopped_at TIMESTAMP NULL DEFAULT NULL,
  last_seen_at TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY tow_sessions_code_unique (code),
  UNIQUE KEY tow_sessions_driver_token_unique (driver_token),
  UNIQUE KEY tow_sessions_pilot_token_unique (pilot_token),
  KEY tow_sessions_status_created_index (status, created_at),
  KEY tow_sessions_pilot_username_status_index (pilot_username, status, created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS pilot_telemetry (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  session_id BIGINT UNSIGNED NOT NULL,
  vario_mps DECIMAL(8,3) NOT NULL,
  agl_m DECIMAL(10,2) NOT NULL,
  pressure_hpa DECIMAL(8,2) DEFAULT NULL,
  relative_altitude_m DECIMAL(10,2) DEFAULT NULL,
  client_timestamp_ms BIGINT UNSIGNED DEFAULT NULL,
  location_json TEXT NULL,
  received_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY pilot_telemetry_session_received_index (session_id, received_at),
  CONSTRAINT pilot_telemetry_session_fk
    FOREIGN KEY (session_id) REFERENCES tow_sessions (id)
    ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
