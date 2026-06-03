---
phase: 02-backend
plan: 03
type: execute
wave: 3
depends_on: [1]
files_modified:
  - app/api/v1/wines/[wine_id]/events/route.ts
  - app/api/v1/wines/[wine_id]/quantity/route.ts
  - app/api/v1/locations/route.ts
  - app/api/v1/locations/[location_id]/route.ts
  - app/api/v1/settings/rating-scale/route.ts
  - lib/validation/events.ts
  - lib/validation/locations.ts
  - lib/validation/settings.ts
  - lib/queries/events.ts
  - lib/queries/locations.ts
  - lib/queries/settings.ts
  - lib/business/location.ts
autonomous: true

features:
  implements: ["F1", "F2", "F4"]
  depends_on: ["F0"]
  enables: ["F3", "F6"]

must_haves:
  truths:
    - "POST /api/v1/wines/:wine_id/events logs CONSUMED/GIFTED/OPENED, decrements quantity for CONSUMED/GIFTED, sets is_open for OPENED, rejects future dates and qty=0 CONSUMED/GIFTED"
    - "GET /api/v1/wines/:wine_id/events returns all bottle events for a wine in reverse-chronological order"
    - "PATCH /api/v1/wines/:wine_id/quantity adjusts quantity by +1 or -1, enforces floor of 0"
    - "GET /api/v1/locations returns all locations with SUM(quantity) bottle counts"
    - "POST /api/v1/locations creates a new location, enforces case-insensitive uniqueness (409 on duplicate)"
    - "PUT /api/v1/locations/:id renames a location with uniqueness validation"
    - "DELETE /api/v1/locations/:id sets storage_location_id=NULL and location_unknown=TRUE on affected wines, then deletes the location"
    - "GET /api/v1/settings/rating-scale returns current rating_scale from user_settings singleton"
    - "PUT /api/v1/settings/rating-scale updates rating_scale to STARS_5 or POINTS_100"
    - "lib/business/location.ts flagUnknown() updates wines with location_unknown=true when a location is deleted"
  artifacts:
    - path: "app/api/v1/wines/[wine_id]/events/route.ts"
      provides: "POST and GET bottle events endpoint"
      exports: ["POST", "GET"]
    - path: "app/api/v1/wines/[wine_id]/quantity/route.ts"
      provides: "PATCH quantity endpoint"
      exports: ["PATCH"]
    - path: "app/api/v1/locations/route.ts"
      provides: "GET list and POST create locations"
      exports: ["GET", "POST"]
    - path: "app/api/v1/locations/[location_id]/route.ts"
      provides: "PUT rename and DELETE location endpoints"
      exports: ["PUT", "DELETE"]
    - path: "app/api/v1/settings/rating-scale/route.ts"
      provides: "GET and PUT rating scale preference"
      exports: ["GET", "PUT"]
    - path: "lib/business/location.ts"
      provides: "flagUnknown() — sets location_unknown=true on wines when location deleted"
      exports: ["flagUnknownLocation"]
    - path: "lib/queries/events.ts"
      provides: "SQL queries for bottle events and quantity patch"
      exports: ["createBottleEvent", "listBottleEvents", "patchQuantity"]
    - path: "lib/queries/locations.ts"
      provides: "SQL queries for storage locations CRUD with bottle counts"
      exports: ["listLocations", "createLocation", "renameLocation", "deleteLocation"]
    - path: "lib/queries/settings.ts"
      provides: "SQL queries for user_settings singleton"
      exports: ["getSettings", "updateRatingScale"]
    - path: "lib/validation/events.ts"
      provides: "Zod schemas for bottle event and quantity inputs"
      exports: ["createBottleEventSchema", "quantityAdjustSchema"]
    - path: "lib/validation/locations.ts"
      provides: "Zod schemas for location inputs"
      exports: ["locationRequestSchema"]
    - path: "lib/validation/settings.ts"
      provides: "Zod schemas for settings inputs"
      exports: ["updateRatingScaleSchema"]
  key_links:
    - from: "app/api/v1/wines/[wine_id]/events/route.ts"
      to: "lib/queries/events.ts"
      via: "createBottleEvent / listBottleEvents"
      pattern: "createBottleEvent|listBottleEvents"
    - from: "app/api/v1/locations/[location_id]/route.ts"
      to: "lib/business/location.ts"
      via: "flagUnknownLocation called before DELETE"
      pattern: "flagUnknownLocation"
    - from: "lib/queries/events.ts"
      to: "lib/db.ts"
      via: "query()"
      pattern: "query\\("

