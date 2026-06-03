---

## 3. Data Model

### 3.1 Entity Relationship Diagram

```
┌──────────────────────┐
│   storage_locations  │
│──────────────────────│
│ location_id  PK      │
│ location_name        │
│ created_at           │
│ updated_at           │
└──────────┬───────────┘
           │ SET NULL on delete
           │ 1 ──── 0..*
┌──────────▼───────────────────────────────────────────────┐
│                          wines                           │
│──────────────────────────────────────────────────────────│
│ wine_id             PK                                   │
│ wine_name           NOT NULL                             │
│ producer            NOT NULL                             │
│ vintage_year        NOT NULL · CHECK 1900-2200           │
│ wine_type           NOT NULL · ENUM                      │
│ grape_variety                                            │
│ country                                                  │
│ region                                                   │
│ appellation                                              │
│ bottle_size         DEFAULT 750ML · ENUM                 │
│ quantity            NOT NULL DEFAULT 1 · CHECK >= 0      │
│ is_open             NOT NULL DEFAULT FALSE               │
│ storage_location_id FK → storage_locations (nullable)   │
│ location_unknown    NOT NULL DEFAULT FALSE               │
│ purchase_date                                            │
│ purchase_source                                          │
│ purchase_price      NUMERIC(10,2)                        │
│ estimated_value     NUMERIC(10,2)                        │
│ drink_window_start  CHECK 1900-2200                      │
│ drink_window_end    CHECK 1900-2200                      │
│ notes               TEXT max 5000                        │
│ latest_rating       NUMERIC(5,1) [denormalized]          │
│ latest_rating_scale [denormalized]                       │
│ latest_rating_date  [denormalized]                       │
│ created_at          NOT NULL                             │
│ updated_at          NOT NULL                             │
└──────────┬───────────────────────────────────────────────┘
           │
     ┌─────┴──────────────────────────────┐
     │ CASCADE on delete                  │ CASCADE on delete
     │ 1 ──── 0..*                        │ 1 ──── 0..*
┌────▼─────────────────┐    ┌─────────────▼────────────────┐
│    bottle_events     │    │        tasting_notes         │
│──────────────────────│    │──────────────────────────────│
│ event_id      PK     │    │ note_id         PK           │
│ wine_id       FK     │    │ wine_id         FK           │
│ event_type    ENUM   │    │ bottle_event_id FK (null OK) │
│ event_date    NOT NULL│   │ date_tasted     NOT NULL     │
│ notes         500ch  │    │ appearance      500ch        │
│ recipient     200ch  │    │ aroma           500ch        │
│ tasting_note_id FK◄──┼────│ flavor          1000ch       │
│               (null) │    │ finish          500ch        │
│ created_at           │    │ personal_rating NUMERIC(5,1) │
└──────────────────────┘    │ rating_scale    ENUM         │
                            │ would_buy_again ENUM         │
                            │ occasion        200ch        │
                            │ guest_feedback  500ch        │
                            │ created_at                   │
                            │ updated_at                   │
                            └──────────────────────────────┘

┌──────────────────────┐
│    user_settings     │   (singleton — 1 row)
│──────────────────────│
│ settings_id   PK     │
│ rating_scale  ENUM   │
│ created_at           │
│ updated_at           │
└──────────────────────┘
```

**Relationship notes:**
- `storage_locations` → `wines`: one-to-many, SET NULL on location delete (FK becomes NULL, `location_unknown` flagged TRUE by app logic)
- `wines` → `bottle_events`: one-to-many, CASCADE DELETE
- `wines` → `tasting_notes`: one-to-many, CASCADE DELETE
- `bottle_events.tasting_note_id` → `tasting_notes`: optional link, SET NULL on note delete
- `tasting_notes.bottle_event_id` → `bottle_events`: optional link, SET NULL on event delete
- `user_settings`: standalone singleton table, no FK relationships

---

### 3.2 Complete DDL

> **Target:** PostgreSQL 15+. SQLite adaptation notes are included inline as comments.

#### `storage_locations` Table

```sql
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
```

#### `wines` Table

