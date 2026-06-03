---
phase: 01-database
plan: 01
type: execute
wave: 1
depends_on: []
files_modified:
  - db/migrations/001_create_storage_locations.sql
  - db/migrations/002_create_wines.sql
  - db/migrations/003_create_bottle_events.sql
  - db/migrations/004_create_tasting_notes.sql
  - db/migrations/005_create_user_settings.sql
  - db/migrate.ts
  - lib/db.ts
autonomous: true

features:
  implements: ["F0", "F1", "F2", "F4", "F5"]
  depends_on: []
  enables: ["F0", "F1", "F2", "F3", "F4", "F5", "F6"]

must_haves:
  truths:
    - "All 5 tables exist in the database with exact column names, types, and constraints from TechArch"
    - "All FK relationships enforced: wines→storage_locations (SET NULL), bottle_events→wines (CASCADE), tasting_notes→wines (CASCADE), cross-FK bottle_events↔tasting_notes (SET NULL)"
    - "All performance indexes created (9 on wines, 3 on bottle_events, 3 on tasting_notes, 1 on storage_locations)"
    - "user_settings singleton row seeded with rating_scale = 'STARS_5'"
    - "drinks.latest_rating, latest_rating_scale, latest_rating_date denormalization columns present (ADR-008)"
    - "drink_window_start, drink_window_end columns present on wines (required for F5 readiness calculation)"
    - "Migration runner can be invoked to apply all migrations in order"
    - "PostgreSQL connection pool established via node-postgres (pg)"
  artifacts:
    - path: "db/migrations/001_create_storage_locations.sql"
      provides: "storage_locations table DDL"
      contains: "CREATE TABLE storage_locations"
    - path: "db/migrations/002_create_wines.sql"
      provides: "wines table DDL with all 26 columns + 10 indexes"
      contains: "CREATE TABLE wines"
    - path: "db/migrations/003_create_bottle_events.sql"
      provides: "bottle_events table DDL + 3 indexes"
      contains: "CREATE TABLE bottle_events"
    - path: "db/migrations/004_create_tasting_notes.sql"
      provides: "tasting_notes table DDL + 3 indexes + ALTER TABLE FK on bottle_events"
      contains: "CREATE TABLE tasting_notes"
    - path: "db/migrations/005_create_user_settings.sql"
      provides: "user_settings table DDL + seed row"
      contains: "CREATE TABLE user_settings"
    - path: "lib/db.ts"
      provides: "PostgreSQL connection pool (pg.Pool)"
      exports: ["query", "pool"]
    - path: "db/migrate.ts"
      provides: "Migration runner script"
      exports: ["runMigrations"]
  key_links:
    - from: "db/migrate.ts"
      to: "db/migrations/*.sql"
      via: "fs.readFileSync + pool.query"
      pattern: "migrations.*\\.sql"
    - from: "lib/db.ts"
      to: "process.env.DATABASE_URL"
      via: "new Pool({ connectionString })"
      pattern: "DATABASE_URL"

