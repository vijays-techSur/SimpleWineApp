---
phase: 04-backend-tasting-dashboard
plan: 04
type: execute
wave: 4
depends_on: [1]
files_modified:
  - app/api/v1/wines/[wine_id]/tasting-notes/route.ts
  - app/api/v1/wines/[wine_id]/tasting-notes/[note_id]/route.ts
  - app/api/v1/settings/rating-scale/route.ts
  - app/api/v1/dashboard/route.ts
  - app/api/v1/dashboard/stats/route.ts
  - lib/queries/tasting-notes.ts
  - lib/queries/dashboard.ts
  - lib/queries/settings.ts
  - lib/validation/tasting-notes.ts
  - lib/validation/settings.ts
  - lib/business/rating.ts
  - lib/filter/filterWines.ts
  - lib/filter/sortWines.ts
autonomous: true

features:
  implements: ["F4", "F6", "F3"]
  depends_on: ["F0", "F1", "F2"]
  enables: ["F3", "F4", "F6"]

must_haves:
  truths:
    - "GET /api/v1/wines/:wine_id/tasting-notes returns all notes for a wine in reverse chronological order"
    - "POST /api/v1/wines/:wine_id/tasting-notes creates a note and triggers latest_rating denormalization on the wines table"
    - "PUT and DELETE /api/v1/wines/:wine_id/tasting-notes/:note_id update/remove the note and recalculate wines.latest_rating"
    - "GET /api/v1/settings/rating-scale returns the user's scale; PUT updates it"
    - "GET /api/v1/dashboard returns full DashboardResponse with stats, drink_now_shelf, breakdowns, recently_added, recently_consumed, highest_rated"
    - "GET /api/v1/dashboard/stats returns only DashboardStats (lightweight)"
    - "filterWines() pure function applies all 10 filter dimensions with AND logic; readiness filter excludes quantity=0 wines"
    - "sortWines() pure function handles all 10 WineSortKey variants; unrated wines sorted last on rating keys; null drink_window_end sorted last"
  artifacts:
    - path: "lib/queries/tasting-notes.ts"
      provides: "SQL queries: listNotes, getNote, createNote, updateNote, deleteNote, refreshLatestRating"
      exports: ["listNotesByWine", "getNoteById", "createNote", "updateNote", "deleteNote", "refreshLatestRating"]
    - path: "lib/queries/dashboard.ts"
      provides: "SQL queries: getDashboard, getDashboardStats"
      exports: ["getDashboard", "getDashboardStats"]
    - path: "lib/business/rating.ts"
      provides: "latest_rating refresh logic post tasting-note write"
      exports: ["refreshLatestRating"]
    - path: "lib/filter/filterWines.ts"
      provides: "Client-side filter engine pure function"
      exports: ["filterWines"]
    - path: "lib/filter/sortWines.ts"
      provides: "Client-side sort pure function"
      exports: ["sortWines"]
    - path: "app/api/v1/wines/[wine_id]/tasting-notes/route.ts"
      provides: "GET list, POST create tasting notes"
      exports: ["GET", "POST"]
    - path: "app/api/v1/dashboard/route.ts"
      provides: "GET full dashboard response"
      exports: ["GET"]
  key_links:
    - from: "app/api/v1/wines/[wine_id]/tasting-notes/route.ts"
      to: "lib/queries/tasting-notes.ts"
      via: "import createNote, listNotesByWine"
      pattern: "createNote|listNotesByWine"
    - from: "lib/queries/tasting-notes.ts"
      to: "lib/business/rating.ts"
      via: "refreshLatestRating called after insert/update/delete"
      pattern: "refreshLatestRating"
    - from: "app/api/v1/dashboard/route.ts"
      to: "lib/queries/dashboard.ts"
      via: "import getDashboard"
      pattern: "getDashboard"
    - from: "lib/filter/filterWines.ts"
      to: "lib/business/readiness.ts"
      via: "calculateReadinessStatus called per wine for readiness filter"
      pattern: "calculateReadinessStatus"

