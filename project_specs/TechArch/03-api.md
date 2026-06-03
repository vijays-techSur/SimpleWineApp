---

## 4. API Design

### 4.1 API Conventions

| Convention | Specification |
|------------|--------------|
| Base URL | `/api/v1` |
| Format | `application/json` (request + response) |
| Auth | None (v1 — single-user personal-use app) |
| IDs | UUID v4 strings (`crypto.randomUUID()`) |
| Timestamps | ISO 8601 UTC strings (`"2026-06-03T14:32:00Z"`) |
| Dates | ISO 8601 date strings (`"2026-06-03"`) |
| Calculated fields | `readiness_status` computed at response time using `CURRENT_DATE`; never cached |
| Errors | Consistent JSON envelope (see §4.2) |
| Envelope | All list responses use `{ "data": [...], "meta": { "total": N, "filtered": N } }` |

### 4.2 Error Response Envelope

```typescript
interface ApiError {
  error: {
    code: string;          // UPPER_SNAKE_CASE machine-readable code
    message: string;       // Human-readable message
    field?: string;        // Field that caused the error (optional)
    details?: Array<{      // Multi-field validation failures
      field: string;
      message: string;
    }>;
  };
}
```

| HTTP Status | When Used |
|-------------|-----------|
| 200 OK | Success (GET, PUT, PATCH, DELETE with body) |
| 201 Created | Resource created (POST) |
| 204 No Content | Successful DELETE with no body |
| 400 Bad Request | Malformed JSON / wrong Content-Type |
| 404 Not Found | Resource does not exist |
| 409 Conflict | Uniqueness violation (duplicate location name) |
| 422 Unprocessable Entity | Business rule or field validation failure |
| 500 Internal Server Error | Uncaught server exception |

---

### 4.3 TypeScript Interfaces

#### Shared Enums and Types

```typescript
// Wine type enum
type WineType = 'RED' | 'WHITE' | 'ROSE' | 'SPARKLING' | 'DESSERT' | 'FORTIFIED';

// Bottle size enum
type BottleSize = '375ML' | '750ML' | '1500ML' | '3000ML';

// Readiness status (calculated, never stored)
type ReadinessStatus =
  | 'DRINK_NOW'
  | 'APPROACHING_PEAK'
  | 'HOLD'
  | 'PAST_WINDOW'
  | 'NO_WINDOW_SET';

// Bottle event type
type BottleEventType = 'CONSUMED' | 'GIFTED' | 'OPENED';

// Tasting note rating scale
type RatingScale = 'STARS_5' | 'POINTS_100';

// Would-buy-again toggle
type WouldBuyAgain = 'YES' | 'NO' | 'MAYBE';

// Sort keys for wine list
type WineSortKey =
  | 'created_at_desc'
  | 'created_at_asc'
  | 'wine_name_asc'
  | 'wine_name_desc'
  | 'vintage_year_desc'
  | 'vintage_year_asc'
  | 'quantity_desc'
  | 'quantity_asc'
  | 'rating_desc'
  | 'rating_asc';
```

#### Wine Record Interfaces

