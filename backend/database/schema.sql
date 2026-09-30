CREATE TABLE IF NOT EXISTS tow_sessions (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  code CHAR(6) NOT NULL,
  driver_token CHAR(64) NOT NULL,
  pilot_token CHAR(64) DEFAULT NULL,
  status ENUM('waiting', 'active', 'ended') NOT NULL DEFAULT 'waiting',
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  accepted_at TIMESTAMP NULL DEFAULT NULL,
  ended_at TIMESTAMP NULL DEFAULT NULL,
  last_seen_at TIMESTAMP NULL DEFAULT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY tow_sessions_code_unique (code),
  UNIQUE KEY tow_sessions_driver_token_unique (driver_token),
  UNIQUE KEY tow_sessions_pilot_token_unique (pilot_token),
  KEY tow_sessions_status_created_index (status, created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS pilot_telemetry (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  session_id BIGINT UNSIGNED NOT NULL,
  vario_mps DECIMAL(8,3) NOT NULL,
  agl_m DECIMAL(10,2) NOT NULL,
  pressure_hpa DECIMAL(8,2) DEFAULT NULL,
  relative_altitude_m DECIMAL(10,2) DEFAULT NULL,
  client_timestamp_ms BIGINT UNSIGNED DEFAULT NULL,
  received_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY pilot_telemetry_session_received_index (session_id, received_at),
  CONSTRAINT pilot_telemetry_session_fk
    FOREIGN KEY (session_id) REFERENCES tow_sessions (id)
    ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