integration_contracts:
  requires:
    - from_plan: "01"
      artifact: "lib/db.ts"
      exports: ["query", "pool"]
      verify: "grep -n 'export.*pool\\|export.*function query\\|export.*const query\\|export.*async function query' lib/db.ts && echo CONTRACT_OK"
    - from_plan: "01"
      artifact: "db/migrations/004_create_tasting_notes.sql"
      exports: ["tasting_notes"]
      verify: "grep -n 'CREATE TABLE tasting_notes' db/migrations/004_create_tasting_notes.sql && grep -n 'ALTER TABLE bottle_events' db/migrations/004_create_tasting_notes.sql && echo CONTRACT_OK"
    - from_plan: "01"
      artifact: "db/migrations/005_create_user_settings.sql"
      exports: ["user_settings"]
      verify: "grep -n 'CREATE TABLE user_settings' db/migrations/005_create_user_settings.sql && grep -n 'INSERT INTO user_settings' db/migrations/005_create_user_settings.sql && echo CONTRACT_OK"
    - from_plan: "01"
      artifact: "db/migrations/002_create_wines.sql"
      exports: ["wines"]
      verify: "grep -n 'latest_rating' db/migrations/002_create_wines.sql && grep -n 'drink_window_start' db/migrations/002_create_wines.sql && echo CONTRACT_OK"
  provides:
    - artifact: "lib/queries/tasting-notes.ts"
      exports: ["listNotesByWine", "getNoteById", "createNote", "updateNote", "deleteNote", "refreshLatestRating"]
      shape: |
        export async function listNotesByWine(wineId: string): Promise<TastingNote[]>
        export async function getNoteById(wineId: string, noteId: string): Promise<TastingNote | null>
        export async function createNote(wineId: string, data: CreateTastingNoteRequest): Promise<TastingNote>
        export async function updateNote(wineId: string, noteId: string, data: UpdateTastingNoteRequest): Promise<TastingNote | null>
        export async function deleteNote(wineId: string, noteId: string): Promise<boolean>
        export async function refreshLatestRating(wineId: string): Promise<void>
      verify: "grep -n 'export.*listNotesByWine\\|export.*createNote\\|export.*refreshLatestRating' lib/queries/tasting-notes.ts && echo CONTRACT_OK"
    - artifact: "lib/queries/dashboard.ts"
      exports: ["getDashboard", "getDashboardStats"]
      shape: |
        export async function getDashboard(currentYear: number): Promise<DashboardResponse>
        export async function getDashboardStats(currentYear: number): Promise<DashboardStats>
      verify: "grep -n 'export.*getDashboard\\|export.*getDashboardStats' lib/queries/dashboard.ts && echo CONTRACT_OK"
    - artifact: "lib/business/rating.ts"
      exports: ["refreshLatestRating"]
      shape: |
        export async function refreshLatestRating(wineId: string): Promise<void>
        // Queries most recent tasting_note with personal_rating for wineId
        // Updates wines.latest_rating, latest_rating_scale, latest_rating_date
        // Sets to NULL if no rated notes remain
      verify: "grep -n 'export.*refreshLatestRating\\|export.*async function refreshLatestRating' lib/business/rating.ts && echo CONTRACT_OK"
    - artifact: "lib/filter/filterWines.ts"
      exports: ["filterWines", "FilterState"]
      shape: |
        export interface FilterState {
          wine_type?: WineType[];
          producer?: string;
          country?: string;
          region?: string;
          vintage_from?: number;
          vintage_to?: number;
          grape_variety?: string;
          storage_location_id?: string; // UUID or 'UNKNOWN'
          readiness?: ReadinessStatus[];
          rating_min?: number;
          rating_max?: number;
        }
        export function filterWines(wines: WineRecord[], filters: FilterState, searchQuery: string, currentYear: number): WineRecord[]
      verify: "grep -n 'export.*filterWines\\|export.*FilterState' lib/filter/filterWines.ts && echo CONTRACT_OK"
    - artifact: "lib/filter/sortWines.ts"
      exports: ["sortWines"]
      shape: |
        export function sortWines(wines: WineRecord[], sortKey: WineSortKey): WineRecord[]
      verify: "grep -n 'export.*sortWines' lib/filter/sortWines.ts && echo CONTRACT_OK"
    - artifact: "app/api/v1/wines/[wine_id]/tasting-notes/route.ts"
      exports: ["GET", "POST"]
      shape: |
        GET /api/v1/wines/:wine_id/tasting-notes → { data: TastingNote[] }
        POST /api/v1/wines/:wine_id/tasting-notes → 201 TastingNote
      verify: "grep -n 'export.*GET\\|export.*POST' app/api/v1/wines/\\[wine_id\\]/tasting-notes/route.ts && echo CONTRACT_OK"
    - artifact: "app/api/v1/dashboard/route.ts"
      exports: ["GET"]
      shape: |
        GET /api/v1/dashboard → DashboardResponse (stats + drink_now_shelf + breakdowns + recently_added + recently_consumed + highest_rated)
      verify: "grep -n 'export.*GET' app/api/v1/dashboard/route.ts && echo CONTRACT_OK"
    - artifact: "app/api/v1/dashboard/stats/route.ts"
      exports: ["GET"]
      shape: |
        GET /api/v1/dashboard/stats → DashboardStats (total_bottles, total_wine_records, drink_now_count, approaching_peak_count)
      verify: "grep -n 'export.*GET' app/api/v1/dashboard/stats/route.ts && echo CONTRACT_OK"
---

<objective>
Implement the final backend wave: tasting notes CRUD (5 endpoints + settings), dashboard aggregation (2 endpoints), and the client-side filter/sort utility functions.