```typescript
// Full wine record (GET /wines, GET /wines/:id, POST /wines response)
interface WineRecord {
  wine_id: string;                      // UUID
  wine_name: string;                    // max 200 chars
  producer: string;                     // max 200 chars
  vintage_year: number;                 // 1900–2200
  wine_type: WineType;
  grape_variety: string | null;         // max 200 chars
  country: string | null;               // max 100 chars
  region: string | null;                // max 100 chars
  appellation: string | null;           // max 100 chars
  bottle_size: BottleSize;              // default '750ML'
  quantity: number;                     // >= 0
  is_open: boolean;
  storage_location_id: string | null;   // UUID FK
  storage_location_name: string | null; // denormalized for display
  location_unknown: boolean;
  purchase_date: string | null;         // 'YYYY-MM-DD'
  purchase_source: string | null;       // max 200 chars
  purchase_price: number | null;        // >= 0, 2dp
  estimated_value: number | null;       // >= 0, 2dp
  drink_window_start: number | null;    // 1900–2200
  drink_window_end: number | null;      // 1900–2200
  readiness_status: ReadinessStatus;   // calculated at response time
  notes: string | null;                 // max 5000 chars
  latest_rating: number | null;         // denormalized cache
  latest_rating_scale: RatingScale | null;
  latest_rating_date: string | null;    // 'YYYY-MM-DD'
  created_at: string;                   // ISO 8601 UTC
  updated_at: string;                   // ISO 8601 UTC
}

// Request body for POST /wines (create)
interface CreateWineRequest {
  wine_name: string;                    // Required
  producer: string;                     // Required
  vintage_year: number;                 // Required; 1900–(currentYear+1)
  wine_type: WineType;                  // Required
  quantity: number;                     // Required; >= 1
  storage_location_id: string;          // Required; UUID FK
  grape_variety?: string;
  country?: string;
  region?: string;
  appellation?: string;
  bottle_size?: BottleSize;             // Default '750ML'
  purchase_date?: string;               // 'YYYY-MM-DD'; not future
  purchase_source?: string;
  purchase_price?: number;              // >= 0
  estimated_value?: number;             // >= 0
  drink_window_start?: number;          // 1900–2200
  drink_window_end?: number;            // 1900–2200; >= start
  notes?: string;                       // max 5000 chars
}

// Request body for PUT /wines/:id (full update — all required fields must be present)
type UpdateWineRequest = CreateWineRequest;

// Request body for PATCH /wines/:id (partial update)
type PatchWineRequest = Partial<CreateWineRequest>;

// List response envelope
interface WineListResponse {
  data: WineRecord[];
  meta: {
    total: number;    // Total records matching no filter
    filtered: number; // Records in current result set
  };
}
```

#### Storage Location Interfaces

```typescript
// Storage location (with bottle count for list view)
interface StorageLocation {
  location_id: string;       // UUID
  location_name: string;     // max 100 chars
  bottle_count?: number;     // SUM(quantity) — present in GET /locations
  created_at: string;        // ISO 8601 UTC
  updated_at: string;        // ISO 8601 UTC
}

// Request body for POST /locations and PUT /locations/:id
interface LocationRequest {
  location_name: string;     // Required; 1–100 chars; unique (case-insensitive)
}

// GET /locations response
interface LocationListResponse {
  data: StorageLocation[];
}

// DELETE /locations/:id response
interface DeleteLocationResponse {
  deleted_location_id: string;
  affected_wines_count: number;
}
```

#### Bottle Event Interfaces

```typescript
// Bottle event record
interface BottleEvent {
  event_id: string;              // UUID
  wine_id: string;               // UUID FK
  event_type: BottleEventType;
  event_date: string;            // 'YYYY-MM-DD'; not future
  notes: string | null;          // max 500 chars
  recipient: string | null;      // max 200 chars; GIFTED only
  tasting_note_id: string | null;// UUID FK; set after note created
  created_at: string;            // ISO 8601 UTC
}

// Request body for POST /wines/:id/events
interface CreateBottleEventRequest {
  event_type: BottleEventType;  // Required
  event_date: string;            // Required; 'YYYY-MM-DD'; not future
  notes?: string;                // max 500 chars
  recipient?: string;            // GIFTED only; max 200 chars
}

// GET /wines/:id/events response
interface BottleEventListResponse {
  data: BottleEvent[];
}

// Request body for PATCH /wines/:id/quantity
interface QuantityAdjustRequest {
  adjustment: 1 | -1;           // Required; +1 or -1 only
}

// PATCH /wines/:id/quantity response
interface QuantityAdjustResponse {
  wine_id: string;
  quantity: number;
}
```

#### Tasting Note Interfaces