integration_contracts:
  requires: []
  provides:
    - artifact: "lib/db.ts"
      exports: ["query", "pool"]
      shape: |
        export const pool: pg.Pool
        export async function query(text: string, params?: any[]): Promise<pg.QueryResult>
      verify: "grep -n 'export.*pool\\|export.*function query\\|export.*const query\\|export.*async function query' lib/db.ts && echo CONTRACT_OK"
    - artifact: "db/migrations/001_create_storage_locations.sql"
      exports: ["storage_locations"]
      shape: |
        TABLE storage_locations (location_id UUID PK, location_name VARCHAR(100) NOT NULL UNIQUE, created_at TIMESTAMPTZ, updated_at TIMESTAMPTZ)
        INDEX uq_location_name_ci ON LOWER(location_name)
      verify: "grep -n 'CREATE TABLE storage_locations' db/migrations/001_create_storage_locations.sql && echo CONTRACT_OK"
    - artifact: "db/migrations/002_create_wines.sql"
      exports: ["wines"]
      shape: |
        TABLE wines (wine_id UUID PK, wine_name VARCHAR(200) NOT NULL, producer VARCHAR(200) NOT NULL, vintage_year INTEGER NOT NULL CHECK 1900-2200, wine_type VARCHAR(20) NOT NULL, quantity INTEGER NOT NULL DEFAULT 1 CHECK >=0, is_open BOOLEAN NOT NULL DEFAULT FALSE, storage_location_id UUID FK SET NULL, location_unknown BOOLEAN NOT NULL DEFAULT FALSE, drink_window_start INTEGER, drink_window_end INTEGER, latest_rating NUMERIC(5,1), latest_rating_scale VARCHAR(10), latest_rating_date DATE, ...)
        9 indexes including idx_wines_drink_window and idx_wines_latest_rating
      verify: "grep -n 'CREATE TABLE wines' db/migrations/002_create_wines.sql && grep -n 'latest_rating' db/migrations/002_create_wines.sql && grep -n 'drink_window_start' db/migrations/002_create_wines.sql && echo CONTRACT_OK"
    - artifact: "db/migrations/003_create_bottle_events.sql"
      exports: ["bottle_events"]
      shape: |
        TABLE bottle_events (event_id UUID PK, wine_id UUID NOT NULL FK CASCADE, event_type VARCHAR(10) NOT NULL CHECK CONSUMED/GIFTED/OPENED, event_date DATE NOT NULL, notes VARCHAR(500), recipient VARCHAR(200), tasting_note_id UUID, created_at TIMESTAMPTZ)
        3 indexes on wine_id, event_date, event_type
      verify: "grep -n 'CREATE TABLE bottle_events' db/migrations/003_create_bottle_events.sql && echo CONTRACT_OK"
    - artifact: "db/migrations/004_create_tasting_notes.sql"
      exports: ["tasting_notes", "fk_bottle_events_tasting_note"]
      shape: |
        TABLE tasting_notes (note_id UUID PK, wine_id UUID NOT NULL FK CASCADE, bottle_event_id UUID FK SET NULL, date_tasted DATE NOT NULL, appearance VARCHAR(500), aroma VARCHAR(500), flavor TEXT CHECK <=1000, finish VARCHAR(500), personal_rating NUMERIC(5,1), rating_scale VARCHAR(10), would_buy_again VARCHAR(5), occasion VARCHAR(200), guest_feedback VARCHAR(500), created_at TIMESTAMPTZ, updated_at TIMESTAMPTZ)
        3 indexes + ALTER TABLE bottle_events ADD CONSTRAINT fk_bottle_events_tasting_note
      verify: "grep -n 'CREATE TABLE tasting_notes' db/migrations/004_create_tasting_notes.sql && grep -n 'ALTER TABLE bottle_events' db/migrations/004_create_tasting_notes.sql && echo CONTRACT_OK"
    - artifact: "db/migrations/005_create_user_settings.sql"
      exports: ["user_settings"]
      shape: |
        TABLE user_settings (settings_id UUID PK, rating_scale VARCHAR(10) NOT NULL DEFAULT 'STARS_5' CHECK STARS_5/POINTS_100, created_at TIMESTAMPTZ, updated_at TIMESTAMPTZ)
        INSERT seed row ON CONFLICT DO NOTHING
      verify: "grep -n 'CREATE TABLE user_settings' db/migrations/005_create_user_settings.sql && grep -n 'INSERT INTO user_settings' db/migrations/005_create_user_settings.sql && echo CONTRACT_OK"
---

<objective>
Create the complete database schema for SimpleWineApp — all 5 tables with exact DDL from TechArch §3.2, all FK relationships, all performance indexes, and the user_settings seed row. Establish the PostgreSQL connection pool and migration runner that wave 2 (backend) will depend on.

Purpose: The database is the foundation for all 22 API endpoints in wave 2 and all UI features in wave 3. Without the correct schema (exact column names, types, constraints), every downstream wave will fail.
Output: 5 migration SQL files, lib/db.ts connection pool, db/migrate.ts runner script.
</objective>