Purpose: Completes the full 22-endpoint REST API surface (endpoints 14–22) and provides the pure filter/sort engine that the frontend's Search & Filter panel (F3) will call. Wave 3 frontend cannot implement the wine list, dashboard, or tasting notes UI without these artifacts.
Output: 13 files — query modules, route handlers, business logic, Zod validation, and filter/sort utilities.
</objective>

<feature_dependencies>
Implements: F4: Tasting Notes & Personal Ratings (endpoints 14–20, lib/queries/tasting-notes.ts, lib/business/rating.ts, lib/validation/tasting-notes.ts, lib/validation/settings.ts), F6: Collection Dashboard & Insights (endpoints 21–22, lib/queries/dashboard.ts), F3: Search & Filter (lib/filter/filterWines.ts, lib/filter/sortWines.ts client-side utilities)
Depends on: F0: wines table (lib/db.ts, migrations 001–004), F1: bottle_events table, F2: storage_locations table
Enables: F3: full client-side filter engine ready for wave 3 frontend, F4: tasting notes UI components, F6: dashboard page components
</feature_dependencies>

<execution_context>
@/app/workspaces/.pivota-home/opencode-xdg/opencode/pivota_spec-framework/workflows/execute-plan.md
</execution_context>

<context>
@.planning/PROJECT.md
@.planning/express/building-a-web-app-to-keep-track-of-my-w/WAVE-SCHEDULE.md
@project_specs/TechArch-SimpleWineApp.md
@.planning/express/building-a-web-app-to-keep-track-of-my-w/01-PLAN.md
</context>

<tasks>

<task type="auto">
  <name>Task 1: Tasting notes queries, business logic (rating.ts), Zod schemas, and 5 route handlers</name>
  <files>
    lib/queries/tasting-notes.ts
    lib/queries/settings.ts
    lib/business/rating.ts
    lib/validation/tasting-notes.ts
    lib/validation/settings.ts
    app/api/v1/wines/[wine_id]/tasting-notes/route.ts
    app/api/v1/wines/[wine_id]/tasting-notes/[note_id]/route.ts
    app/api/v1/settings/rating-scale/route.ts
  </files>
  <action>
**lib/validation/tasting-notes.ts** — Zod schemas for F04:

```typescript
import { z } from 'zod';

const today = new Date().toISOString().split('T')[0];

export const CreateTastingNoteSchema = z.object({
  date_tasted: z.string().regex(/^\d{4}-\d{2}-\d{2}$/)
    .refine(d => d <= today, { message: 'Tasting date cannot be in the future.' }),
  appearance: z.string().max(500).optional(),
  aroma: z.string().max(500).optional(),
  flavor: z.string().max(1000).optional(),
  finish: z.string().max(500).optional(),
  personal_rating: z.number().optional(),   // range validated in route based on scale
  rating_scale: z.enum(['STARS_5', 'POINTS_100']).optional(),
  would_buy_again: z.enum(['YES', 'NO', 'MAYBE']).optional(),
  occasion: z.string().max(200).optional(),
  guest_feedback: z.string().max(500).optional(),
  bottle_event_id: z.string().uuid().optional(),
});

export type CreateTastingNoteInput = z.infer<typeof CreateTastingNoteSchema>;
export const UpdateTastingNoteSchema = CreateTastingNoteSchema;
```

**lib/validation/settings.ts** — Zod schemas for F04.6:

```typescript
import { z } from 'zod';

export const UpdateRatingScaleSchema = z.object({
  rating_scale: z.enum(['STARS_5', 'POINTS_100']),
});
```

**lib/queries/settings.ts** — SQL queries for user_settings singleton:

```typescript
import { query } from '../db';

export async function getRatingScale(): Promise<'STARS_5' | 'POINTS_100'> {
  const result = await query('SELECT rating_scale FROM user_settings LIMIT 1');
  if (result.rows.length === 0) return 'STARS_5'; // fallback if seed row missing
  return result.rows[0].rating_scale;
}

export async function setRatingScale(scale: 'STARS_5' | 'POINTS_100'): Promise<void> {
  await query(
    `UPDATE user_settings SET rating_scale = $1, updated_at = NOW()`,
    [scale]
  );
}
```

**lib/business/rating.ts** — latest_rating refresh per ADR-008. After any tasting_notes insert/update/delete, this refreshes the denormalized columns on wines:

```typescript
import { query } from '../db';

/**
 * Refresh wines.latest_rating, latest_rating_scale, latest_rating_date
 * by querying the most recent tasting note with a personal_rating for wineId.
 * Sets all three columns to NULL if no rated notes remain.
 * Called after any tasting note create, update, or delete.
 */
export async function refreshLatestRating(wineId: string): Promise<void> {
  const result = await query(
    `SELECT personal_rating, rating_scale, date_tasted
       FROM tasting_notes
      WHERE wine_id = $1
        AND personal_rating IS NOT NULL
      ORDER BY date_tasted DESC, created_at DESC
      LIMIT 1`,
    [wineId]
  );

  if (result.rows.length === 0) {
    await query(
      `UPDATE wines
          SET latest_rating = NULL, latest_rating_scale = NULL, latest_rating_date = NULL, updated_at = NOW()
        WHERE wine_id = $1`,
      [wineId]
    );
  } else {
    const { personal_rating, rating_scale, date_tasted } = result.rows[0];
    await query(
      `UPDATE wines
          SET latest_rating = $1, latest_rating_scale = $2, latest_rating_date = $3, updated_at = NOW()
        WHERE wine_id = $4`,
      [personal_rating, rating_scale, date_tasted, wineId]
    );
  }
}
```