```typescript
// Tasting note record
interface TastingNote {
  note_id: string;               // UUID
  wine_id: string;               // UUID FK
  bottle_event_id: string | null;// UUID FK; null for standalone notes
  date_tasted: string;           // 'YYYY-MM-DD'; not future
  appearance: string | null;     // max 500 chars
  aroma: string | null;          // max 500 chars
  flavor: string | null;         // max 1000 chars
  finish: string | null;         // max 500 chars
  personal_rating: number | null;// 1–5 (STARS_5) or 1–100 (POINTS_100)
  rating_scale: RatingScale | null;
  would_buy_again: WouldBuyAgain | null;
  occasion: string | null;       // max 200 chars
  guest_feedback: string | null; // max 500 chars
  created_at: string;            // ISO 8601 UTC
  updated_at: string;            // ISO 8601 UTC
}

// Request body for POST /wines/:id/tasting-notes
interface CreateTastingNoteRequest {
  date_tasted: string;           // Required; 'YYYY-MM-DD'; not future
  appearance?: string;
  aroma?: string;
  flavor?: string;
  finish?: string;
  personal_rating?: number;
  rating_scale?: RatingScale;    // Uses user_settings default if omitted
  would_buy_again?: WouldBuyAgain;
  occasion?: string;
  guest_feedback?: string;
  bottle_event_id?: string;      // UUID; must be a CONSUMED event
}

// PUT /wines/:id/tasting-notes/:note_id (full replace)
type UpdateTastingNoteRequest = CreateTastingNoteRequest;

// GET /wines/:id/tasting-notes response
interface TastingNoteListResponse {
  data: TastingNote[];
}
```

#### Dashboard Interfaces

```typescript
// Dashboard summary stats
interface DashboardStats {
  total_bottles: number;
  total_wine_records: number;
  drink_now_count: number;
  approaching_peak_count: number;
}

// Drink Now shelf card (abbreviated wine record)
interface DrinkNowCard {
  wine_id: string;
  wine_name: string;
  producer: string;
  vintage_year: number;
  wine_type: WineType;
  quantity: number;
  storage_location_name: string | null;
  drink_window_end: number | null;
  readiness_status: 'DRINK_NOW';
}

// Breakdown row (type, region, decade)
interface BreakdownByTypeRow {
  wine_type: WineType;
  bottle_count: number;
  percentage: number;  // Rounded to nearest integer
}

interface BreakdownByRegionRow {
  label: string;        // "Region, Country" or "Unknown Origin"
  bottle_count: number;
  percentage: number;
}

interface BreakdownByDecadeRow {
  decade: string;       // e.g., "2020s"
  bottle_count: number;
}

// Recently added wine (abbreviated)
interface RecentlyAddedItem {
  wine_id: string;
  wine_name: string;
  producer: string;
  vintage_year: number;
  wine_type: WineType;
  created_at: string;   // ISO 8601 UTC
}

// Recently consumed event (abbreviated)
interface RecentlyConsumedItem {
  event_id: string;
  wine_id: string;
  wine_name: string;
  producer: string;
  vintage_year: number;
  event_date: string;   // 'YYYY-MM-DD'
}

// Highest rated wine (abbreviated)
interface HighestRatedItem {
  wine_id: string;
  wine_name: string;
  producer: string;
  vintage_year: number;
  latest_rating: number;
  latest_rating_scale: RatingScale;
  latest_rating_date: string;  // 'YYYY-MM-DD'
}

// Full dashboard response (GET /api/v1/dashboard)
interface DashboardResponse {
  stats: DashboardStats;
  drink_now_shelf: DrinkNowCard[];          // Up to 10; sorted by drink_window_end asc
  breakdown_by_type: BreakdownByTypeRow[];  // All 6 wine types
  breakdown_by_region: BreakdownByRegionRow[]; // Top 5 + "Other"
  breakdown_by_decade: BreakdownByDecadeRow[]; // All decades with bottles, desc
  recently_added: RecentlyAddedItem[];      // Up to 5
  recently_consumed: RecentlyConsumedItem[];// Up to 5
  highest_rated: HighestRatedItem[];        // Up to 5
}
```

#### Settings Interfaces