<feature_dependencies>
Implements: F0: Wine Inventory CRUD (wines table), F1: Quantity & Bottle Status Tracking (wines.quantity, wines.is_open, bottle_events table), F2: Storage Location Management (storage_locations table, wines.storage_location_id FK, wines.location_unknown), F4: Tasting Notes & Personal Ratings (tasting_notes table, wines.latest_rating denormalization, user_settings table), F5: Drinking Window Management (wines.drink_window_start, wines.drink_window_end — readiness calculated at response time, never stored per ADR-007)
Depends on: None
Enables: F0, F1, F2, F3, F4, F5, F6 — all wave 2 API endpoints and wave 3 frontend features
</feature_dependencies>

<execution_context>
@/app/workspaces/.pivota-home/opencode-xdg/opencode/pivota_spec-framework/workflows/execute-plan.md
</execution_context>

<context>
@.planning/PROJECT.md
@.planning/express/building-a-web-app-to-keep-track-of-my-w/WAVE-SCHEDULE.md
@project_specs/TechArch-SimpleWineApp.md
</context>

<tasks>

<task type="auto">
  <name>Task 1: Write all 5 SQL migration files with exact TechArch DDL</name>
  <files>
    db/migrations/001_create_storage_locations.sql
    db/migrations/002_create_wines.sql
    db/migrations/003_create_bottle_events.sql
    db/migrations/004_create_tasting_notes.sql
    db/migrations/005_create_user_settings.sql
  </files>
  <action>
Create `db/migrations/` directory and write 5 migration files. Copy DDL VERBATIM from TechArch §3.2. Do not abstract, simplify, or rename any column.

**001_create_storage_locations.sql** — exact DDL from TechArch:
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

**002_create_wines.sql** — exact DDL from TechArch:
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

**003_create_bottle_events.sql** — exact DDL from TechArch (note: tasting_note_id FK is added via ALTER in 004):
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

**004_create_tasting_notes.sql** — exact DDL from TechArch including the deferred ALTER:
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

**005_create_user_settings.sql** — exact DDL from TechArch:
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

**Creation order per TechArch §3.3 (respects FK dependencies):**
1. storage_locations
2. wines (FK → storage_locations)
3. bottle_events (FK → wines; tasting_note_id column without FK initially)
4. tasting_notes (FK → wines, → bottle_events)
5. ALTER bottle_events ADD CONSTRAINT FK → tasting_notes (in 004)
6. user_settings + seed row
  </action>
  <verify>
```bash
grep -n 'CREATE TABLE storage_locations' db/migrations/001_create_storage_locations.sql && \
grep -n 'CREATE TABLE wines' db/migrations/002_create_wines.sql && \
grep -n 'latest_rating' db/migrations/002_create_wines.sql && \
grep -n 'drink_window_start' db/migrations/002_create_wines.sql && \
grep -n 'CREATE TABLE bottle_events' db/migrations/003_create_bottle_events.sql && \
grep -n 'CREATE TABLE tasting_notes' db/migrations/004_create_tasting_notes.sql && \
grep -n 'ALTER TABLE bottle_events' db/migrations/004_create_tasting_notes.sql && \
grep -n 'CREATE TABLE user_settings' db/migrations/005_create_user_settings.sql && \
grep -n 'INSERT INTO user_settings' db/migrations/005_create_user_settings.sql && \
echo "ALL DDL FILES PRESENT AND VALID"
```
  </verify>
  <done>
- All 5 migration files exist under db/migrations/ with exact column names, types, and constraints matching TechArch §3.2 verbatim
- wines table has all 26 columns including latest_rating, latest_rating_scale, latest_rating_date (ADR-008) and drink_window_start, drink_window_end (F5)
- wines table has all 10 performance indexes (idx_wines_wine_type through idx_wines_producer)
- bottle_events table has tasting_note_id column (UUID, FK added in 004 via ALTER)
- tasting_notes table has ALTER TABLE statement at end of 004 file adding fk_bottle_events_tasting_note constraint
- user_settings table has singleton seed row INSERT with ON CONFLICT DO NOTHING
  </done>
</task>

