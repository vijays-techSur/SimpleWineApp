CREATE TABLE user_settings (
  settings_id   UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  rating_scale  VARCHAR(10) NOT NULL DEFAULT 'STARS_5'
                  CHECK (rating_scale IN ('STARS_5','POINTS_100')),

  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Seed the single settings row on first run (idempotent)
INSERT INTO user_settings (rating_scale)
VALUES ('STARS_5')
ON CONFLICT DO NOTHING;