integration_contracts:
  requires:
    - from_plan: "01"
      artifact: "lib/db.ts"
      exports: ["query", "pool"]
      verify: "grep -n 'export.*pool\\|export.*function query\\|export.*const query\\|export.*async function query' lib/db.ts && echo CONTRACT_OK"
    - from_plan: "01"
      artifact: "db/migrations/003_create_bottle_events.sql"
      exports: ["bottle_events"]
      verify: "grep -n 'CREATE TABLE bottle_events' db/migrations/003_create_bottle_events.sql && echo CONTRACT_OK"
    - from_plan: "01"
      artifact: "db/migrations/001_create_storage_locations.sql"
      exports: ["storage_locations"]
      verify: "grep -n 'CREATE TABLE storage_locations' db/migrations/001_create_storage_locations.sql && echo CONTRACT_OK"
    - from_plan: "01"
      artifact: "db/migrations/005_create_user_settings.sql"
      exports: ["user_settings"]
      verify: "grep -n 'CREATE TABLE user_settings' db/migrations/005_create_user_settings.sql && echo CONTRACT_OK"
  provides:
    - artifact: "app/api/v1/wines/[wine_id]/events/route.ts"
      exports: ["POST", "GET"]
      shape: |
        POST /api/v1/wines/:wine_id/events
        Request: { event_type: 'CONSUMED'|'GIFTED'|'OPENED', event_date: string, notes?: string, recipient?: string }
        Response (201): BottleEvent { event_id, wine_id, event_type, event_date, notes, recipient, tasting_note_id, created_at }
        Response (404): { error: { code: 'WINE_NOT_FOUND', message: string } }
        Response (422): { error: { code: 'QUANTITY_EMPTY'|'VALIDATION_ERROR', message: string } }

        GET /api/v1/wines/:wine_id/events
        Response (200): { data: BottleEvent[] }
      verify: "grep -n 'export.*POST\\|export.*GET\\|export async function POST\\|export async function GET' app/api/v1/wines/\\[wine_id\\]/events/route.ts && echo CONTRACT_OK"
    - artifact: "app/api/v1/wines/[wine_id]/quantity/route.ts"
      exports: ["PATCH"]
      shape: |
        PATCH /api/v1/wines/:wine_id/quantity
        Request: { adjustment: 1 | -1 }
        Response (200): { wine_id: string, quantity: number }
        Response (422): { error: { code: 'VALIDATION_ERROR', message: string } }
      verify: "grep -n 'export.*PATCH\\|export async function PATCH' app/api/v1/wines/\\[wine_id\\]/quantity/route.ts && echo CONTRACT_OK"
    - artifact: "app/api/v1/locations/route.ts"
      exports: ["GET", "POST"]
      shape: |
        GET /api/v1/locations
        Response (200): { data: StorageLocation[] }  -- each with bottle_count: SUM(quantity)

        POST /api/v1/locations
        Request: { location_name: string }
        Response (201): StorageLocation { location_id, location_name, created_at, updated_at }
        Response (409): { error: { code: 'DUPLICATE_LOCATION', message: string } }
        Response (422): { error: { code: 'VALIDATION_ERROR', message: string } }
      verify: "grep -n 'export.*GET\\|export.*POST\\|export async function GET\\|export async function POST' app/api/v1/locations/route.ts && echo CONTRACT_OK"
    - artifact: "app/api/v1/locations/[location_id]/route.ts"
      exports: ["PUT", "DELETE"]
      shape: |
        PUT /api/v1/locations/:location_id
        Request: { location_name: string }
        Response (200): StorageLocation
        Response (404): { error: { code: 'LOCATION_NOT_FOUND', message: string } }
        Response (409): { error: { code: 'DUPLICATE_LOCATION', message: string } }

        DELETE /api/v1/locations/:location_id
        Response (200): { deleted_location_id: string, affected_wines_count: number }
        Response (404): { error: { code: 'LOCATION_NOT_FOUND', message: string } }
      verify: "grep -n 'export.*PUT\\|export.*DELETE\\|export async function PUT\\|export async function DELETE' app/api/v1/locations/\\[location_id\\]/route.ts && echo CONTRACT_OK"
    - artifact: "app/api/v1/settings/rating-scale/route.ts"
      exports: ["GET", "PUT"]
      shape: |
        GET /api/v1/settings/rating-scale
        Response (200): { rating_scale: 'STARS_5' | 'POINTS_100' }

        PUT /api/v1/settings/rating-scale
        Request: { rating_scale: 'STARS_5' | 'POINTS_100' }
        Response (200): { rating_scale: 'STARS_5' | 'POINTS_100' }
        Response (422): { error: { code: 'VALIDATION_ERROR', message: string } }
      verify: "grep -n 'export.*GET\\|export.*PUT\\|export async function GET\\|export async function PUT' app/api/v1/settings/rating-scale/route.ts && echo CONTRACT_OK"
    - artifact: "lib/business/location.ts"
      exports: ["flagUnknownLocation"]
      shape: |
        export async function flagUnknownLocation(locationId: string): Promise<{ affectedCount: number }>
        -- Sets storage_location_id=NULL, location_unknown=true on wines WHERE storage_location_id=$1
      verify: "grep -n 'export.*flagUnknownLocation\\|export async function flagUnknownLocation' lib/business/location.ts && echo CONTRACT_OK"
    - artifact: "lib/queries/events.ts"
      exports: ["createBottleEvent", "listBottleEvents", "patchQuantity"]
      shape: |
        export async function createBottleEvent(wineId: string, data: CreateBottleEventRequest): Promise<BottleEvent>
        export async function listBottleEvents(wineId: string): Promise<BottleEvent[]>
        export async function patchQuantity(wineId: string, adjustment: 1 | -1): Promise<{ wine_id: string, quantity: number }>
      verify: "grep -n 'export.*createBottleEvent\\|export.*listBottleEvents\\|export.*patchQuantity' lib/queries/events.ts && echo CONTRACT_OK"
    - artifact: "lib/queries/locations.ts"
      exports: ["listLocations", "createLocation", "renameLocation", "deleteLocation"]
      shape: |
        export async function listLocations(): Promise<StorageLocation[]>
        export async function createLocation(name: string): Promise<StorageLocation>
        export async function renameLocation(locationId: string, newName: string): Promise<StorageLocation>
        export async function deleteLocation(locationId: string): Promise<void>
      verify: "grep -n 'export.*listLocations\\|export.*createLocation\\|export.*renameLocation\\|export.*deleteLocation' lib/queries/locations.ts && echo CONTRACT_OK"
    - artifact: "lib/queries/settings.ts"
      exports: ["getSettings", "updateRatingScale"]
      shape: |
        export async function getSettings(): Promise<{ rating_scale: 'STARS_5' | 'POINTS_100' }>
        export async function updateRatingScale(scale: 'STARS_5' | 'POINTS_100'): Promise<{ rating_scale: 'STARS_5' | 'POINTS_100' }>
      verify: "grep -n 'export.*getSettings\\|export.*updateRatingScale' lib/queries/settings.ts && echo CONTRACT_OK"