<task type="auto">
  <name>Task 2: Create PostgreSQL connection pool (lib/db.ts) and migration runner (db/migrate.ts)</name>
  <files>
    lib/db.ts
    db/migrate.ts
    package.json
  </files>
  <action>
**lib/db.ts** — PostgreSQL connection pool using node-postgres (pg). Per TechArch ADR-003: raw SQL via node-postgres, no ORM.

```typescript
import { Pool, QueryResult } from 'pg';

if (!process.env.DATABASE_URL) {
  throw new Error('DATABASE_URL environment variable is required');
}

export const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
  max: 10,
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 2000,
});

// Graceful shutdown
process.on('exit', () => pool.end());

/**
 * Execute a parameterized SQL query against the connection pool.
 * All queries MUST use parameterized form ($1, $2, ...) — never string interpolation.
 */
export async function query(text: string, params?: any[]): Promise<QueryResult> {
  const start = Date.now();
  const result = await pool.query(text, params);
  const duration = Date.now() - start;
  if (process.env.NODE_ENV !== 'production') {
    console.log('[db] query', { text, duration, rows: result.rowCount });
  }
  return result;
}
```

**db/migrate.ts** — Migration runner that applies numbered migration files in order. Uses a `schema_migrations` tracking table so migrations are idempotent.

```typescript
import fs from 'fs';
import path from 'path';
import { pool } from '../lib/db';

async function runMigrations() {
  const client = await pool.connect();
  try {
    // Ensure tracking table exists
    await client.query(`
      CREATE TABLE IF NOT EXISTS schema_migrations (
        filename   VARCHAR(255) PRIMARY KEY,
        applied_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
      )
    `);

    const migrationsDir = path.join(__dirname, 'migrations');
    const files = fs.readdirSync(migrationsDir)
      .filter(f => f.endsWith('.sql'))
      .sort(); // lexicographic order: 001_, 002_, ...

    for (const file of files) {
      const { rows } = await client.query(
        'SELECT filename FROM schema_migrations WHERE filename = $1',
        [file]
      );
      if (rows.length > 0) {
        console.log(`[migrate] skipping already-applied: ${file}`);
        continue;
      }

      console.log(`[migrate] applying: ${file}`);
      const sql = fs.readFileSync(path.join(migrationsDir, file), 'utf-8');
      await client.query('BEGIN');
      await client.query(sql);
      await client.query(
        'INSERT INTO schema_migrations (filename) VALUES ($1)',
        [file]
      );
      await client.query('COMMIT');
      console.log(`[migrate] applied: ${file}`);
    }

    console.log('[migrate] all migrations complete');
  } catch (err) {
    await client.query('ROLLBACK');
    console.error('[migrate] migration failed, rolled back:', err);
    process.exit(1);
  } finally {
    client.release();
    await pool.end();
  }
}

runMigrations().catch(err => {
  console.error('[migrate] unhandled error:', err);
  process.exit(1);
});
```

**package.json** — Ensure `pg` and `@types/pg` are listed as dependencies, and add a `migrate` script. If package.json does not exist yet, create a minimal one for a Next.js 14 project per TechArch §1.4:

```json
{
  "name": "simple-wine-app",
  "version": "0.1.0",
  "private": true,
  "scripts": {
    "dev": "next dev",
    "build": "next build",
    "start": "next start",
    "migrate": "ts-node db/migrate.ts",
    "migrate:check": "ts-node -e \"require('./db/migrate')\" 2>&1 || true"
  },
  "dependencies": {
    "next": "^14.0.0",
    "react": "^18.0.0",
    "react-dom": "^18.0.0",
    "pg": "^8.11.0",
    "zod": "^3.22.0",
    "@tanstack/react-query": "^5.0.0"
  },
  "devDependencies": {
    "@types/node": "^20.0.0",
    "@types/pg": "^8.10.0",
    "@types/react": "^18.0.0",
    "@types/react-dom": "^18.0.0",
    "typescript": "^5.0.0",
    "ts-node": "^10.9.0"
  }
}
```

**IMPORTANT:** If package.json already exists in the repo, do NOT overwrite it wholesale — instead add only the missing dependencies (`pg`, `@types/pg`, `zod`, `@tanstack/react-query`, `ts-node`) and the `migrate` script using targeted edits. Preserve any existing content.

