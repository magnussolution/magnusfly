ALTER TABLE tow_sessions ADD COLUMN pilot_stopped_at TIMESTAMP NULL DEFAULT NULL;
ALTER TABLE pilot_telemetry ADD COLUMN location_json TEXT NULL;
