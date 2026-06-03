---
phase: 02-backend
plan: 02
type: execute
wave: 2
depends_on: [1]
files_modified:
  - lib/validation/wines.ts
  - lib/business/readiness.ts
  - lib/business/rating.ts
  - lib/business/location.ts
  - lib/errors.ts
  - lib/queries/wines.ts
  - app/api/v1/wines/route.ts
  - app/api/v1/wines/[wine_id]/route.ts
autonomous: true

features:
  implements: ["F0", "F5"]
  depends_on: ["F0", "F1", "F2", "F4", "F5"]
  enables: ["F0", "F3", "F5", "F6"]

must_haves:
  truths:
    - "GET /api/v1/wines returns all wine records with readiness_status calculated per ADR-007"
    - "POST /api/v1/wines creates a valid wine record and returns 201 with full WineRecord JSON"
    - "GET /api/v1/wines/:wine_id returns a single wine record with readiness_status or 404"
    - "PUT /api/v1/wines/:wine_id replaces all fields and returns updated WineRecord"
    - "DELETE /api/v1/wines/:wine_id deletes the record (cascade) and returns 204"
    - "Invalid input to POST/PUT returns 422 with field-specific error detail"
    - "readiness_status is never stored in the DB — calculateReadinessStatus() called on every response"
    - "latest_rating is refreshed on the wines row after any tasting note write/delete"
  artifacts:
    - path: "lib/validation/wines.ts"
      provides: "Zod schemas for CreateWineRequest, UpdateWineRequest, PatchWineRequest"
      exports: ["createWineSchema", "updateWineSchema", "patchWineSchema"]
    - path: "lib/business/readiness.ts"
      provides: "calculateReadinessStatus() pure function (ADR-007)"
      exports: ["calculateReadinessStatus", "ReadinessStatus"]
    - path: "lib/business/rating.ts"
      provides: "refreshLatestRating() — queries most recent tasting note and updates wines row"
      exports: ["refreshLatestRating"]
    - path: "lib/business/location.ts"
      provides: "flagLocationUnknown() — sets location_unknown=true and clears storage_location_id on affected wines"
      exports: ["flagLocationUnknown"]
    - path: "lib/errors.ts"
      provides: "createApiError() — formats error response per TechArch §4.2 ApiError envelope"
      exports: ["createApiError", "ApiErrorCode"]
    - path: "lib/queries/wines.ts"
      provides: "SQL query functions: listWines, getWine, createWine, updateWine, deleteWine"
      exports: ["listWines", "getWine", "createWine", "updateWine", "deleteWine"]
    - path: "app/api/v1/wines/route.ts"
      provides: "GET /api/v1/wines, POST /api/v1/wines handlers"
      exports: ["GET", "POST"]
    - path: "app/api/v1/wines/[wine_id]/route.ts"
      provides: "GET/PUT/PATCH/DELETE /api/v1/wines/:wine_id handlers"
      exports: ["GET", "PUT", "PATCH", "DELETE"]
  key_links:
    - from: "app/api/v1/wines/route.ts"
      to: "lib/queries/wines.ts"
      via: "import { listWines, createWine }"
      pattern: "from.*lib/queries/wines"
    - from: "app/api/v1/wines/route.ts"
      to: "lib/business/readiness.ts"
      via: "import { calculateReadinessStatus }"
      pattern: "calculateReadinessStatus"
    - from: "app/api/v1/wines/[wine_id]/route.ts"
      to: "lib/queries/wines.ts"
      via: "import { getWine, updateWine, deleteWine }"
      pattern: "from.*lib/queries/wines"
    - from: "lib/queries/wines.ts"
      to: "lib/db.ts"
      via: "import { query } from '../db'"
      pattern: "from.*lib/db"