**lib/queries/tasting-notes.ts** — SQL queries for tasting notes CRUD.

From TechArch §3.2 tasting_notes table schema:
- `note_id UUID PK, wine_id UUID NOT NULL FK CASCADE, bottle_event_id UUID FK SET NULL`
- `date_tasted DATE NOT NULL, appearance VARCHAR(500), aroma VARCHAR(500), flavor TEXT CHECK <=1000, finish VARCHAR(500)`
- `personal_rating NUMERIC(5,1), rating_scale VARCHAR(10), would_buy_again VARCHAR(5), occasion VARCHAR(200), guest_feedback VARCHAR(500)`
- `created_at TIMESTAMPTZ, updated_at TIMESTAMPTZ`

```typescript
import { query } from '../db';
import { refreshLatestRating } from '../business/rating';
import { TastingNote, CreateTastingNoteInput } from '../../types'; // shared types

export async function listNotesByWine(wineId: string): Promise<TastingNote[]> {
  const result = await query(
    `SELECT note_id, wine_id, bottle_event_id, date_tasted,
            appearance, aroma, flavor, finish,
            personal_rating, rating_scale, would_buy_again,
            occasion, guest_feedback, created_at, updated_at
       FROM tasting_notes
      WHERE wine_id = $1
      ORDER BY date_tasted DESC, created_at DESC`,
    [wineId]
  );
  return result.rows;
}

export async function getNoteById(wineId: string, noteId: string): Promise<TastingNote | null> {
  const result = await query(
    `SELECT note_id, wine_id, bottle_event_id, date_tasted,
            appearance, aroma, flavor, finish,
            personal_rating, rating_scale, would_buy_again,
            occasion, guest_feedback, created_at, updated_at
       FROM tasting_notes
      WHERE wine_id = $1 AND note_id = $2`,
    [wineId, noteId]
  );
  return result.rows[0] ?? null;
}

export async function createNote(wineId: string, data: CreateTastingNoteInput): Promise<TastingNote> {
  const noteId = crypto.randomUUID();
  const result = await query(
    `INSERT INTO tasting_notes
       (note_id, wine_id, bottle_event_id, date_tasted,
        appearance, aroma, flavor, finish,
        personal_rating, rating_scale, would_buy_again,
        occasion, guest_feedback)
     VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13)
     RETURNING *`,
    [
      noteId, wineId,
      data.bottle_event_id ?? null,
      data.date_tasted,
      data.appearance ?? null,
      data.aroma ?? null,
      data.flavor ?? null,
      data.finish ?? null,
      data.personal_rating ?? null,
      data.rating_scale ?? null,
      data.would_buy_again ?? null,
      data.occasion ?? null,
      data.guest_feedback ?? null,
    ]
  );
  const note = result.rows[0];
  await refreshLatestRating(wineId);
  return note;
}

export async function updateNote(wineId: string, noteId: string, data: CreateTastingNoteInput): Promise<TastingNote | null> {
  const result = await query(
    `UPDATE tasting_notes
        SET bottle_event_id = $1, date_tasted = $2,
            appearance = $3, aroma = $4, flavor = $5,
            finish = $6, personal_rating = $7, rating_scale = $8,
            would_buy_again = $9, occasion = $10, guest_feedback = $11,
            updated_at = NOW()
      WHERE wine_id = $12 AND note_id = $13
      RETURNING *`,
    [
      data.bottle_event_id ?? null,
      data.date_tasted,
      data.appearance ?? null,
      data.aroma ?? null,
      data.flavor ?? null,
      data.finish ?? null,
      data.personal_rating ?? null,
      data.rating_scale ?? null,
      data.would_buy_again ?? null,
      data.occasion ?? null,
      data.guest_feedback ?? null,
      wineId, noteId,
    ]
  );
  if (result.rows.length === 0) return null;
  await refreshLatestRating(wineId);
  return result.rows[0];
}

export async function deleteNote(wineId: string, noteId: string): Promise<boolean> {
  const result = await query(
    `DELETE FROM tasting_notes WHERE wine_id = $1 AND note_id = $2`,
    [wineId, noteId]
  );
  if ((result.rowCount ?? 0) > 0) {
    await refreshLatestRating(wineId);
    return true;
  }
  return false;
}
```

**app/api/v1/wines/[wine_id]/tasting-notes/route.ts** — GET (list) + POST (create):

