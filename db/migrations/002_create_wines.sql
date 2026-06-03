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