integration_contracts:
  requires:
    - from_plan: "01"
      artifact: "lib/db.ts"
      exports: ["query", "pool"]
      verify: "grep -n 'export.*pool\\|export.*function query\\|export.*const query\\|export.*async function query' lib/db.ts && echo CONTRACT_OK"
    - from_plan: "01"
      artifact: "db/migrations/002_create_wines.sql"
      exports: ["wines"]
      verify: "grep -n 'CREATE TABLE wines' db/migrations/002_create_wines.sql && grep -n 'latest_rating' db/migrations/002_create_wines.sql && grep -n 'drink_window_start' db/migrations/002_create_wines.sql && echo CONTRACT_OK"
    - from_plan: "01"
      artifact: "db/migrations/001_create_storage_locations.sql"
      exports: ["storage_locations"]
      verify: "grep -n 'CREATE TABLE storage_locations' db/migrations/001_create_storage_locations.sql && echo CONTRACT_OK"
  provides:
    - artifact: "lib/validation/wines.ts"
      exports: ["createWineSchema", "updateWineSchema", "patchWineSchema"]
      shape: |
        export const createWineSchema: z.ZodObject<...>  // validates CreateWineRequest
        export const updateWineSchema: z.ZodObject<...>  // same shape as create (full replace)
        export const patchWineSchema: z.ZodObject<...>   // all fields optional (partial update)
      verify: "grep -n 'export.*createWineSchema\\|export.*updateWineSchema\\|export.*patchWineSchema' lib/validation/wines.ts && echo CONTRACT_OK"
    - artifact: "lib/business/readiness.ts"
      exports: ["calculateReadinessStatus"]
      shape: |
        export type ReadinessStatus = 'DRINK_NOW' | 'APPROACHING_PEAK' | 'HOLD' | 'PAST_WINDOW' | 'NO_WINDOW_SET'
        export function calculateReadinessStatus(drinkWindowStart: number | null, drinkWindowEnd: number | null, currentYear?: number): ReadinessStatus
      verify: "grep -n 'export function calculateReadinessStatus\\|export.*calculateReadinessStatus' lib/business/readiness.ts && echo CONTRACT_OK"
    - artifact: "lib/business/rating.ts"
      exports: ["refreshLatestRating"]
      shape: |
        export async function refreshLatestRating(wineId: string): Promise<void>
      verify: "grep -n 'export.*function refreshLatestRating\\|export.*refreshLatestRating' lib/business/rating.ts && echo CONTRACT_OK"
    - artifact: "lib/business/location.ts"
      exports: ["flagLocationUnknown"]
      shape: |
        export async function flagLocationUnknown(locationId: string): Promise<number>
        // returns count of wines affected
      verify: "grep -n 'export.*function flagLocationUnknown\\|export.*flagLocationUnknown' lib/business/location.ts && echo CONTRACT_OK"
    - artifact: "lib/errors.ts"
      exports: ["createApiError"]
      shape: |
        export function createApiError(code: string, message: string, field?: string, details?: Array<{field:string,message:string}>): { error: ApiError }
      verify: "grep -n 'export.*function createApiError\\|export.*createApiError' lib/errors.ts && echo CONTRACT_OK"
    - artifact: "lib/queries/wines.ts"
      exports: ["listWines", "getWine", "createWine", "updateWine", "deleteWine"]
      shape: |
        export async function listWines(params: WineListParams): Promise<{ rows: WineRecord[]; total: number }>
        export async function getWine(wineId: string): Promise<WineRecord | null>
        export async function createWine(data: CreateWineRequest): Promise<WineRecord>
        export async function updateWine(wineId: string, data: CreateWineRequest): Promise<WineRecord | null>
        export async function deleteWine(wineId: string): Promise<boolean>
      verify: "grep -n 'export.*function listWines\\|export.*function getWine\\|export.*function createWine\\|export.*function updateWine\\|export.*function deleteWine' lib/queries/wines.ts && echo CONTRACT_OK"
    - artifact: "app/api/v1/wines/route.ts"
      exports: ["GET", "POST"]
      shape: |
        export async function GET(request: NextRequest): Promise<NextResponse>   // list wines
        export async function POST(request: NextRequest): Promise<NextResponse>  // create wine → 201
      verify: "grep -n 'export.*function GET\\|export.*GET\\|export.*function POST\\|export.*POST' app/api/v1/wines/route.ts && echo CONTRACT_OK"
    - artifact: "app/api/v1/wines/[wine_id]/route.ts"
      exports: ["GET", "PUT", "PATCH", "DELETE"]
      shape: |
        export async function GET(request: NextRequest, { params }: { params: { wine_id: string } }): Promise<NextResponse>
        export async function PUT(request: NextRequest, { params }: { params: { wine_id: string } }): Promise<NextResponse>
        export async function PATCH(request: NextRequest, { params }: { params: { wine_id: string } }): Promise<NextResponse>
        export async function DELETE(request: NextRequest, { params }: { params: { wine_id: string } }): Promise<NextResponse>
      verify: "grep -n 'export.*function GET\\|export.*function PUT\\|export.*function PATCH\\|export.*function DELETE' app/api/v1/wines/[wine_id]/route.ts && echo CONTRACT_OK"
---

<objective>
Implement the Wines CRUD API endpoints, Zod validation schemas, and three business logic modules (readiness.ts, rating.ts, location.ts) that all wave 2 and wave 3 plans consume.

Purpose: This plan delivers the 6 core wine CRUD endpoints (F0) and the readiness status calculation engine (F5 ADR-007). It also establishes the reusable business logic layer (rating refresh, location flag management, error factory) that plans 03 and 04 will import.
Output: 8 TypeScript files covering validation, business logic, query layer, and route handlers for /api/v1/wines and /api/v1/wines/:wine_id.
</objective>

<feature_dependencies>
Implements: F0: Wine Inventory CRUD (GET/POST/GET/:id/PUT/PATCH/DELETE /api/v1/wines), F5: Drinking Window Management — readiness_status calculated at response time by calculateReadinessStatus() per ADR-007, never stored
Depends on: Wave 1 — wines table DDL (002_create_wines.sql), storage_locations table (001), lib/db.ts query pool
Enables: F0 full CRUD for frontend (wave 3), F3 filter query params on GET /wines, F5 readiness badge in all WineRecord responses, F6 dashboard wine queries
</feature_dependencies>

<execution_context>
@/app/workspaces/.pivota-home/opencode-xdg/opencode/pivota_spec-framework/workflows/execute-plan.md
</execution_context>

<context>
@.planning/PROJECT.md
@.planning/express/building-a-web-app-to-keep-track-of-my-w/WAVE-SCHEDULE.md
@.planning/express/building-a-web-app-to-keep-track-of-my-w/01-PLAN.md
@project_specs/TechArch-SimpleWineApp.md
</context>

<tasks>

<task type="auto">
  <name>Task 1: Zod validation schemas, business logic modules, and error factory</name>
  <files>
    lib/validation/wines.ts
    lib/business/readiness.ts
    lib/business/rating.ts
    lib/business/location.ts
    lib/errors.ts
  </files>
  <action>
Create `lib/validation/`, `lib/business/` directories and write 5 files.

---

**lib/errors.ts** — API error response factory per TechArch §4.2 ApiError envelope:

```typescript
// lib/errors.ts
export interface ApiErrorDetail {
  field: string;
  message: string;
}

export interface ApiErrorBody {
  code: string;
  message: string;
  field?: string;
  details?: ApiErrorDetail[];
}

export function createApiError(
  code: string,
  message: string,
  field?: string,
  details?: ApiErrorDetail[]
): { error: ApiErrorBody } {
  const body: ApiErrorBody = { code, message };
  if (field) body.field = field;
  if (details && details.length > 0) body.details = details;
  return { error: body };
}
```

---

**lib/validation/wines.ts** — Zod schemas for CreateWineRequest, UpdateWineRequest, PatchWineRequest per TechArch §4.3 and FRD F00 validation rules:

```typescript
import { z } from 'zod';

const WINE_TYPES = ['RED', 'WHITE', 'ROSE', 'SPARKLING', 'DESSERT', 'FORTIFIED'] as const;
const BOTTLE_SIZES = ['375ML', '750ML', '1500ML', '3000ML'] as const;
const currentYear = () => new Date().getUTCFullYear();

export const createWineSchema = z.object({
  // Required fields (FRD F00 §Inputs)
  wine_name: z.string().min(1, 'Wine name is required').max(200),
  producer: z.string().min(1, 'Producer is required').max(200),
  vintage_year: z
    .number()
    .int('Vintage must be a year (e.g., 2019)')
    .min(1900, 'Vintage must be between 1900 and current year + 1')
    .max(currentYear() + 1, 'Vintage must be between 1900 and current year + 1'),
  wine_type: z.enum(WINE_TYPES, {
    errorMap: () => ({
      message: 'Wine type must be one of: Red, White, Rosé, Sparkling, Dessert, Fortified',
    }),
  }),
  quantity: z.number().int().min(1, 'Quantity must be at least 1'),
  storage_location_id: z.string().uuid('storage_location_id must be a valid UUID'),

  // Optional fields
  grape_variety: z.string().max(200).optional(),
  country: z.string().max(100).optional(),
  region: z.string().max(100).optional(),
  appellation: z.string().max(100).optional(),
  bottle_size: z.enum(BOTTLE_SIZES).default('750ML').optional(),
  purchase_date: z
    .string()
    .regex(/^\d{4}-\d{2}-\d{2}$/, 'purchase_date must be YYYY-MM-DD')
    .refine(
      (d) => new Date(d) <= new Date(),
      'Purchase date cannot be in the future'
    )
    .optional(),
  purchase_source: z.string().max(200).optional(),
  purchase_price: z.number().min(0).optional(),
  estimated_value: z.number().min(0).optional(),
  drink_window_start: z.number().int().min(1900).max(2200).optional(),
  drink_window_end: z.number().int().min(1900).max(2200).optional(),
  notes: z.string().max(5000).optional(),
}).refine(
  (d) =>
    d.drink_window_start == null ||
    d.drink_window_end == null ||
    d.drink_window_start <= d.drink_window_end,
  {
    message: 'Drink by start year must be before or equal to end year',
    path: ['drink_window_start'],
  }
);

// PUT /wines/:id — full replace; same shape as create
export const updateWineSchema = createWineSchema;

// PATCH /wines/:id — partial update; all fields optional
export const patchWineSchema = createWineSchema.partial().refine(
  (d) =>
    d.drink_window_start == null ||
    d.drink_window_end == null ||
    d.drink_window_start <= d.drink_window_end,
  {
    message: 'Drink by start year must be before or equal to end year',
    path: ['drink_window_start'],
  }
);

export type CreateWineRequest = z.infer<typeof createWineSchema>;
export type UpdateWineRequest = z.infer<typeof updateWineSchema>;
export type PatchWineRequest = z.infer<typeof patchWineSchema>;
```

---

**lib/business/readiness.ts** — Pure function per TechArch §2.2 and ADR-007. Copy the algorithm verbatim from TechArch:

```typescript
// lib/business/readiness.ts
// Per TechArch §2.2 ADR-007: readiness_status is NEVER stored in the DB.
// Called on every API response that includes a wine record.

export type ReadinessStatus =
  | 'DRINK_NOW'
  | 'APPROACHING_PEAK'
  | 'HOLD'
  | 'PAST_WINDOW'
  | 'NO_WINDOW_SET';

/**
 * Calculate drinking readiness status from window years and current UTC year.
 * Algorithm verbatim from TechArch §2.2:
 *   1. NO_WINDOW_SET  — both null
 *   2. DRINK_NOW      — currentYear >= start AND (no end OR currentYear <= end)
 *   3. APPROACHING_PEAK — currentYear >= start-2 AND currentYear < start
 *   4. HOLD           — currentYear < start-2
 *   5. PAST_WINDOW    — end is set AND currentYear > end
 */
export function calculateReadinessStatus(
  drinkWindowStart: number | null,
  drinkWindowEnd: number | null,
  currentYear: number = new Date().getUTCFullYear()
): ReadinessStatus {
  if (!drinkWindowStart && !drinkWindowEnd) return 'NO_WINDOW_SET';
  if (
    drinkWindowStart &&
    currentYear >= drinkWindowStart &&
    (!drinkWindowEnd || currentYear <= drinkWindowEnd)
  )
    return 'DRINK_NOW';
  if (
    drinkWindowStart &&
    currentYear >= drinkWindowStart - 2 &&
    currentYear < drinkWindowStart
  )
    return 'APPROACHING_PEAK';
  if (drinkWindowStart && currentYear < drinkWindowStart - 2) return 'HOLD';
  if (drinkWindowEnd && currentYear > drinkWindowEnd) return 'PAST_WINDOW';
  return 'NO_WINDOW_SET';
}
```

---

**lib/business/rating.ts** — latest_rating refresh logic per TechArch §2.2 ADR-008:

```typescript
// lib/business/rating.ts
// Per ADR-008: after any tasting_note insert/update/delete, refresh wines.latest_rating.
import { query } from '../db';

/**
 * Refresh the denormalized latest_rating columns on the wines row.
 * Queries the most recent tasting_note with a non-null personal_rating for wineId,
 * then updates wines.latest_rating, latest_rating_scale, latest_rating_date.
 * If no rated notes exist, sets all three to NULL.
 */
export async function refreshLatestRating(wineId: string): Promise<void> {
  const noteResult = await query(
    `SELECT personal_rating, rating_scale, date_tasted
       FROM tasting_notes
      WHERE wine_id = $1
        AND personal_rating IS NOT NULL
      ORDER BY date_tasted DESC, created_at DESC
      LIMIT 1`,
    [wineId]
  );

  if (noteResult.rows.length === 0) {
    // No rated notes — clear denormalized cache
    await query(
      `UPDATE wines
          SET latest_rating = NULL,
              latest_rating_scale = NULL,
              latest_rating_date = NULL,
              updated_at = NOW()
        WHERE wine_id = $1`,
      [wineId]
    );
  } else {
    const { personal_rating, rating_scale, date_tasted } = noteResult.rows[0];
    await query(
      `UPDATE wines
          SET latest_rating = $2,
              latest_rating_scale = $3,
              latest_rating_date = $4,
              updated_at = NOW()
        WHERE wine_id = $1`,
      [wineId, personal_rating, rating_scale, date_tasted]
    );
  }
}
```