```sql
CREATE TABLE wines (
  -- Identity
  wine_id              UUID          PRIMARY KEY DEFAULT gen_random_uuid(),
  wine_name            VARCHAR(200)  NOT NULL,
  producer             VARCHAR(200)  NOT NULL,
  vintage_year         INTEGER       NOT NULL
                         CHECK (vintage_year BETWEEN 1900 AND 2200),
  wine_type            VARCHAR(20)   NOT NULL
                         CHECK (wine_type IN (
                           'RED','WHITE','ROSE','SPARKLING','DESSERT','FORTIFIED'
                         )),
  grape_variety        VARCHAR(200),
  country              VARCHAR(100),
  region               VARCHAR(100),
  appellation          VARCHAR(100),
  bottle_size          VARCHAR(10)   NOT NULL DEFAULT '750ML'
                         CHECK (bottle_size IN ('375ML','750ML','1500ML','3000ML')),

  -- Quantity & status
  quantity             INTEGER       NOT NULL DEFAULT 1
                         CHECK (quantity >= 0),
  is_open              BOOLEAN       NOT NULL DEFAULT FALSE,

  -- Storage
  storage_location_id  UUID          REFERENCES storage_locations(location_id)
                         ON DELETE SET NULL,
  location_unknown     BOOLEAN       NOT NULL DEFAULT FALSE,

  -- Acquisition
  purchase_date        DATE,
  purchase_source      VARCHAR(200),
  purchase_price       NUMERIC(10,2) CHECK (purchase_price >= 0),
  estimated_value      NUMERIC(10,2) CHECK (estimated_value >= 0),

  -- Drinking window
  drink_window_start   INTEGER       CHECK (drink_window_start BETWEEN 1900 AND 2200),
  drink_window_end     INTEGER       CHECK (drink_window_end BETWEEN 1900 AND 2200),
  CONSTRAINT chk_window_order CHECK (
    drink_window_start IS NULL
    OR drink_window_end IS NULL
    OR drink_window_start <= drink_window_end
  ),

  -- Free-text notes
  notes                TEXT          CHECK (char_length(notes) <= 5000),

  -- Denormalized rating cache (maintained by application logic after tasting_notes writes)
  latest_rating        NUMERIC(5,1),
  latest_rating_scale  VARCHAR(10)   CHECK (latest_rating_scale IN ('STARS_5','POINTS_100')),
  latest_rating_date   DATE,

  -- Metadata
  created_at           TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
  updated_at           TIMESTAMPTZ   NOT NULL DEFAULT NOW()
);

-- Performance indexes
CREATE INDEX idx_wines_wine_type      ON wines(wine_type);
CREATE INDEX idx_wines_vintage_year   ON wines(vintage_year);
CREATE INDEX idx_wines_country        ON wines(country);
CREATE INDEX idx_wines_region         ON wines(region);
CREATE INDEX idx_wines_storage_loc    ON wines(storage_location_id);
CREATE INDEX idx_wines_quantity       ON wines(quantity);
CREATE INDEX idx_wines_created_at     ON wines(created_at DESC);
CREATE INDEX idx_wines_latest_rating  ON wines(latest_rating DESC NULLS LAST);
CREATE INDEX idx_wines_drink_window   ON wines(drink_window_start, drink_window_end);
CREATE INDEX idx_wines_producer       ON wines(LOWER(producer));
```

#### `bottle_events` Table

> Note: `bottle_events` references `tasting_notes` (added via ALTER after `tasting_notes` is created).

```sql
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
```

#### `tasting_notes` Table

```sql
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
```

#### `user_settings` Table

```sql
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
```

---

### 3.3 Migration Strategy

Use **db-migrate** or **node-pg-migrate** for version-controlled schema migrations. Migration files live in `db/migrations/`.

**Creation order (respects FK dependencies):**
1. `storage_locations`
2. `wines` (FK → storage_locations)
3. `bottle_events` (FK → wines; tasting_note_id column without FK initially)
4. `tasting_notes` (FK → wines, → bottle_events)
5. ALTER `bottle_events` ADD CONSTRAINT FK → tasting_notes
6. `user_settings` + seed row

**Index creation:** Included in the same migration as the table CREATE.

---
