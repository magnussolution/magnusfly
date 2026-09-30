ALTER TABLE pilot_profiles
  ADD COLUMN password_hash VARCHAR(255) NOT NULL AFTER country;