---

**lib/business/location.ts** — location_unknown flag management per FRD F02.3 and TechArch §2.2:

```typescript
// lib/business/location.ts
// Per FRD F02.3: when a storage_location is deleted, set storage_location_id = NULL
// and location_unknown = TRUE on all affected wines. The FK ON DELETE SET NULL handles
// the nullification; this function sets the flag and returns the count.
import { query } from '../db';

/**
 * Flag all wines whose storage_location_id just became NULL due to location deletion.
 * Called by DELETE /api/v1/locations/:id BEFORE the location row is deleted,
 * so we can count affected wines and flag them in a single UPDATE.
 *
 * Returns the number of wines affected.
 */
export async function flagLocationUnknown(locationId: string): Promise<number> {
  const result = await query(
    `UPDATE wines
        SET location_unknown = TRUE,
            updated_at = NOW()
      WHERE storage_location_id = $1
  RETURNING wine_id`,
    [locationId]
  );
  return result.rowCount ?? 0;
}
```
  </action>
  <verify>
```bash
grep -n 'export.*createWineSchema\|export.*updateWineSchema\|export.*patchWineSchema' lib/validation/wines.ts && \
grep -n 'export function calculateReadinessStatus' lib/business/readiness.ts && \
grep -n 'export.*function refreshLatestRating' lib/business/rating.ts && \
grep -n 'export.*function flagLocationUnknown' lib/business/location.ts && \
grep -n 'export.*function createApiError' lib/errors.ts && \
echo "ALL BUSINESS LOGIC AND VALIDATION EXPORTS PRESENT"
```
  </verify>
  <done>
- lib/validation/wines.ts exports createWineSchema, updateWineSchema, patchWineSchema with all FRD F00 validation rules (required fields, vintage range 1900–currentYear+1, quantity ≥ 1, window start ≤ end, purchase_date not future)
- lib/business/readiness.ts exports calculateReadinessStatus() matching TechArch §2.2 algorithm verbatim (5 branches in order: NO_WINDOW_SET, DRINK_NOW, APPROACHING_PEAK, HOLD, PAST_WINDOW)
- lib/business/rating.ts exports refreshLatestRating(wineId) that queries most recent rated tasting note and updates wines denormalized columns or NULLs them if no rated notes remain
- lib/business/location.ts exports flagLocationUnknown(locationId) that UPDATEs affected wines before location delete and returns affected count
- lib/errors.ts exports createApiError() matching TechArch §4.2 ApiError envelope shape exactly
  </done>
</task>

<feature_dependencies>
Implements: F0: Wine Inventory CRUD validation rules (createWineSchema), F5: Drinking Window Management (calculateReadinessStatus — ADR-007 pure function)
Depends on: Wave 1 lib/db.ts (query import used by rating.ts and location.ts)
Enables: Task 2 route handlers (import all 5 modules), wave 2 plans 03 and 04 (import readiness, rating, location, errors)
</feature_dependencies>

<task type="auto">
  <name>Task 2: Wine SQL query layer and CRUD route handlers</name>
  <files>
    lib/queries/wines.ts
    app/api/v1/wines/route.ts
    app/api/v1/wines/[wine_id]/route.ts
  </files>
  <action>
Create the query layer and two Next.js App Router route files for Wines CRUD.

---

**lib/queries/wines.ts** — SQL query functions using raw node-postgres per ADR-003. The WineRecord shape is from TechArch §4.3. `readiness_status` is NOT stored; it is added by the route handler after each query.

```typescript
// lib/queries/wines.ts
import { query } from '../db';
import type { CreateWineRequest } from '../validation/wines';

// Row shape returned from DB (no readiness_status — computed by route)
export interface WineRow {
  wine_id: string;
  wine_name: string;
  producer: string;
  vintage_year: number;
  wine_type: string;
  grape_variety: string | null;
  country: string | null;
  region: string | null;
  appellation: string | null;
  bottle_size: string;
  quantity: number;
  is_open: boolean;
  storage_location_id: string | null;
  storage_location_name: string | null;
  location_unknown: boolean;
  purchase_date: string | null;
  purchase_source: string | null;
  purchase_price: number | null;
  estimated_value: number | null;
  drink_window_start: number | null;
  drink_window_end: number | null;
  notes: string | null;
  latest_rating: number | null;
  latest_rating_scale: string | null;
  latest_rating_date: string | null;
  created_at: string;
  updated_at: string;
}

export interface WineListParams {
  q?: string;
  wine_type?: string;    // comma-separated enum values
  producer?: string;
  country?: string;
  region?: string;
  vintage_from?: number;
  vintage_to?: number;
  grape_variety?: string;
  location_id?: string;  // UUID or 'unknown'
  sort?: string;
}

const BASE_SELECT = `
  SELECT
    w.wine_id, w.wine_name, w.producer, w.vintage_year, w.wine_type,
    w.grape_variety, w.country, w.region, w.appellation, w.bottle_size,
    w.quantity, w.is_open,
    w.storage_location_id, sl.location_name AS storage_location_name,
    w.location_unknown,
    w.purchase_date, w.purchase_source, w.purchase_price, w.estimated_value,
    w.drink_window_start, w.drink_window_end,
    w.notes, w.latest_rating, w.latest_rating_scale, w.latest_rating_date,
    w.created_at, w.updated_at
  FROM wines w
  LEFT JOIN storage_locations sl ON sl.location_id = w.storage_location_id