After writing files, install dependencies:
```bash
npm install
```
  </action>
  <verify>
```bash
node -e "require('./lib/db')" 2>&1 | grep -v "DATABASE_URL" || true && \
grep -n "export.*pool\|export.*query\|export async function query\|export const pool" lib/db.ts && \
grep -n "runMigrations\|schema_migrations\|fs.readdirSync" db/migrate.ts && \
grep -n '"pg"' package.json && \
echo "DB MODULE AND MIGRATION RUNNER VALID"
```
  </verify>
  <done>
- lib/db.ts exports `pool` (pg.Pool) and `query` (parameterized SQL helper)
- lib/db.ts reads DATABASE_URL from environment and throws clearly if absent
- db/migrate.ts applies numbered SQL files in lexicographic order
- db/migrate.ts tracks applied migrations in schema_migrations table (idempotent)
- db/migrate.ts wraps each migration in BEGIN/COMMIT transaction with ROLLBACK on error
- package.json includes `pg`, `@types/pg` dependencies and `migrate` npm script
- `npm install` completes without errors
  </done>
</task>

</tasks>

<verification>
After both tasks complete, run these checks:

```bash
# 1. All migration files present
ls db/migrations/*.sql | sort

# 2. Critical columns exist in DDL
grep -n 'latest_rating\|latest_rating_scale\|latest_rating_date' db/migrations/002_create_wines.sql
grep -n 'drink_window_start\|drink_window_end\|chk_window_order' db/migrations/002_create_wines.sql
grep -n 'location_unknown\|storage_location_id' db/migrations/002_create_wines.sql

# 3. FK constraints present
grep -n 'ON DELETE CASCADE\|ON DELETE SET NULL' db/migrations/002_create_wines.sql
grep -n 'ON DELETE CASCADE\|ON DELETE SET NULL' db/migrations/003_create_bottle_events.sql
grep -n 'ON DELETE CASCADE\|ON DELETE SET NULL' db/migrations/004_create_tasting_notes.sql
grep -n 'ALTER TABLE bottle_events.*fk_bottle_events_tasting_note' db/migrations/004_create_tasting_notes.sql

# 4. All 10 wines indexes
grep -c 'CREATE INDEX' db/migrations/002_create_wines.sql

# 5. Seed row
grep -n 'INSERT INTO user_settings' db/migrations/005_create_user_settings.sql

# 6. lib/db.ts exports
grep -n 'export' lib/db.ts

# 7. Migration runner
grep -n 'schema_migrations\|BEGIN\|COMMIT\|ROLLBACK' db/migrate.ts
```

If DATABASE_URL is set and PostgreSQL is reachable:
```bash
npm run migrate 2>&1
```
Expected: `[migrate] all migrations complete` with no errors.
</verification>

<success_criteria>
- 5 SQL migration files exist with DDL copied verbatim from TechArch §3.2
- wines table has exactly: wine_id, wine_name, producer, vintage_year, wine_type, grape_variety, country, region, appellation, bottle_size, quantity, is_open, storage_location_id, location_unknown, purchase_date, purchase_source, purchase_price, estimated_value, drink_window_start, drink_window_end, chk_window_order constraint, notes, latest_rating, latest_rating_scale, latest_rating_date, created_at, updated_at
- All 10 performance indexes on wines created
- bottle_events.tasting_note_id FK added via ALTER TABLE in migration 004
- user_settings seeded with STARS_5 default
- lib/db.ts provides pool + query exports that wave 2 API routes will import
- db/migrate.ts idempotently applies migrations in order
- npm install completes; pg and @types/pg in dependencies
</success_criteria>

<output>
After completion, create `.planning/express/building-a-web-app-to-keep-track-of-my-w/01-SUMMARY.md` summarizing:
- Tables created with column counts
- Indexes created
- Key FK relationships established
- Exports provided by lib/db.ts (consumed by all wave 2 plans)
- Any deviations from TechArch DDL (expected: none)
</output>
