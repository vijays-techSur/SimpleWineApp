CREATE TABLE storage_locations (
  location_id   UUID         PRIMARY KEY DEFAULT gen_random_uuid(),
  location_name VARCHAR(100) NOT NULL,
  CONSTRAINT uq_location_name UNIQUE (location_name),

  created_at    TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
  updated_at    TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);

-- Case-insensitive uniqueness (PostgreSQL functional index)
-- SQLite: enforce case-insensitivity in application layer
CREATE UNIQUE INDEX uq_location_name_ci
  ON storage_locations (LOWER(location_name));