---

<objective>
Implement the second backend API slice: bottle event endpoints (POST/GET /api/v1/wines/:wine_id/events), quantity PATCH endpoint, storage locations CRUD (/api/v1/locations), and settings endpoint (/api/v1/settings/rating-scale). Includes all Zod validation schemas, SQL query modules, and the location.ts business logic for flagging wines as "Location Unknown" on location delete.

Purpose: Completes the F1 (bottle tracking) and F2 (storage locations) API surface consumed by wave 3 frontend, and provides the settings endpoint required by F4 tasting notes rating scale.
Output: 5 API route handlers, 6 lib/ modules (3 query files, 3 validation files, 1 business logic file).
</objective>

<feature_dependencies>
Implements: F1: Quantity & Bottle Status Tracking (POST/GET /events, PATCH /quantity, createBottleEvent, patchQuantity), F2: Storage Location Management (GET/POST /locations, PUT/DELETE /locations/:id, flagUnknownLocation), F4 partial: Settings endpoint (GET/PUT /settings/rating-scale used by tasting notes rating scale preference)
Depends on: F0: Wine CRUD (wines table + lib/db.ts from plan 01; wines endpoints from plan 02)
Enables: F3: Search & Filter (location filter requires location data), F6: Dashboard (recently consumed events)
</feature_dependencies>

<execution_context>
@/app/workspaces/.pivota-home/opencode-xdg/opencode/pivota_spec-framework/workflows/execute-plan.md
</execution_context>

<context>
@.planning/PROJECT.md
@.planning/express/building-a-web-app-to-keep-track-of-my-w/WAVE-SCHEDULE.md
@project_specs/TechArch-SimpleWineApp.md
@project_specs/FRD-SimpleWineApp.md
</context>

<tasks>

<task type="auto">
  <name>Task 1: Bottle events endpoints + quantity PATCH + validation + query modules</name>
  <files>
    app/api/v1/wines/[wine_id]/events/route.ts
    app/api/v1/wines/[wine_id]/quantity/route.ts
    lib/validation/events.ts
    lib/queries/events.ts
  </files>
  <action>
Create the Zod validation schemas, SQL query module, and two API route handlers for bottle events and quantity adjustment.

**lib/validation/events.ts** — Zod schemas per TechArch §4.3 BottleEvent Interfaces:

```typescript
import { z } from 'zod';

export const createBottleEventSchema = z.object({
  event_type: z.enum(['CONSUMED', 'GIFTED', 'OPENED']),
  event_date: z.string().regex(/^\d{4}-\d{2}-\d{2}$/, 'event_date must be YYYY-MM-DD')
    .refine(d => new Date(d) <= new Date(), { message: 'Event date cannot be in the future.' }),
  notes: z.string().max(500, 'Notes must be 500 characters or fewer.').optional(),
  recipient: z.string().max(200, 'Recipient must be 200 characters or fewer.').optional(),
});

export const quantityAdjustSchema = z.object({
  adjustment: z.union([z.literal(1), z.literal(-1)]),
});

export type CreateBottleEventRequest = z.infer<typeof createBottleEventSchema>;
export type QuantityAdjustRequest = z.infer<typeof quantityAdjustSchema>;
```

**lib/queries/events.ts** — Raw SQL via node-postgres per TechArch ADR-003. All queries parameterized.

Key behaviors per FRD F01:
- `createBottleEvent`: CONSUMED/GIFTED decrements quantity by 1; OPENED sets is_open=true (no qty decrement). Rejects CONSUMED/GIFTED when quantity=0 (QUANTITY_EMPTY). For CONSUMED/GIFTED also clears is_open=false after decrement.
- `listBottleEvents`: Returns reverse-chronological list (ORDER BY event_date DESC, created_at DESC).
- `patchQuantity`: Adjusts by +1 or -1; quantity floor is 0 (UPDATE ... SET quantity = GREATEST(quantity + $2, 0)).

