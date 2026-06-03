CREATE TABLE tasting_notes (
  note_id          UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  wine_id          UUID        NOT NULL
                     REFERENCES wines(wine_id) ON DELETE CASCADE,
  bottle_event_id  UUID
                     REFERENCES bottle_events(event_id) ON DELETE SET NULL,

  date_tasted      DATE        NOT NULL
                     CHECK (date_tasted <= CURRENT_DATE),
  appearance       VARCHAR(500),
  aroma            VARCHAR(500),
  flavor           TEXT        CHECK (char_length(flavor) <= 1000),
  finish           VARCHAR(500),
  personal_rating  NUMERIC(5,1),
  rating_scale     VARCHAR(10) CHECK (rating_scale IN ('STARS_5','POINTS_100')),
  would_buy_again  VARCHAR(5)  CHECK (would_buy_again IN ('YES','NO','MAYBE')),
  occasion         VARCHAR(200),
  guest_feedback   VARCHAR(500),

  created_at       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at       TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_tasting_notes_wine_id ON tasting_notes(wine_id);
CREATE INDEX idx_tasting_notes_date    ON tasting_notes(date_tasted DESC);
CREATE INDEX idx_tasting_notes_rating  ON tasting_notes(personal_rating DESC NULLS LAST);

-- Add FK from bottle_events to tasting_notes (deferred to after tasting_notes is created)
ALTER TABLE bottle_events
  ADD CONSTRAINT fk_bottle_events_tasting_note
  FOREIGN KEY (tasting_note_id)
  REFERENCES tasting_notes(note_id)
  ON DELETE SET NULL;