`;

const SORT_MAP: Record<string, string> = {
  created_at_desc: 'w.created_at DESC',
  created_at_asc: 'w.created_at ASC',
  wine_name_asc: 'w.wine_name ASC',
  wine_name_desc: 'w.wine_name DESC',
  vintage_year_desc: 'w.vintage_year DESC',
  vintage_year_asc: 'w.vintage_year ASC',
  quantity_desc: 'w.quantity DESC',
  quantity_asc: 'w.quantity ASC',
  rating_desc: 'w.latest_rating DESC NULLS LAST',
  rating_asc: 'w.latest_rating ASC NULLS LAST',
};

export async function listWines(
  params: WineListParams = {}
): Promise<{ rows: WineRow[]; total: number }> {
  const conditions: string[] = [];
  const values: unknown[] = [];
  let i = 1;

  if (params.wine_type) {
    const types = params.wine_type.split(',').map((t) => t.trim().toUpperCase());
    conditions.push(`w.wine_type = ANY($${i}::text[])`);
    values.push(types);
    i++;
  }
  if (params.producer) {
    conditions.push(`LOWER(w.producer) = LOWER($${i})`);
    values.push(params.producer);
    i++;
  }
  if (params.country) {
    conditions.push(`LOWER(w.country) = LOWER($${i})`);
    values.push(params.country);
    i++;
  }
  if (params.region) {
    conditions.push(`LOWER(w.region) = LOWER($${i})`);
    values.push(params.region);
    i++;
  }
  if (params.vintage_from != null) {
    conditions.push(`w.vintage_year >= $${i}`);
    values.push(params.vintage_from);
    i++;
  }
  if (params.vintage_to != null) {
    conditions.push(`w.vintage_year <= $${i}`);
    values.push(params.vintage_to);
    i++;
  }
  if (params.grape_variety) {
    conditions.push(`LOWER(w.grape_variety) LIKE LOWER($${i})`);
    values.push(`%${params.grape_variety}%`);
    i++;
  }
  if (params.location_id) {
    if (params.location_id === 'unknown') {
      conditions.push(`w.location_unknown = TRUE`);
    } else {
      conditions.push(`w.storage_location_id = $${i}`);
      values.push(params.location_id);
      i++;
    }
  }
  if (params.q) {
    conditions.push(
      `(LOWER(w.wine_name) LIKE LOWER($${i}) OR LOWER(w.producer) LIKE LOWER($${i}) OR LOWER(w.region) LIKE LOWER($${i}) OR LOWER(w.grape_variety) LIKE LOWER($${i}))`
    );
    values.push(`%${params.q}%`);
    i++;
  }

  const where = conditions.length > 0 ? `WHERE ${conditions.join(' AND ')}` : '';
  const orderBy = SORT_MAP[params.sort ?? ''] ?? SORT_MAP.created_at_desc;

  const dataResult = await query(
    `${BASE_SELECT} ${where} ORDER BY ${orderBy}`,
    values
  );
  const countResult = await query(
    `SELECT COUNT(*) AS total FROM wines w ${where}`,
    values
  );

  return {
    rows: dataResult.rows as WineRow[],
    total: parseInt((countResult.rows[0] as { total: string }).total, 10),
  };
}

export async function getWine(wineId: string): Promise<WineRow | null> {
  const result = await query(`${BASE_SELECT} WHERE w.wine_id = $1`, [wineId]);
  return result.rows.length > 0 ? (result.rows[0] as WineRow) : null;
}

export async function createWine(data: CreateWineRequest): Promise<WineRow> {
  // Verify storage_location_id exists
  const locCheck = await query(
    'SELECT location_id FROM storage_locations WHERE location_id = $1',
    [data.storage_location_id]
  );
  if (locCheck.rows.length === 0) {
    throw Object.assign(new Error('INVALID_REFERENCE'), { code: 'INVALID_REFERENCE' });
  }

  const result = await query(
    `INSERT INTO wines (
      wine_name, producer, vintage_year, wine_type, quantity, storage_location_id,
      grape_variety, country, region, appellation, bottle_size,
      purchase_date, purchase_source, purchase_price, estimated_value,
      drink_window_start, drink_window_end, notes
    ) VALUES (
      $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16,$17,$18
    )
    RETURNING wine_id`,
    [
      data.wine_name, data.producer, data.vintage_year, data.wine_type,
      data.quantity, data.storage_location_id,
      data.grape_variety ?? null, data.country ?? null, data.region ?? null,
      data.appellation ?? null, data.bottle_size ?? '750ML',
      data.purchase_date ?? null, data.purchase_source ?? null,
      data.purchase_price ?? null, data.estimated_value ?? null,
      data.drink_window_start ?? null, data.drink_window_end ?? null,
      data.notes ?? null,
    ]
  );
  const newId = (result.rows[0] as { wine_id: string }).wine_id;
  return (await getWine(newId))!;
}

export async function updateWine(
  wineId: string,
  data: CreateWineRequest
): Promise<WineRow | null> {
  // Verify storage_location_id exists
  const locCheck = await query(
    'SELECT location_id FROM storage_locations WHERE location_id = $1',
    [data.storage_location_id]
  );
  if (locCheck.rows.length === 0) {
    throw Object.assign(new Error('INVALID_REFERENCE'), { code: 'INVALID_REFERENCE' });
  }

  const result = await query(
    `UPDATE wines SET
      wine_name = $2, producer = $3, vintage_year = $4, wine_type = $5,
      quantity = $6, storage_location_id = $7,
      grape_variety = $8, country = $9, region = $10, appellation = $11,
      bottle_size = $12, purchase_date = $13, purchase_source = $14,
      purchase_price = $15, estimated_value = $16,
      drink_window_start = $17, drink_window_end = $18, notes = $19,
      location_unknown = FALSE,
      updated_at = NOW()
    WHERE wine_id = $1
    RETURNING wine_id`,
    [
      wineId,
      data.wine_name, data.producer, data.vintage_year, data.wine_type,
      data.quantity, data.storage_location_id,
      data.grape_variety ?? null, data.country ?? null, data.region ?? null,
      data.appellation ?? null, data.bottle_size ?? '750ML',
      data.purchase_date ?? null, data.purchase_source ?? null,
      data.purchase_price ?? null, data.estimated_value ?? null,
      data.drink_window_start ?? null, data.drink_window_end ?? null,
      data.notes ?? null,
    ]
  );
  if (result.rows.length === 0) return null;
  return getWine(wineId);
}

export async function deleteWine(wineId: string): Promise<boolean> {
  const result = await query('DELETE FROM wines WHERE wine_id = $1', [wineId]);
  return (result.rowCount ?? 0) > 0;
}
```