```typescript
import { query } from '../db';

export interface BottleEvent {
  event_id: string;
  wine_id: string;
  event_type: 'CONSUMED' | 'GIFTED' | 'OPENED';
  event_date: string;
  notes: string | null;
  recipient: string | null;
  tasting_note_id: string | null;
  created_at: string;
}

export class QuantityEmptyError extends Error {
  constructor() {
    super('No bottles remain in the cellar for this wine.');
    this.name = 'QuantityEmptyError';
  }
}

export async function createBottleEvent(
  wineId: string,
  data: { event_type: string; event_date: string; notes?: string; recipient?: string }
): Promise<BottleEvent> {
  // Check wine exists and get current quantity
  const wineResult = await query(
    'SELECT wine_id, quantity FROM wines WHERE wine_id = $1',
    [wineId]
  );
  if (wineResult.rows.length === 0) {
    throw Object.assign(new Error('Wine record not found.'), { code: 'WINE_NOT_FOUND' });
  }
  const currentQty = wineResult.rows[0].quantity;

  // Block CONSUMED/GIFTED at quantity=0
  if ((data.event_type === 'CONSUMED' || data.event_type === 'GIFTED') && currentQty === 0) {
    throw new QuantityEmptyError();
  }

  // Insert event
  const eventResult = await query(
    `INSERT INTO bottle_events (event_id, wine_id, event_type, event_date, notes, recipient)
     VALUES (gen_random_uuid(), $1, $2, $3, $4, $5)
     RETURNING event_id, wine_id, event_type, event_date::text, notes, recipient, tasting_note_id, created_at`,
    [wineId, data.event_type, data.event_date, data.notes ?? null, data.recipient ?? null]
  );

  // Post-event wine updates
  if (data.event_type === 'CONSUMED' || data.event_type === 'GIFTED') {
    await query(
      'UPDATE wines SET quantity = GREATEST(quantity - 1, 0), is_open = FALSE, updated_at = NOW() WHERE wine_id = $1',
      [wineId]
    );
  } else if (data.event_type === 'OPENED') {
    await query(
      'UPDATE wines SET is_open = TRUE, updated_at = NOW() WHERE wine_id = $1',
      [wineId]
    );
  }

  return eventResult.rows[0];
}

export async function listBottleEvents(wineId: string): Promise<BottleEvent[]> {
  const result = await query(
    `SELECT event_id, wine_id, event_type, event_date::text, notes, recipient, tasting_note_id, created_at
     FROM bottle_events
     WHERE wine_id = $1
     ORDER BY event_date DESC, created_at DESC`,
    [wineId]
  );
  return result.rows;
}

export async function patchQuantity(
  wineId: string,
  adjustment: 1 | -1
): Promise<{ wine_id: string; quantity: number }> {
  const result = await query(
    `UPDATE wines
     SET quantity = GREATEST(quantity + $2, 0), updated_at = NOW()
     WHERE wine_id = $1
     RETURNING wine_id, quantity`,
    [wineId, adjustment]
  );
  if (result.rows.length === 0) {
    throw Object.assign(new Error('Wine record not found.'), { code: 'WINE_NOT_FOUND' });
  }
  return result.rows[0];
}
```