From TechArch §4.3 TastingNote interface and endpoint spec:
- GET → `{ data: TastingNote[] }` (200)
- POST → TastingNote (201); 404 if wine_id not found; 422 on validation failure

Validate `bottle_event_id` if provided: must exist and be a CONSUMED event (query `bottle_events WHERE event_id = $1 AND event_type = 'CONSUMED'`).
Validate `personal_rating` range: if `rating_scale = 'STARS_5'` or user setting is STARS_5, must be 1–5; if POINTS_100, must be 1–100.
Strip HTML/script content from all text fields (replace `<[^>]+>` with empty string server-side).

Return `ApiError` envelope on failures per TechArch §4.2.

**app/api/v1/wines/[wine_id]/tasting-notes/[note_id]/route.ts** — GET (single) + PUT (full replace) + DELETE:

- GET → TastingNote (200) or 404 NOTE_NOT_FOUND
- PUT → updated TastingNote (200) or 404; runs same validation as POST; calls `updateNote`
- DELETE → 204 No Content; calls `deleteNote` which triggers `refreshLatestRating`

**app/api/v1/settings/rating-scale/route.ts** — GET + PUT:

- GET → `{ rating_scale: 'STARS_5' | 'POINTS_100' }` (200)
- PUT body: `{ rating_scale: 'STARS_5' | 'POINTS_100' }` → 200 `{ rating_scale }` on success, 422 on invalid value
  </action>
  <verify>
grep -n 'export.*listNotesByWine\|export.*createNote\|export.*refreshLatestRating' lib/queries/tasting-notes.ts && grep -n 'export.*refreshLatestRating\|export.*async function refreshLatestRating' lib/business/rating.ts && grep -n 'export.*GET\|export.*POST' app/api/v1/wines/\[wine_id\]/tasting-notes/route.ts && grep -n 'export.*GET\|export.*PUT\|export.*DELETE' "app/api/v1/wines/[wine_id]/tasting-notes/[note_id]/route.ts" && grep -n 'export.*GET\|export.*PUT' app/api/v1/settings/rating-scale/route.ts && echo CONTRACT_OK
  </verify>
  <done>
- lib/queries/tasting-notes.ts exports listNotesByWine, getNoteById, createNote, updateNote, deleteNote — all call refreshLatestRating after any write
- lib/business/rating.ts exports refreshLatestRating; queries most recent rated tasting_note for wineId and UPDATEs wines.latest_rating, latest_rating_scale, latest_rating_date (or NULLs if no rated notes remain)
- lib/queries/settings.ts exports getRatingScale, setRatingScale operating on user_settings singleton row
- All 3 route files export correct HTTP methods
- POST /tasting-notes validates date_tasted (required, not future), personal_rating range, bottle_event_id must be CONSUMED event
- DELETE /tasting-notes/:note_id returns 204 No Content
- GET/PUT /settings/rating-scale reads/writes rating_scale enum
  </done>
</task>

<task type="auto">
  <name>Task 2: Dashboard query module + 2 route handlers + filterWines.ts + sortWines.ts</name>
  <files>
    lib/queries/dashboard.ts
    app/api/v1/dashboard/route.ts
    app/api/v1/dashboard/stats/route.ts
    lib/filter/filterWines.ts
    lib/filter/sortWines.ts
  </files>
  <action>
**lib/queries/dashboard.ts** — All dashboard aggregation queries. Uses `calculateReadinessStatus` from `lib/business/readiness.ts` (already created in wave 2 plans 02–03) to compute DRINK_NOW / APPROACHING_PEAK counts.

From TechArch §4.3 DashboardResponse interface:
```typescript
// DashboardResponse shape (reference only — returned by getDashboard):
// {
//   stats: DashboardStats,                       // total_bottles, total_wine_records, drink_now_count, approaching_peak_count
//   drink_now_shelf: DrinkNowCard[],              // up to 10; qty>0; DRINK_NOW; sorted drink_window_end ASC NULLS LAST
//   breakdown_by_type: BreakdownByTypeRow[],      // all 6 wine types; SUM(qty) for qty>0
//   breakdown_by_region: BreakdownByRegionRow[],  // top 5 + "Other"; "Unknown Origin" for no country/region
//   breakdown_by_decade: BreakdownByDecadeRow[],  // all decades with bottles, desc
//   recently_added: RecentlyAddedItem[],          // up to 5; ORDER BY created_at DESC
//   recently_consumed: RecentlyConsumedItem[],    // up to 5 CONSUMED events; ORDER BY event_date DESC
//   highest_rated: HighestRatedItem[],            // top 5 by latest_rating DESC; latest_rating NOT NULL; ties by latest_rating_date DESC
// }
```