---

**app/api/v1/wines/route.ts** — GET (list) and POST (create) handlers. Per TechArch §4.1: list response uses `{ data, meta }` envelope; POST returns 201; readiness_status injected at response time.

```typescript
// app/api/v1/wines/route.ts
import { NextRequest, NextResponse } from 'next/server';
import { listWines, createWine } from '@/lib/queries/wines';
import { createWineSchema } from '@/lib/validation/wines';
import { calculateReadinessStatus } from '@/lib/business/readiness';
import { createApiError } from '@/lib/errors';
import type { WineRow } from '@/lib/queries/wines';

function attachReadiness(row: WineRow) {
  return {
    ...row,
    readiness_status: calculateReadinessStatus(
      row.drink_window_start,
      row.drink_window_end
    ),
  };
}

export async function GET(request: NextRequest) {
  try {
    const sp = request.nextUrl.searchParams;
    const params = {
      q: sp.get('q') ?? undefined,
      wine_type: sp.get('wine_type') ?? undefined,
      producer: sp.get('producer') ?? undefined,
      country: sp.get('country') ?? undefined,
      region: sp.get('region') ?? undefined,
      vintage_from: sp.get('vintage_from') ? Number(sp.get('vintage_from')) : undefined,
      vintage_to: sp.get('vintage_to') ? Number(sp.get('vintage_to')) : undefined,
      grape_variety: sp.get('grape_variety') ?? undefined,
      location_id: sp.get('location_id') ?? undefined,
      sort: sp.get('sort') ?? undefined,
    };

    const { rows, total } = await listWines(params);
    const data = rows.map(attachReadiness);

    return NextResponse.json(
      { data, meta: { total, filtered: data.length } },
      { status: 200 }
    );
  } catch (err) {
    console.error('[GET /api/v1/wines]', err);
    return NextResponse.json(
      createApiError('INTERNAL_ERROR', 'An unexpected error occurred'),
      { status: 500 }
    );
  }
}

export async function POST(request: NextRequest) {
  try {
    let body: unknown;
    try {
      body = await request.json();
    } catch {
      return NextResponse.json(
        createApiError('BAD_REQUEST', 'Invalid JSON body'),
        { status: 400 }
      );
    }

    const parsed = createWineSchema.safeParse(body);
    if (!parsed.success) {
      const details = parsed.error.errors.map((e) => ({
        field: e.path.join('.'),
        message: e.message,
      }));
      return NextResponse.json(
        createApiError('VALIDATION_ERROR', 'Validation failed', undefined, details),
        { status: 422 }
      );
    }

    let wine;
    try {
      wine = await createWine(parsed.data);
    } catch (err: unknown) {
      if ((err as { code?: string }).code === 'INVALID_REFERENCE') {
        return NextResponse.json(
          createApiError(
            'INVALID_REFERENCE',
            'The selected storage location no longer exists. Please choose another.',
            'storage_location_id'
          ),
          { status: 422 }
        );
      }
      throw err;
    }

    return NextResponse.json(attachReadiness(wine), { status: 201 });
  } catch (err) {
    console.error('[POST /api/v1/wines]', err);
    return NextResponse.json(
      createApiError('INTERNAL_ERROR', 'An unexpected error occurred'),
      { status: 500 }
    );
  }
}
```

---

**app/api/v1/wines/[wine_id]/route.ts** — GET, PUT, PATCH, DELETE handlers for single wine record. Per FRD F00: PUT is full replace; PATCH is partial; DELETE returns 204 with cascade.