```typescript
// GET /api/v1/settings/rating-scale response
interface RatingScaleResponse {
  rating_scale: RatingScale;
}

// PUT /api/v1/settings/rating-scale request body
interface UpdateRatingScaleRequest {
  rating_scale: RatingScale;  // Required; 'STARS_5' or 'POINTS_100'
}
```

---

### 4.4 Endpoint Reference Table

All 22 endpoints:

| # | Method | Endpoint | Feature | Purpose |
|---|--------|----------|---------|---------|
| 1 | GET | `/api/v1/wines` | F00/F03 | List wines (filter, sort, search query params) |
| 2 | POST | `/api/v1/wines` | F00 | Create a new wine record |
| 3 | GET | `/api/v1/wines/:wine_id` | F00 | Get single wine record |
| 4 | PUT | `/api/v1/wines/:wine_id` | F00 | Full update of wine record |
| 5 | PATCH | `/api/v1/wines/:wine_id` | F00 | Partial update of wine record |
| 6 | DELETE | `/api/v1/wines/:wine_id` | F00 | Delete wine (cascade: events + notes) |
| 7 | POST | `/api/v1/wines/:wine_id/events` | F01 | Log bottle event (Consumed/Gifted/Opened) |
| 8 | GET | `/api/v1/wines/:wine_id/events` | F01 | List all bottle events for a wine |
| 9 | PATCH | `/api/v1/wines/:wine_id/quantity` | F01 | Adjust quantity +1 or −1 (no event log) |
| 10 | GET | `/api/v1/locations` | F02 | List all storage locations with bottle counts |
| 11 | POST | `/api/v1/locations` | F02 | Create a new storage location |
| 12 | PUT | `/api/v1/locations/:location_id` | F02 | Rename a storage location |
| 13 | DELETE | `/api/v1/locations/:location_id` | F02 | Delete location; flag affected wines |
| 14 | GET | `/api/v1/wines/:wine_id/tasting-notes` | F04 | List all tasting notes for a wine |
| 15 | POST | `/api/v1/wines/:wine_id/tasting-notes` | F04 | Add a new tasting note |
| 16 | GET | `/api/v1/wines/:wine_id/tasting-notes/:note_id` | F04 | Get single tasting note |
| 17 | PUT | `/api/v1/wines/:wine_id/tasting-notes/:note_id` | F04 | Update a tasting note (full replace) |
| 18 | DELETE | `/api/v1/wines/:wine_id/tasting-notes/:note_id` | F04 | Delete a tasting note |
| 19 | GET | `/api/v1/settings/rating-scale` | F04 | Get rating scale preference |
| 20 | PUT | `/api/v1/settings/rating-scale` | F04 | Set rating scale preference |
| 21 | GET | `/api/v1/dashboard` | F06 | Full dashboard aggregation response |
| 22 | GET | `/api/v1/dashboard/stats` | F06 | Summary stats only (lightweight) |

---

### 4.5 GET /api/v1/wines Query Parameters (F03)

| Parameter | Type | Description |
|-----------|------|-------------|
| `q` | string | Full-text search: wine_name, producer, region, grape_variety |
| `wine_type` | string | Comma-separated: `RED,WHITE,ROSE` |
| `producer` | string | Exact match, case-insensitive |
| `country` | string | Exact match, case-insensitive |
| `region` | string | Exact match, case-insensitive |
| `vintage_from` | integer | Vintage >= value (inclusive) |
| `vintage_to` | integer | Vintage <= value (inclusive) |
| `grape_variety` | string | Substring match, case-insensitive |
| `location_id` | string | UUID or `"unknown"` for location_unknown=true wines |
| `readiness` | string | Comma-separated: `DRINK_NOW,APPROACHING_PEAK,HOLD` |
| `rating_min` | number | Min latest_rating (inclusive) |
| `rating_max` | number | Max latest_rating (inclusive) |
| `sort` | string | Sort key (see WineSortKey enum); default `created_at_desc` |

> Note: In v1, filtering is performed client-side in the browser for collections ≤500 records. The server-side query parameter support is provided as a fallback and for API consumers.

---