**getDashboardStats(currentYear):**
1. `SELECT SUM(quantity) AS total_bottles, COUNT(*) AS total_wine_records FROM wines` → total_bottles (quantity>0 wines contribute their count), total_wine_records (all rows)
2. Load all wines with drink_window_start, drink_window_end, quantity; compute readiness via `calculateReadinessStatus(start, end, currentYear)` in application layer; count DRINK_NOW+qty>0 and APPROACHING_PEAK+qty>0.

**getDashboard(currentYear):**

Build stats (as above), then:

- **drink_now_shelf:** Load all wines where qty>0; filter DRINK_NOW in application layer; sort by drink_window_end ASC NULLS LAST; slice first 10. Map to DrinkNowCard shape.

- **breakdown_by_type:** 
  ```sql
  SELECT wine_type, SUM(quantity) AS bottle_count 
    FROM wines WHERE quantity > 0 GROUP BY wine_type
  ```
  Ensure all 6 types appear (fill missing types with 0). Calculate percentage as `Math.round((count / totalBottles) * 100)`.

- **breakdown_by_region:**
  ```sql
  SELECT
    CASE
      WHEN country IS NOT NULL AND region IS NOT NULL THEN region || ', ' || country
      WHEN country IS NOT NULL THEN country
      WHEN region IS NOT NULL THEN region
      ELSE 'Unknown Origin'
    END AS label,
    SUM(quantity) AS bottle_count
  FROM wines WHERE quantity > 0
  GROUP BY label
  ORDER BY bottle_count DESC
  ```
  Take top 5; aggregate remaining into "Other" row if any. Calculate percentage.

- **breakdown_by_decade:**
  ```sql
  SELECT
    (FLOOR(vintage_year / 10) * 10) || 's' AS decade,
    SUM(quantity) AS bottle_count
  FROM wines WHERE quantity > 0
  GROUP BY decade ORDER BY decade DESC
  ```

- **recently_added:**
  ```sql
  SELECT wine_id, wine_name, producer, vintage_year, wine_type, created_at
  FROM wines ORDER BY created_at DESC LIMIT 5
  ```

- **recently_consumed:**
  ```sql
  SELECT be.event_id, be.wine_id, w.wine_name, w.producer, w.vintage_year, be.event_date
  FROM bottle_events be JOIN wines w ON w.wine_id = be.wine_id
  WHERE be.event_type = 'CONSUMED'
  ORDER BY be.event_date DESC LIMIT 5
  ```

- **highest_rated:**
  ```sql
  SELECT wine_id, wine_name, producer, vintage_year, latest_rating, latest_rating_scale, latest_rating_date
  FROM wines
  WHERE latest_rating IS NOT NULL
  ORDER BY latest_rating DESC, latest_rating_date DESC
  LIMIT 5
  ```

**app/api/v1/dashboard/route.ts** — GET only:

```typescript
import { NextResponse } from 'next/server';
import { getDashboard } from '../../../../lib/queries/dashboard';

export async function GET() {
  try {
    const currentYear = new Date().getUTCFullYear();
    const data = await getDashboard(currentYear);
    return NextResponse.json(data, { status: 200 });
  } catch (err) {
    console.error('[dashboard]', err);
    return NextResponse.json(
      { error: { code: 'INTERNAL_ERROR', message: 'Failed to load dashboard.' } },
      { status: 500 }
    );
  }
}
```

**app/api/v1/dashboard/stats/route.ts** — GET only (lightweight):

Same pattern as above but calls `getDashboardStats(currentYear)` and returns just the stats object.

---

**lib/filter/filterWines.ts** — Pure client-side filter engine per TechArch §2.3 and F03:

```typescript
import Fuse from 'fuse.js';
import { calculateReadinessStatus } from '../business/readiness';

export interface FilterState {
  wine_type?: WineType[];
  producer?: string;
  country?: string;
  region?: string;
  vintage_from?: number;
  vintage_to?: number;
  grape_variety?: string;
  storage_location_id?: string; // UUID or 'UNKNOWN'
  readiness?: ReadinessStatus[];
  rating_min?: number;
  rating_max?: number;
}

/**
 * Pure function — no side effects. Applies all active filters and search query
 * to the wine array. All criteria combined with AND logic.
 * Readiness filters exclude quantity = 0 wines per F03 §F03.8.
 */
export function filterWines(
  wines: WineRecord[],
  filters: FilterState,
  searchQuery: string,
  currentYear: number
): WineRecord[] {
  let result = wines;

  // 1. Full-text search via Fuse.js (wine_name, producer, region, grape_variety, occasion)
  // occasion comes from wine.latest_occasion if available on the WineRecord
  if (searchQuery.trim()) {
    const fuse = new Fuse(result, {
      keys: ['wine_name', 'producer', 'region', 'grape_variety'],
      threshold: 0.35,
      ignoreLocation: true,
    });
    result = fuse.search(searchQuery.trim()).map(r => r.item);
  }

  // 2. Wine type filter (OR within multi-select)
  if (filters.wine_type?.length) {
    result = result.filter(w => filters.wine_type!.includes(w.wine_type));
  }

  // 3. Producer exact match (case-insensitive)
  if (filters.producer) {
    const p = filters.producer.toLowerCase();
    result = result.filter(w => w.producer.toLowerCase() === p);
  }

  // 4. Country exact match (case-insensitive)
  if (filters.country) {
    const c = filters.country.toLowerCase();
    result = result.filter(w => w.country?.toLowerCase() === c);
  }

  // 5. Region exact match (case-insensitive)
  if (filters.region) {
    const r = filters.region.toLowerCase();
    result = result.filter(w => w.region?.toLowerCase() === r);
  }

  // 6. Vintage range [from, to] inclusive
  if (filters.vintage_from != null) {
    result = result.filter(w => w.vintage_year >= filters.vintage_from!);
  }
  if (filters.vintage_to != null) {
    result = result.filter(w => w.vintage_year <= filters.vintage_to!);
  }

  // 7. Grape variety substring match (case-insensitive)
  if (filters.grape_variety) {
    const g = filters.grape_variety.toLowerCase();
    result = result.filter(w => w.grape_variety?.toLowerCase().includes(g));
  }

  // 8. Storage location: UUID match or "UNKNOWN" for location_unknown = true
  if (filters.storage_location_id) {
    if (filters.storage_location_id === 'UNKNOWN') {
      result = result.filter(w => w.location_unknown === true);
    } else {
      result = result.filter(w => w.storage_location_id === filters.storage_location_id);
    }
  }

  // 9. Readiness status filter (OR within multi-select; excludes qty = 0 wines per F03.8)
  if (filters.readiness?.length) {
    result = result.filter(w => {
      if (w.quantity === 0) return false; // F03.8: all readiness filters exclude qty=0
      const status = calculateReadinessStatus(w.drink_window_start, w.drink_window_end, currentYear);
      return filters.readiness!.includes(status);
    });
  }

  // 10. Rating range filter (on latest_rating)
  if (filters.rating_min != null) {
    result = result.filter(w => w.latest_rating != null && w.latest_rating >= filters.rating_min!);
  }
  if (filters.rating_max != null) {
    result = result.filter(w => w.latest_rating != null && w.latest_rating <= filters.rating_max!);
  }

  return result;
}
```

**NOTE:** Fuse.js must be installed: `npm install fuse.js`. Add to package.json dependencies if not already present.

**lib/filter/sortWines.ts** — Pure sort function for all 10 WineSortKey values per TechArch §4.3:

```typescript
// WineSortKey values from TechArch §4.3:
// 'created_at_desc' | 'created_at_asc' | 'wine_name_asc' | 'wine_name_desc'
// 'vintage_year_desc' | 'vintage_year_asc' | 'quantity_desc' | 'quantity_asc'
// 'rating_desc' | 'rating_asc'
// (drink_window_end sort keys handled via 'drink_window_end_asc' | 'drink_window_end_desc')

export function sortWines(wines: WineRecord[], sortKey: WineSortKey): WineRecord[] {
  const sorted = [...wines]; // do not mutate

  switch (sortKey) {
    case 'created_at_desc':
      return sorted.sort((a, b) => new Date(b.created_at).getTime() - new Date(a.created_at).getTime());
    case 'created_at_asc':
      return sorted.sort((a, b) => new Date(a.created_at).getTime() - new Date(b.created_at).getTime());
    case 'wine_name_asc':
      return sorted.sort((a, b) => a.wine_name.localeCompare(b.wine_name));
    case 'wine_name_desc':
      return sorted.sort((a, b) => b.wine_name.localeCompare(a.wine_name));
    case 'vintage_year_desc':
      return sorted.sort((a, b) => b.vintage_year - a.vintage_year);
    case 'vintage_year_asc':
      return sorted.sort((a, b) => a.vintage_year - b.vintage_year);
    case 'quantity_desc':
      return sorted.sort((a, b) => b.quantity - a.quantity);
    case 'quantity_asc':
      return sorted.sort((a, b) => a.quantity - b.quantity);
    case 'rating_desc':
      // Unrated wines sorted last
      return sorted.sort((a, b) => {
        if (a.latest_rating == null && b.latest_rating == null) return 0;
        if (a.latest_rating == null) return 1;
        if (b.latest_rating == null) return -1;
        return b.latest_rating - a.latest_rating;
      });
    case 'rating_asc':
      // Unrated wines sorted last
      return sorted.sort((a, b) => {
        if (a.latest_rating == null && b.latest_rating == null) return 0;
        if (a.latest_rating == null) return 1;
        if (b.latest_rating == null) return -1;
        return a.latest_rating - b.latest_rating;
      });
    case 'drink_window_end_asc':
      // null drink_window_end sorted last (F03.12)
      return sorted.sort((a, b) => {
        if (a.drink_window_end == null && b.drink_window_end == null) return 0;
        if (a.drink_window_end == null) return 1;
        if (b.drink_window_end == null) return -1;
        return a.drink_window_end - b.drink_window_end;
      });
    case 'drink_window_end_desc':
      // null drink_window_end sorted last (F03.12)
      return sorted.sort((a, b) => {
        if (a.drink_window_end == null && b.drink_window_end == null) return 0;
        if (a.drink_window_end == null) return 1;
        if (b.drink_window_end == null) return -1;
        return b.drink_window_end - a.drink_window_end;
      });
    default:
      return sorted;
  }
}
```