```typescript
// app/api/v1/wines/[wine_id]/route.ts
import { NextRequest, NextResponse } from 'next/server';
import { getWine, updateWine, deleteWine } from '@/lib/queries/wines';
import { updateWineSchema, patchWineSchema } from '@/lib/validation/wines';
import { calculateReadinessStatus } from '@/lib/business/readiness';
import { createApiError } from '@/lib/errors';
import type { WineRow } from '@/lib/queries/wines';

interface RouteContext {
  params: { wine_id: string };
}

function attachReadiness(row: WineRow) {
  return {
    ...row,
    readiness_status: calculateReadinessStatus(
      row.drink_window_start,
      row.drink_window_end
    ),
  };
}

export async function GET(_request: NextRequest, { params }: RouteContext) {
  try {
    const wine = await getWine(params.wine_id);
    if (!wine) {
      return NextResponse.json(
        createApiError('WINE_NOT_FOUND', 'Wine record not found.'),
        { status: 404 }
      );
    }
    return NextResponse.json(attachReadiness(wine), { status: 200 });
  } catch (err) {
    console.error('[GET /api/v1/wines/:id]', err);
    return NextResponse.json(
      createApiError('INTERNAL_ERROR', 'An unexpected error occurred'),
      { status: 500 }
    );
  }
}

export async function PUT(request: NextRequest, { params }: RouteContext) {
  try {
    let body: unknown;
    try {
      body = await request.json();
    } catch {
      return NextResponse.json(
        createApiError('BAD_REQUEST', 'Invalid JSON body'),
        { status: 400 }
      );
    }

    const parsed = updateWineSchema.safeParse(body);
    if (!parsed.success) {
      const details = parsed.error.errors.map((e) => ({
        field: e.path.join('.'),
        message: e.message,
      }));
      return NextResponse.json(
        createApiError('VALIDATION_ERROR', 'Validation failed', undefined, details),
        { status: 422 }
      );
    }

    let wine;
    try {
      wine = await updateWine(params.wine_id, parsed.data);
    } catch (err: unknown) {
      if ((err as { code?: string }).code === 'INVALID_REFERENCE') {
        return NextResponse.json(
          createApiError(
            'INVALID_REFERENCE',
            'The selected storage location no longer exists. Please choose another.',
            'storage_location_id'
          ),
          { status: 422 }
        );
      }
      throw err;
    }

    if (!wine) {
      return NextResponse.json(
        createApiError('WINE_NOT_FOUND', 'Wine record not found.'),
        { status: 404 }
      );
    }
    return NextResponse.json(attachReadiness(wine), { status: 200 });
  } catch (err) {
    console.error('[PUT /api/v1/wines/:id]', err);
    return NextResponse.json(
      createApiError('INTERNAL_ERROR', 'An unexpected error occurred'),
      { status: 500 }
    );
  }
}

export async function PATCH(request: NextRequest, { params }: RouteContext) {
  try {
    // For PATCH: fetch existing wine first so we can merge
    const existing = await getWine(params.wine_id);
    if (!existing) {
      return NextResponse.json(
        createApiError('WINE_NOT_FOUND', 'Wine record not found.'),
        { status: 404 }
      );
    }

    let body: unknown;
    try {
      body = await request.json();
    } catch {
      return NextResponse.json(
        createApiError('BAD_REQUEST', 'Invalid JSON body'),
        { status: 400 }
      );
    }

    const parsed = patchWineSchema.safeParse(body);
    if (!parsed.success) {
      const details = parsed.error.errors.map((e) => ({
        field: e.path.join('.'),
        message: e.message,
      }));
      return NextResponse.json(
        createApiError('VALIDATION_ERROR', 'Validation failed', undefined, details),
        { status: 422 }
      );
    }

    // Merge patch fields over existing; use updateWine for the actual DB write
    const merged = {
      wine_name: parsed.data.wine_name ?? existing.wine_name,
      producer: parsed.data.producer ?? existing.producer,
      vintage_year: parsed.data.vintage_year ?? existing.vintage_year,
      wine_type: (parsed.data.wine_type ?? existing.wine_type) as
        | 'RED' | 'WHITE' | 'ROSE' | 'SPARKLING' | 'DESSERT' | 'FORTIFIED',
      quantity: parsed.data.quantity ?? existing.quantity,
      storage_location_id: parsed.data.storage_location_id ?? existing.storage_location_id ?? '',
      grape_variety: parsed.data.grape_variety ?? existing.grape_variety ?? undefined,
      country: parsed.data.country ?? existing.country ?? undefined,
      region: parsed.data.region ?? existing.region ?? undefined,
      appellation: parsed.data.appellation ?? existing.appellation ?? undefined,
      bottle_size: (parsed.data.bottle_size ?? existing.bottle_size) as
        | '375ML' | '750ML' | '1500ML' | '3000ML' | undefined,
      purchase_date: parsed.data.purchase_date ?? existing.purchase_date ?? undefined,
      purchase_source: parsed.data.purchase_source ?? existing.purchase_source ?? undefined,
      purchase_price: parsed.data.purchase_price ?? existing.purchase_price ?? undefined,
      estimated_value: parsed.data.estimated_value ?? existing.estimated_value ?? undefined,
      drink_window_start: parsed.data.drink_window_start ?? existing.drink_window_start ?? undefined,
      drink_window_end: parsed.data.drink_window_end ?? existing.drink_window_end ?? undefined,
      notes: parsed.data.notes ?? existing.notes ?? undefined,
    };

    let wine;
    try {
      wine = await updateWine(params.wine_id, merged);
    } catch (err: unknown) {
      if ((err as { code?: string }).code === 'INVALID_REFERENCE') {
        return NextResponse.json(
          createApiError(
            'INVALID_REFERENCE',
            'The selected storage location no longer exists. Please choose another.',
            'storage_location_id'
          ),
          { status: 422 }
        );
      }
      throw err;
    }

    if (!wine) {
      return NextResponse.json(
        createApiError('WINE_NOT_FOUND', 'Wine record not found.'),
        { status: 404 }
      );
    }
    return NextResponse.json(attachReadiness(wine), { status: 200 });
  } catch (err) {
    console.error('[PATCH /api/v1/wines/:id]', err);
    return NextResponse.json(
      createApiError('INTERNAL_ERROR', 'An unexpected error occurred'),
      { status: 500 }
    );
  }
}

export async function DELETE(_request: NextRequest, { params }: RouteContext) {
  try {
    const deleted = await deleteWine(params.wine_id);
    if (!deleted) {
      return NextResponse.json(
        createApiError('WINE_NOT_FOUND', 'Wine record not found.'),
        { status: 404 }
      );
    }
    // 204 No Content — cascade delete of bottle_events and tasting_notes handled by DB FK
    return new NextResponse(null, { status: 204 });
  } catch (err) {
    console.error('[DELETE /api/v1/wines/:id]', err);
    return NextResponse.json(
      createApiError('INTERNAL_ERROR', 'An unexpected error occurred'),
      { status: 500 }
    );
  }
}
```

**Directory structure note:** Ensure `app/api/v1/wines/` and `app/api/v1/wines/[wine_id]/` directories exist before writing route files. The `[wine_id]` folder name uses square brackets as required by Next.js App Router dynamic segments.
  </action>
  <verify>
