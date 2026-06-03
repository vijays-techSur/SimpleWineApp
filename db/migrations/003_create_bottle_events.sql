CREATE TABLE bottle_events (
  event_id         UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  wine_id          UUID        NOT NULL
                     REFERENCES wines(wine_id) ON DELETE CASCADE,
  event_type       VARCHAR(10) NOT NULL
                     CHECK (event_type IN ('CONSUMED','GIFTED','OPENED')),
  event_date       DATE        NOT NULL
                     CHECK (event_date <= CURRENT_DATE),
  notes            VARCHAR(500),
  recipient        VARCHAR(200),     -- GIFTED events only; NULL for others
  tasting_note_id  UUID,             -- FK added below after tasting_notes created

  created_at       TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_bottle_events_wine_id    ON bottle_events(wine_id);
CREATE INDEX idx_bottle_events_event_date ON bottle_events(event_date DESC);
CREATE INDEX idx_bottle_events_event_type ON bottle_events(event_type);