**app/api/v1/wines/[wine_id]/events/route.ts** — Next.js App Router route handler. Import from `lib/errors.ts` for consistent error responses (create that file if plan 02 didn't — see note below).

```typescript
import { NextRequest, NextResponse } from 'next/server';
import { createBottleEventSchema } from '@/lib/validation/events';
import { createBottleEvent, listBottleEvents, QuantityEmptyError } from '@/lib/queries/events';

export async function POST(
  req: NextRequest,
  { params }: { params: { wine_id: string } }
) {
  try {
    const body = await req.json().catch(() => null);
    if (!body) {
      return NextResponse.json(
        { error: { code: 'BAD_REQUEST', message: 'Request body must be valid JSON.' } },
        { status: 400 }
      );
    }
    const parsed = createBottleEventSchema.safeParse(body);
    if (!parsed.success) {
      return NextResponse.json(
        {
          error: {
            code: 'VALIDATION_ERROR',
            message: parsed.error.errors[0].message,
            details: parsed.error.errors.map(e => ({ field: e.path.join('.'), message: e.message })),
          },
        },
        { status: 422 }
      );
    }
    const event = await createBottleEvent(params.wine_id, parsed.data);
    return NextResponse.json(event, { status: 201 });
  } catch (err: any) {
    if (err?.code === 'WINE_NOT_FOUND') {
      return NextResponse.json({ error: { code: 'WINE_NOT_FOUND', message: err.message } }, { status: 404 });
    }
    if (err?.name === 'QuantityEmptyError') {
      return NextResponse.json({ error: { code: 'QUANTITY_EMPTY', message: err.message } }, { status: 422 });
    }
    console.error('[POST /events]', err);
    return NextResponse.json({ error: { code: 'INTERNAL_ERROR', message: 'Internal server error.' } }, { status: 500 });
  }
}

export async function GET(
  _req: NextRequest,
  { params }: { params: { wine_id: string } }
) {
  try {
    const events = await listBottleEvents(params.wine_id);
    return NextResponse.json({ data: events });
  } catch (err: any) {
    console.error('[GET /events]', err);
    return NextResponse.json({ error: { code: 'INTERNAL_ERROR', message: 'Internal server error.' } }, { status: 500 });
  }
}
```

**app/api/v1/wines/[wine_id]/quantity/route.ts**:

```typescript
import { NextRequest, NextResponse } from 'next/server';
import { quantityAdjustSchema } from '@/lib/validation/events';
import { patchQuantity } from '@/lib/queries/events';

export async function PATCH(
  req: NextRequest,
  { params }: { params: { wine_id: string } }
) {
  try {
    const body = await req.json().catch(() => null);
    if (!body) {
      return NextResponse.json(
        { error: { code: 'BAD_REQUEST', message: 'Request body must be valid JSON.' } },
        { status: 400 }
      );
    }
    const parsed = quantityAdjustSchema.safeParse(body);
    if (!parsed.success) {
      return NextResponse.json(
        {
          error: {
            code: 'VALIDATION_ERROR',
            message: 'adjustment must be 1 or -1.',
            details: parsed.error.errors.map(e => ({ field: e.path.join('.'), message: e.message })),
          },
        },
        { status: 422 }
      );
    }
    const result = await patchQuantity(params.wine_id, parsed.data.adjustment);
    return NextResponse.json(result);
  } catch (err: any) {
    if (err?.code === 'WINE_NOT_FOUND') {
      return NextResponse.json({ error: { code: 'WINE_NOT_FOUND', message: err.message } }, { status: 404 });
    }
    console.error('[PATCH /quantity]', err);
    return NextResponse.json({ error: { code: 'INTERNAL_ERROR', message: 'Internal server error.' } }, { status: 500 });
  }
}
```

**Note on lib/errors.ts:** If plan 02 did not create a `lib/errors.ts` factory, inline error responses as shown above. If it does exist, import and use it for consistency.

**Directory creation note:** Ensure Next.js App Router directory structure exists:
- `app/api/v1/wines/[wine_id]/events/` — create this nested directory tree
- `app/api/v1/wines/[wine_id]/quantity/` — create this directory
  </action>
  <verify>
```bash
grep -n 'export async function POST\|export async function GET' app/api/v1/wines/\[wine_id\]/events/route.ts && grep -n 'export async function PATCH' app/api/v1/wines/\[wine_id\]/quantity/route.ts && grep -n 'createBottleEventSchema\|quantityAdjustSchema' lib/validation/events.ts && grep -n 'export.*createBottleEvent\|export.*listBottleEvents\|export.*patchQuantity' lib/queries/events.ts && grep -n 'GREATEST\|quantity' lib/queries/events.ts && echo "EVENTS_ROUTES_OK"
```
  </verify>
  <done>
- lib/validation/events.ts exports createBottleEventSchema (event_type enum, event_date not-future, notes ≤500, recipient ≤200) and quantityAdjustSchema (adjustment: 1 | -1)
- lib/queries/events.ts exports createBottleEvent (blocks CONSUMED/GIFTED at qty=0, decrements qty, clears is_open for CONSUMED/GIFTED, sets is_open for OPENED), listBottleEvents (reverse-chronological), patchQuantity (GREATEST floor 0)
- POST /api/v1/wines/:wine_id/events returns 201 on success, 404 WINE_NOT_FOUND, 422 QUANTITY_EMPTY or VALIDATION_ERROR
- GET /api/v1/wines/:wine_id/events returns { data: BottleEvent[] }
- PATCH /api/v1/wines/:wine_id/quantity returns 200 { wine_id, quantity }, 422 on invalid adjustment, 404 if wine not found
  </done>
</task>

<task type="auto">
  <name>Task 2: Storage locations CRUD + settings endpoint + location business logic</name>
  <files>
    app/api/v1/locations/route.ts
    app/api/v1/locations/[location_id]/route.ts
    app/api/v1/settings/rating-scale/route.ts
    lib/validation/locations.ts
    lib/validation/settings.ts
    lib/queries/locations.ts
    lib/queries/settings.ts
    lib/business/location.ts
  </files>
  <action>
Create validation schemas, query modules, business logic, and route handlers for storage locations CRUD and the settings rating-scale endpoint.

**lib/validation/locations.ts** — per TechArch §4.3 LocationRequest:

```typescript
import { z } from 'zod';

export const locationRequestSchema = z.object({
  location_name: z.string()
    .min(1, 'Location name is required.')
    .max(100, 'Location name must be 100 characters or fewer.')
    .trim(),
});

export type LocationRequest = z.infer<typeof locationRequestSchema>;
```

**lib/validation/settings.ts** — per TechArch §4.3 UpdateRatingScaleRequest:

```typescript
import { z } from 'zod';

export const updateRatingScaleSchema = z.object({
  rating_scale: z.enum(['STARS_5', 'POINTS_100']),
});

export type UpdateRatingScaleRequest = z.infer<typeof updateRatingScaleSchema>;
```

**lib/business/location.ts** — location_unknown flag management per TechArch §2.2 and FRD F02.3:

```typescript
import { query } from '../db';

/**
 * When a storage location is about to be deleted, set storage_location_id=NULL
 * and location_unknown=TRUE on all wines currently assigned to that location.
 * Returns the count of affected wine records.
 */
export async function flagUnknownLocation(locationId: string): Promise<{ affectedCount: number }> {
  const result = await query(
    `UPDATE wines
     SET storage_location_id = NULL,
         location_unknown = TRUE,
         updated_at = NOW()
     WHERE storage_location_id = $1
     RETURNING wine_id`,
    [locationId]
  );
  return { affectedCount: result.rowCount ?? 0 };
}
```

**lib/queries/locations.ts** — per TechArch §4.3 StorageLocation interface. GET includes SUM(quantity) as bottle_count (JOIN to wines). Case-insensitive uniqueness via LOWER() per DDL constraint.

```typescript
import { query } from '../db';

export interface StorageLocation {
  location_id: string;
  location_name: string;
  bottle_count?: number;
  created_at: string;
  updated_at: string;
}

export class DuplicateLocationError extends Error {
  constructor() {
    super('A location with that name already exists.');
    this.name = 'DuplicateLocationError';
  }
}

export class LocationNotFoundError extends Error {
  constructor() {
    super('Storage location not found.');
    this.name = 'LocationNotFoundError';
  }
}

export async function listLocations(): Promise<StorageLocation[]> {
  const result = await query(
    `SELECT sl.location_id, sl.location_name,
            COALESCE(SUM(w.quantity), 0)::int AS bottle_count,
            sl.created_at, sl.updated_at
     FROM storage_locations sl
     LEFT JOIN wines w ON w.storage_location_id = sl.location_id AND w.quantity > 0
     GROUP BY sl.location_id, sl.location_name, sl.created_at, sl.updated_at
     ORDER BY sl.location_name ASC`
  );
  return result.rows;
}

export async function createLocation(name: string): Promise<StorageLocation> {
  try {
    const result = await query(
      `INSERT INTO storage_locations (location_id, location_name)
       VALUES (gen_random_uuid(), $1)
       RETURNING location_id, location_name, created_at, updated_at`,
      [name]
    );
    return { ...result.rows[0], bottle_count: 0 };
  } catch (err: any) {
    // PostgreSQL unique constraint violation
    if (err.code === '23505') throw new DuplicateLocationError();
    throw err;
  }
}

export async function renameLocation(locationId: string, newName: string): Promise<StorageLocation> {
  try {
    const result = await query(
      `UPDATE storage_locations
       SET location_name = $2, updated_at = NOW()
       WHERE location_id = $1
       RETURNING location_id, location_name, created_at, updated_at`,
      [locationId, newName]
    );
    if (result.rows.length === 0) throw new LocationNotFoundError();
    return result.rows[0];
  } catch (err: any) {
    if (err.code === '23505') throw new DuplicateLocationError();
    throw err;
  }
}

export async function deleteLocation(locationId: string): Promise<void> {
  const result = await query(
    'DELETE FROM storage_locations WHERE location_id = $1 RETURNING location_id',
    [locationId]
  );
  if (result.rows.length === 0) throw new LocationNotFoundError();
}
```

**lib/queries/settings.ts** — singleton user_settings table. GET fetches the one row; PUT updates it. If no row exists (shouldn't happen after migration seed, but defensive), upsert.

```typescript
import { query } from '../db';

export async function getSettings(): Promise<{ rating_scale: 'STARS_5' | 'POINTS_100' }> {
  const result = await query('SELECT rating_scale FROM user_settings LIMIT 1');
  if (result.rows.length === 0) {
    // Seed row should always exist (migration 005), but defensive fallback
    return { rating_scale: 'STARS_5' };
  }
  return { rating_scale: result.rows[0].rating_scale };
}

export async function updateRatingScale(
  scale: 'STARS_5' | 'POINTS_100'
): Promise<{ rating_scale: 'STARS_5' | 'POINTS_100' }> {
  const result = await query(
    `UPDATE user_settings SET rating_scale = $1, updated_at = NOW()
     RETURNING rating_scale`,
    [scale]
  );
  if (result.rows.length === 0) {
    // Upsert if row missing
    const inserted = await query(
      `INSERT INTO user_settings (rating_scale) VALUES ($1)
       ON CONFLICT DO NOTHING
       RETURNING rating_scale`,
      [scale]
    );
    return { rating_scale: inserted.rows[0]?.rating_scale ?? scale };
  }
  return { rating_scale: result.rows[0].rating_scale };
}
```

**app/api/v1/locations/route.ts** — GET list + POST create:

```typescript
import { NextRequest, NextResponse } from 'next/server';
import { locationRequestSchema } from '@/lib/validation/locations';
import { listLocations, createLocation, DuplicateLocationError } from '@/lib/queries/locations';

export async function GET() {
  try {
    const locations = await listLocations();
    return NextResponse.json({ data: locations });
  } catch (err) {
    console.error('[GET /locations]', err);
    return NextResponse.json({ error: { code: 'INTERNAL_ERROR', message: 'Internal server error.' } }, { status: 500 });
  }
}

export async function POST(req: NextRequest) {
  try {
    const body = await req.json().catch(() => null);
    if (!body) {
      return NextResponse.json({ error: { code: 'BAD_REQUEST', message: 'Request body must be valid JSON.' } }, { status: 400 });
    }
    const parsed = locationRequestSchema.safeParse(body);
    if (!parsed.success) {
      return NextResponse.json(
        { error: { code: 'VALIDATION_ERROR', message: parsed.error.errors[0].message } },
        { status: 422 }
      );
    }
    const location = await createLocation(parsed.data.location_name);
    return NextResponse.json(location, { status: 201 });
  } catch (err: any) {
    if (err?.name === 'DuplicateLocationError') {
      return NextResponse.json({ error: { code: 'DUPLICATE_LOCATION', message: err.message } }, { status: 409 });
    }
    console.error('[POST /locations]', err);
    return NextResponse.json({ error: { code: 'INTERNAL_ERROR', message: 'Internal server error.' } }, { status: 500 });
  }
}
```

**app/api/v1/locations/[location_id]/route.ts** — PUT rename + DELETE. DELETE calls `flagUnknownLocation` BEFORE deleting the location row (order matters for FK integrity — wines.storage_location_id is SET NULL by DB cascade too, but we need location_unknown=TRUE set by app logic first):

```typescript
import { NextRequest, NextResponse } from 'next/server';
import { locationRequestSchema } from '@/lib/validation/locations';
import { renameLocation, deleteLocation, DuplicateLocationError, LocationNotFoundError } from '@/lib/queries/locations';
import { flagUnknownLocation } from '@/lib/business/location';

export async function PUT(
  req: NextRequest,
  { params }: { params: { location_id: string } }
) {
  try {
    const body = await req.json().catch(() => null);
    if (!body) {
      return NextResponse.json({ error: { code: 'BAD_REQUEST', message: 'Request body must be valid JSON.' } }, { status: 400 });
    }
    const parsed = locationRequestSchema.safeParse(body);
    if (!parsed.success) {
      return NextResponse.json(
        { error: { code: 'VALIDATION_ERROR', message: parsed.error.errors[0].message } },
        { status: 422 }
      );
    }
    const location = await renameLocation(params.location_id, parsed.data.location_name);
    return NextResponse.json(location);
  } catch (err: any) {
    if (err?.name === 'LocationNotFoundError') {
      return NextResponse.json({ error: { code: 'LOCATION_NOT_FOUND', message: err.message } }, { status: 404 });
    }
    if (err?.name === 'DuplicateLocationError') {
      return NextResponse.json({ error: { code: 'DUPLICATE_LOCATION', message: err.message } }, { status: 409 });
    }
    console.error('[PUT /locations/:id]', err);
    return NextResponse.json({ error: { code: 'INTERNAL_ERROR', message: 'Internal server error.' } }, { status: 500 });
  }
}

export async function DELETE(
  _req: NextRequest,
  { params }: { params: { location_id: string } }
) {
  try {
    // 1. Flag affected wines as location_unknown BEFORE deleting location
    //    (DB cascade will NULL the FK, but app must set location_unknown=true first)
    const { affectedCount } = await flagUnknownLocation(params.location_id);

    // 2. Delete the location (DB ON DELETE SET NULL handles FK nullification;
    //    flagUnknownLocation above already set location_unknown=true)
    await deleteLocation(params.location_id);

    return NextResponse.json({
      deleted_location_id: params.location_id,
      affected_wines_count: affectedCount,
    });
  } catch (err: any) {
    if (err?.name === 'LocationNotFoundError') {
      return NextResponse.json({ error: { code: 'LOCATION_NOT_FOUND', message: err.message } }, { status: 404 });
    }
    console.error('[DELETE /locations/:id]', err);
    return NextResponse.json({ error: { code: 'INTERNAL_ERROR', message: 'Internal server error.' } }, { status: 500 });
  }
}
```

**app/api/v1/settings/rating-scale/route.ts**:

```typescript
import { NextRequest, NextResponse } from 'next/server';
import { updateRatingScaleSchema } from '@/lib/validation/settings';
import { getSettings, updateRatingScale } from '@/lib/queries/settings';

export async function GET() {
  try {
    const settings = await getSettings();
    return NextResponse.json(settings);
  } catch (err) {
    console.error('[GET /settings/rating-scale]', err);
    return NextResponse.json({ error: { code: 'INTERNAL_ERROR', message: 'Internal server error.' } }, { status: 500 });
  }
}

export async function PUT(req: NextRequest) {
  try {
    const body = await req.json().catch(() => null);
    if (!body) {
      return NextResponse.json({ error: { code: 'BAD_REQUEST', message: 'Request body must be valid JSON.' } }, { status: 400 });
    }
    const parsed = updateRatingScaleSchema.safeParse(body);
    if (!parsed.success) {
      return NextResponse.json(
        {
          error: {
            code: 'VALIDATION_ERROR',
            message: "rating_scale must be 'STARS_5' or 'POINTS_100'.",
          },
        },
        { status: 422 }
      );
    }
    const settings = await updateRatingScale(parsed.data.rating_scale);
    return NextResponse.json(settings);
  } catch (err) {
    console.error('[PUT /settings/rating-scale]', err);
    return NextResponse.json({ error: { code: 'INTERNAL_ERROR', message: 'Internal server error.' } }, { status: 500 });
  }
}
```

**Directory creation:** Create App Router directory structure:
- `app/api/v1/locations/` (route.ts here)
- `app/api/v1/locations/[location_id]/` (route.ts here)
- `app/api/v1/settings/rating-scale/` (route.ts here)
  </action>
  <verify>
```bash
grep -n 'export async function GET\|export async function POST' app/api/v1/locations/route.ts && grep -n 'export async function PUT\|export async function DELETE' app/api/v1/locations/\[location_id\]/route.ts && grep -n 'flagUnknownLocation' app/api/v1/locations/\[location_id\]/route.ts && grep -n 'export.*flagUnknownLocation\|export async function flagUnknownLocation' lib/business/location.ts && grep -n 'export.*getSettings\|export.*updateRatingScale' lib/queries/settings.ts && grep -n 'export.*listLocations\|export.*createLocation\|export.*renameLocation\|export.*deleteLocation' lib/queries/locations.ts && grep -n 'export async function GET\|export async function PUT' app/api/v1/settings/rating-scale/route.ts && echo "LOCATIONS_SETTINGS_OK"
```
  </verify>
  <done>
- lib/validation/locations.ts exports locationRequestSchema (name 1-100 chars, trimmed)
- lib/validation/settings.ts exports updateRatingScaleSchema (enum STARS_5|POINTS_100)
- lib/business/location.ts exports flagUnknownLocation(locationId) → sets storage_location_id=NULL, location_unknown=TRUE, returns affectedCount
- lib/queries/locations.ts exports listLocations (with SUM(quantity) bottle_count JOIN), createLocation (throws DuplicateLocationError on 23505), renameLocation, deleteLocation (throws LocationNotFoundError if missing)
- lib/queries/settings.ts exports getSettings (SELECT from user_settings singleton), updateRatingScale (UPDATE + fallback INSERT)
- GET /api/v1/locations returns { data: StorageLocation[] } with bottle_count per location
- POST /api/v1/locations returns 201 on success, 409 DUPLICATE_LOCATION, 422 VALIDATION_ERROR
- PUT /api/v1/locations/:id returns 200 updated location, 404 LOCATION_NOT_FOUND, 409 DUPLICATE_LOCATION
- DELETE /api/v1/locations/:id calls flagUnknownLocation first, then deleteLocation, returns { deleted_location_id, affected_wines_count }
- GET /api/v1/settings/rating-scale returns { rating_scale: 'STARS_5' | 'POINTS_100' }
- PUT /api/v1/settings/rating-scale returns 200 updated scale, 422 VALIDATION_ERROR for invalid value
  </done>
</task>

</tasks>

<verification>
After both tasks complete, run these checks to confirm all exports and critical behaviors:

```bash
# 1. All route files export the correct HTTP method handlers
grep -n 'export async function' app/api/v1/wines/\[wine_id\]/events/route.ts
grep -n 'export async function' app/api/v1/wines/\[wine_id\]/quantity/route.ts
grep -n 'export async function' app/api/v1/locations/route.ts
grep -n 'export async function' app/api/v1/locations/\[location_id\]/route.ts
grep -n 'export async function' app/api/v1/settings/rating-scale/route.ts

# 2. Business logic: flagUnknownLocation sets both NULL and location_unknown=TRUE
grep -n 'location_unknown\|storage_location_id' lib/business/location.ts

# 3. Quantity floor in patchQuantity
grep -n 'GREATEST' lib/queries/events.ts

# 4. CONSUMED/GIFTED block at qty=0
grep -n 'QuantityEmpty\|quantity.*===.*0' lib/queries/events.ts

# 5. Locations query includes bottle_count SUM
grep -n 'SUM.*quantity\|bottle_count' lib/queries/locations.ts

# 6. Settings singleton defensive upsert
grep -n 'ON CONFLICT\|INSERT INTO user_settings' lib/queries/settings.ts

# 7. DELETE route calls flagUnknownLocation before deleteLocation
grep -n 'flagUnknownLocation\|deleteLocation' app/api/v1/locations/\[location_id\]/route.ts
```
</verification>

<success_criteria>
- 12 files created: 5 API route handlers, 3 query modules, 3 validation modules, 1 business logic module
- POST /api/v1/wines/:wine_id/events: logs all 3 event types; CONSUMED/GIFTED decrement quantity via GREATEST(qty-1,0); OPENED sets is_open=true; blocks CONSUMED/GIFTED at qty=0 with 422 QUANTITY_EMPTY
- GET /api/v1/wines/:wine_id/events: returns reverse-chronological list in { data: [...] } envelope
- PATCH /api/v1/wines/:wine_id/quantity: enforces floor=0 via GREATEST; +1 and -1 are the only valid adjustments
- GET /api/v1/locations: returns all locations with SUM(quantity) bottle_count from LEFT JOIN wines
- POST /api/v1/locations: case-insensitive unique enforcement (PostgreSQL 23505 → 409); 201 on success
- PUT /api/v1/locations/:id: renames with same uniqueness check; 404 if missing
- DELETE /api/v1/locations/:id: flagUnknownLocation runs BEFORE deleteLocation; returns affected_wines_count
- lib/business/location.ts: flagUnknownLocation sets BOTH storage_location_id=NULL AND location_unknown=TRUE in single UPDATE
- GET /api/v1/settings/rating-scale: reads user_settings singleton
- PUT /api/v1/settings/rating-scale: updates STARS_5|POINTS_100; 422 on invalid value
- All query functions use parameterized SQL (no string interpolation)
</success_criteria>

<output>
After completion, create `.planning/express/building-a-web-app-to-keep-track-of-my-w/03-SUMMARY.md` summarizing:
- API endpoints implemented (7 endpoints across 5 route files)
- Business logic: flagUnknownLocation behavior and integration point
- Query module exports consumed by wave 3 frontend
- Settings endpoint (consumed by F4 tasting notes)
- Any deviations from TechArch specs (expected: none)
</output>