```bash
grep -n 'export.*function listWines\|export.*function getWine\|export.*function createWine\|export.*function updateWine\|export.*function deleteWine' lib/queries/wines.ts && \
grep -n 'export.*function GET\|export.*GET' app/api/v1/wines/route.ts && \
grep -n 'export.*function POST\|export.*POST' app/api/v1/wines/route.ts && \
grep -n 'export.*function GET\|export.*function PUT\|export.*function PATCH\|export.*function DELETE' "app/api/v1/wines/[wine_id]/route.ts" && \
grep -n 'calculateReadinessStatus' app/api/v1/wines/route.ts && \
grep -n 'calculateReadinessStatus' "app/api/v1/wines/[wine_id]/route.ts" && \
echo "WINE QUERY LAYER AND ROUTE HANDLERS VALID"
```
  </verify>
  <done>
- lib/queries/wines.ts exports listWines, getWine, createWine, updateWine, deleteWine using raw parameterized SQL via lib/db.ts query helper
- listWines supports all query params from TechArch §4.5 (q, wine_type, producer, country, region, vintage_from/to, grape_variety, location_id, sort)
- app/api/v1/wines/route.ts: GET returns { data: WineRecord[], meta: { total, filtered } }; POST returns 201 WineRecord
- app/api/v1/wines/[wine_id]/route.ts: GET returns WineRecord or 404; PUT full-replaces and returns WineRecord; PATCH merges delta and returns WineRecord; DELETE returns 204
- All responses that include a WineRecord call calculateReadinessStatus() — readiness_status is NEVER read from DB
- Zod validation failures return 422 with details array; 404 uses WINE_NOT_FOUND error code; INVALID_REFERENCE returns 422 when storage_location_id FK fails
- Cascade delete of bottle_events and tasting_notes on DELETE is handled by DB FK constraints (ON DELETE CASCADE from wave 1 migration)
  </done>
</task>

<feature_dependencies>
Implements: F0: Wine Inventory CRUD (all 6 endpoints: GET /wines, POST /wines, GET /wines/:id, PUT /wines/:id, PATCH /wines/:id, DELETE /wines/:id), F5: Drinking Window Management (readiness_status injected on every wine response via calculateReadinessStatus)
Depends on: Task 1 (lib/validation/wines.ts, lib/business/readiness.ts, lib/errors.ts), Wave 1 lib/db.ts, wines table + storage_locations table
Enables: Wave 3 frontend can fetch/mutate wine records; Wave 2 plans 03/04 can import lib/business/* and lib/errors.ts; F3 filter params handled by listWines
</feature_dependencies>

</tasks>

<verification>
After both tasks complete, run these checks:

```bash
# 1. All 8 files exist
ls lib/validation/wines.ts lib/business/readiness.ts lib/business/rating.ts \
   lib/business/location.ts lib/errors.ts lib/queries/wines.ts \
   app/api/v1/wines/route.ts "app/api/v1/wines/[wine_id]/route.ts"

# 2. Critical exports present
grep -n 'export.*createWineSchema\|export.*updateWineSchema\|export.*patchWineSchema' lib/validation/wines.ts
grep -n 'export function calculateReadinessStatus' lib/business/readiness.ts
grep -n 'export.*refreshLatestRating' lib/business/rating.ts
grep -n 'export.*flagLocationUnknown' lib/business/location.ts
grep -n 'export.*createApiError' lib/errors.ts

# 3. readiness_status is calculated, never stored — no SELECT on readiness_status column
grep -rn 'readiness_status' lib/queries/wines.ts && echo "WARN: readiness stored in query — review" || echo "OK: readiness not stored in query layer"

# 4. Route handlers call calculateReadinessStatus
grep -n 'calculateReadinessStatus' app/api/v1/wines/route.ts
grep -n 'calculateReadinessStatus' "app/api/v1/wines/[wine_id]/route.ts"

# 5. Error codes match FRD F00 error table
grep -n 'WINE_NOT_FOUND\|VALIDATION_ERROR\|INVALID_REFERENCE' "app/api/v1/wines/[wine_id]/route.ts"

# 6. TypeScript compiles (if tsc available)
npx tsc --noEmit 2>&1 | head -30 || true
```
</verification>

<success_criteria>
- lib/validation/wines.ts: createWineSchema enforces all FRD F00 required fields; vintage_year 1900–(currentYear+1); quantity ≥ 1; drink_window_start ≤ drink_window_end; purchase_date not future
- lib/business/readiness.ts: calculateReadinessStatus() matches TechArch §2.2 algorithm exactly (5 branches, same order); is a pure function with no DB calls
- lib/business/rating.ts: refreshLatestRating() queries most recent rated tasting note and UPDATEs wines denormalized columns (or NULLs them); called by wave 2 plan 04 tasting note routes
- lib/business/location.ts: flagLocationUnknown() UPDATEs affected wines before location delete; returns count
- lib/errors.ts: createApiError() produces { error: { code, message, field?, details? } } matching TechArch §4.2
- lib/queries/wines.ts: all 5 functions use parameterized SQL, LEFT JOIN storage_locations, return WineRow (no readiness_status)
- GET /api/v1/wines: returns { data: [...], meta: { total, filtered } } with all filter/sort params supported
- POST /api/v1/wines: 201 on success; 422 + details on validation failure; 422 INVALID_REFERENCE if storage_location_id unknown
- GET /api/v1/wines/:id: 200 WineRecord or 404 WINE_NOT_FOUND
- PUT /api/v1/wines/:id: full replace; 200 or 404 or 422
- DELETE /api/v1/wines/:id: 204 No Content; cascade handled by DB FK; 404 if not found
- Every WineRecord in any response includes readiness_status computed by calculateReadinessStatus() — never from DB column
</success_criteria>

<output>
After completion, create `.planning/express/building-a-web-app-to-keep-track-of-my-w/02-SUMMARY.md` summarizing:
- Files created and their exports
- Validation rules enforced (Zod schema field list)
- Business logic modules available for import by wave 2 plans 03 and 04
- Readiness algorithm confirmation (ADR-007 pure function, never stored)
- Any deviations from TechArch specs (expected: none)
</output>