After writing all files, install fuse.js if not present:
```bash
npm install fuse.js
npm install --save-dev @types/fuse.js 2>/dev/null || true
```
  </action>
  <verify>
grep -n 'export.*getDashboard\|export.*getDashboardStats' lib/queries/dashboard.ts && grep -n 'export.*GET' app/api/v1/dashboard/route.ts && grep -n 'export.*GET' app/api/v1/dashboard/stats/route.ts && grep -n 'export.*filterWines\|export.*FilterState' lib/filter/filterWines.ts && grep -n 'export.*sortWines' lib/filter/sortWines.ts && echo CONTRACT_OK
  </verify>
  <done>
- lib/queries/dashboard.ts exports getDashboard and getDashboardStats; getDashboard returns full DashboardResponse shape from TechArch §4.3 (stats + drink_now_shelf up to 10 + 6-type breakdown + top-5 region breakdown + decade breakdown + recently_added up to 5 + recently_consumed up to 5 + highest_rated up to 5)
- getDashboard applies calculateReadinessStatus in application layer for DRINK_NOW + APPROACHING_PEAK counts (never stored per ADR-007)
- app/api/v1/dashboard/route.ts exports GET; passes currentYear = new Date().getUTCFullYear() (ADR-007: calculated at request time)
- app/api/v1/dashboard/stats/route.ts exports GET returning only DashboardStats
- lib/filter/filterWines.ts exports filterWines pure function with all 10 filter dimensions; readiness filter excludes quantity=0 wines (F03.8); uses Fuse.js for full-text match
- lib/filter/sortWines.ts exports sortWines pure function covering all WineSortKey variants; unrated wines last on rating sorts; null drink_window_end last on window sorts
- fuse.js installed in package.json
  </done>
</task>

</tasks>

<verification>
Run these checks after both tasks complete:

```bash
# 1. Query module exports
grep -n 'export' lib/queries/tasting-notes.ts
grep -n 'export' lib/queries/dashboard.ts
grep -n 'export' lib/queries/settings.ts
grep -n 'export' lib/business/rating.ts

# 2. Route handler HTTP methods
grep -n 'export.*GET\|export.*POST\|export.*PUT\|export.*DELETE' \
  app/api/v1/wines/[wine_id]/tasting-notes/route.ts \
  "app/api/v1/wines/[wine_id]/tasting-notes/[note_id]/route.ts" \
  app/api/v1/settings/rating-scale/route.ts \
  app/api/v1/dashboard/route.ts \
  app/api/v1/dashboard/stats/route.ts

# 3. Filter + sort engines
grep -n 'filterWines\|FilterState' lib/filter/filterWines.ts
grep -n 'sortWines' lib/filter/sortWines.ts

# 4. Rating refresh wired into tasting-note writes
grep -n 'refreshLatestRating' lib/queries/tasting-notes.ts

# 5. Fuse.js installed
grep '"fuse.js"' package.json

# 6. TypeScript compilation check
npx tsc --noEmit 2>&1 | head -30
```
</verification>

<success_criteria>
- All 8 files in Task 1 exist and export correct functions/handlers
- All 5 files in Task 2 exist and export correct functions/handlers
- lib/business/rating.ts refreshLatestRating correctly NULLs wines.latest_rating when no rated notes remain; sets most recent personal_rating + scale + date otherwise
- lib/queries/tasting-notes.ts calls refreshLatestRating on createNote, updateNote, deleteNote
- lib/queries/dashboard.ts getDashboard returns full DashboardResponse including all 8 sections
- Dashboard readiness counts computed via calculateReadinessStatus (not a stored field per ADR-007)
- filterWines applies all 10 filter dimensions; readiness filter excludes quantity=0 wines (F03.8 requirement)
- sortWines handles all WineSortKey variants including null-last rules for rating_desc/asc and drink_window_end_asc/desc
- fuse.js in package.json dependencies
- TypeScript compiles without errors on the new files
</success_criteria>

<output>
After completion, create `.planning/express/building-a-web-app-to-keep-track-of-my-w/04-SUMMARY.md` summarizing:
- Tasting notes endpoints implemented (14–20) with latest_rating denormalization
- Dashboard endpoints implemented (21–22) with full DashboardResponse shape
- Filter/sort utility functions implemented (filterWines, sortWines)
- Exports provided (consumed by wave 3 frontend plans)
- Any deviations from TechArch specs (expected: none)
</output>
