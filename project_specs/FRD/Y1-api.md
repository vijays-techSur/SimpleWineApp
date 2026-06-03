---

## Y1: REST API Endpoints

**Base URL:** `/api/v1`
**Format:** All requests and responses use `application/json`.
**Authentication:** Single-user app in v1 — no auth layer required in MVP. If a session cookie or local token is introduced, all endpoints should validate it; this is a Phase 2 concern.
**Errors:** All error responses follow the structure in `Y2-errors.md §Error Response Format`.
**Calculated fields:** `readiness_status` is computed server-side at response time using `CURRENT_DATE`. Never cache or persist this field.
**Timestamps:** All `created_at` and `updated_at` values are ISO 8601 UTC strings (e.g., `"2026-06-03T14:32:00Z"`).

---

### §F00 — Wine Inventory

#### `GET /api/v1/wines`

List all wine records with optional filtering, searching, and sorting (see F03).

**Query Parameters:**

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `q` | string | — | Full-text search across name, producer, region, grape |
| `wine_type` | string | — | Comma-separated enum values (e.g., `RED,WHITE`) |
| `producer` | string | — | Exact match (case-insensitive) |
| `country` | string | — | Exact match (case-insensitive) |
| `region` | string | — | Exact match (case-insensitive) |
| `vintage_from` | integer | — | Vintage year range start (inclusive) |
| `vintage_to` | integer | — | Vintage year range end (inclusive) |
| `grape_variety` | string | — | Substring match |
| `location_id` | string | — | UUID or `"unknown"` for Location Unknown |
| `readiness` | string | — | Comma-separated: DRINK_NOW, APPROACHING_PEAK, HOLD, PAST_WINDOW, NO_WINDOW_SET |
| `rating_min` | number | — | Min latest rating (inclusive) |
| `rating_max` | number | — | Max latest rating (inclusive) |
| `sort` | string | `created_at_desc` | Sort key (see F03 sort options) |

**Response: `200 OK`**

```json
{
  "data": [
    {
      "wine_id": "uuid",
      "wine_name": "Château Margaux",
      "producer": "Château Margaux",
      "vintage_year": 2015,
      "wine_type": "RED",
      "grape_variety": "Cabernet Sauvignon, Merlot",
      "country": "France",
      "region": "Bordeaux",
      "appellation": "Margaux AOC",
      "bottle_size": "750ML",
      "quantity": 3,
      "is_open": false,
      "storage_location_id": "uuid",
      "storage_location_name": "Wine Fridge – Bottom Shelf",
      "location_unknown": false,
      "purchase_date": "2022-04-15",
      "purchase_source": "Wine.com",
      "purchase_price": 650.00,
      "estimated_value": 720.00,
      "drink_window_start": 2025,
      "drink_window_end": 2045,
      "readiness_status": "DRINK_NOW",
      "notes": "Exceptional vintage.",
      "latest_rating": 4.5,
      "latest_rating_scale": "STARS_5",
      "latest_rating_date": "2026-01-10",
      "created_at": "2022-04-16T10:00:00Z",
      "updated_at": "2026-01-10T20:00:00Z"
    }
  ],
  "meta": {
    "total": 42,
    "filtered": 12
  }
}
```

---

#### `POST /api/v1/wines`

Create a new wine record.

**Request Body:**

```json
{
  "wine_name": "Château Margaux",
  "producer": "Château Margaux",
  "vintage_year": 2015,
  "wine_type": "RED",
  "grape_variety": "Cabernet Sauvignon, Merlot",
  "country": "France",
  "region": "Bordeaux",
  "appellation": "Margaux AOC",
  "bottle_size": "750ML",
  "quantity": 3,
  "storage_location_id": "uuid",
  "purchase_date": "2022-04-15",
  "purchase_source": "Wine.com",
  "purchase_price": 650.00,
  "estimated_value": 720.00,
  "drink_window_start": 2025,
  "drink_window_end": 2045,
  "notes": "Exceptional vintage."
}
```

**Response: `201 Created`** — full wine record object (same shape as GET /wines item)

---

#### `GET /api/v1/wines/:wine_id`

Get single wine record by ID.

**Response: `200 OK`** — single wine record object (full shape as above)

**Error: `404 Not Found`** — `WINE_NOT_FOUND`

---

#### `PUT /api/v1/wines/:wine_id`

Full update of a wine record. All required fields must be provided.

**Request Body:** Same as POST.

**Response: `200 OK`** — updated wine record object.

---

#### `PATCH /api/v1/wines/:wine_id`

Partial update. Only provided fields are updated.

**Request Body:** Any subset of POST fields.

**Response: `200 OK`** — updated wine record object.

---

#### `DELETE /api/v1/wines/:wine_id`

Delete a wine record and all associated tasting notes and bottle events (cascade).

**Response: `204 No Content`**

**Error: `404 Not Found`** — `WINE_NOT_FOUND`

---

### §F01 — Bottle Events

#### `POST /api/v1/wines/:wine_id/events`

Log a bottle event.

**Request Body:**

```json
{
  "event_type": "CONSUMED",
  "event_date": "2026-06-03",
  "notes": "Opened for anniversary dinner.",
  "recipient": null
}
```

**Response: `201 Created`**

```json
{
  "event_id": "uuid",
  "wine_id": "uuid",
  "event_type": "CONSUMED",
  "event_date": "2026-06-03",
  "notes": "Opened for anniversary dinner.",
  "recipient": null,
  "tasting_note_id": null,
  "created_at": "2026-06-03T19:00:00Z"
}
```

**Error: `422 Unprocessable Entity`** — `QUANTITY_EMPTY` (CONSUMED or GIFTED when quantity = 0)

---

#### `GET /api/v1/wines/:wine_id/events`

Get all bottle events for a wine, sorted by `event_date` descending.

**Response: `200 OK`**

```json
{
  "data": [
    {
      "event_id": "uuid",
      "wine_id": "uuid",
      "event_type": "CONSUMED",
      "event_date": "2026-06-03",
      "notes": "Anniversary dinner.",
      "recipient": null,
      "tasting_note_id": "uuid",
      "created_at": "2026-06-03T19:00:00Z"
    }
  ]
}
```

---

#### `PATCH /api/v1/wines/:wine_id/quantity`

Directly adjust quantity by +1 or −1 without logging an event (for the +/− UI controls).

**Request Body:**

```json
{
  "adjustment": 1
}
```

`adjustment` must be `1` or `-1`. System rejects `−1` when current quantity = 0.

**Response: `200 OK`**

```json
{
  "wine_id": "uuid",
  "quantity": 4
}
```

---

### §F02 — Storage Locations

#### `GET /api/v1/locations`

List all storage locations with bottle counts.

**Response: `200 OK`**

```json
{
  "data": [
    {
      "location_id": "uuid",
      "location_name": "Wine Fridge – Top Shelf",
      "bottle_count": 12,
      "created_at": "2026-01-01T00:00:00Z",
      "updated_at": "2026-01-01T00:00:00Z"
    }
  ]
}
```

---

#### `POST /api/v1/locations`

Create a new storage location.

**Request Body:** `{ "location_name": "Basement Cellar" }`

**Response: `201 Created`** — full location object (without bottle_count on create).

**Error: `422`** — `DUPLICATE_LOCATION` if name already exists.

---

#### `PUT /api/v1/locations/:location_id`

Rename a storage location.

**Request Body:** `{ "location_name": "Basement Cellar – Rack A" }`

**Response: `200 OK`** — updated location object.

---

#### `DELETE /api/v1/locations/:location_id`

Delete a location. All wines assigned to it have `storage_location_id` set to NULL and `location_unknown` set to TRUE.

**Response: `200 OK`**

```json
{
  "deleted_location_id": "uuid",
  "affected_wines_count": 5
}
```

---

### §F04 — Tasting Notes

#### `GET /api/v1/wines/:wine_id/tasting-notes`

List all tasting notes for a wine, sorted by `date_tasted` descending.

**Response: `200 OK`**

```json
{
  "data": [
    {
      "note_id": "uuid",
      "wine_id": "uuid",
      "bottle_event_id": "uuid",
      "date_tasted": "2026-06-03",
      "appearance": "Deep ruby with violet hints.",
      "aroma": "Blackcurrant, cedar, tobacco.",
      "flavor": "Full-bodied with firm tannins, layers of dark fruit.",
      "finish": "Long, velvety finish.",
      "personal_rating": 4.5,
      "rating_scale": "STARS_5",
      "would_buy_again": "YES",
      "occasion": "Anniversary dinner",
      "guest_feedback": "Guests loved it.",
      "created_at": "2026-06-03T21:00:00Z",
      "updated_at": "2026-06-03T21:00:00Z"
    }
  ]
}
```

---

#### `POST /api/v1/wines/:wine_id/tasting-notes`

Add a tasting note to a wine.

**Request Body:** All tasting note fields (only `date_tasted` required; see F04 Inputs for full list).

**Response: `201 Created`** — full tasting note object.

---

#### `PUT /api/v1/wines/:wine_id/tasting-notes/:note_id`

Update a tasting note.

**Request Body:** All fields (full replace).

**Response: `200 OK`** — updated tasting note object.

---

#### `DELETE /api/v1/wines/:wine_id/tasting-notes/:note_id`

Delete a tasting note.

**Response: `204 No Content`**

---

#### `GET /api/v1/settings/rating-scale`

Get rating scale preference.

**Response: `200 OK`** `{ "rating_scale": "STARS_5" }`

---

#### `PUT /api/v1/settings/rating-scale`

Set rating scale preference.

**Request Body:** `{ "rating_scale": "POINTS_100" }` (must be `"STARS_5"` or `"POINTS_100"`)

**Response: `200 OK`** `{ "rating_scale": "POINTS_100" }`

---

### §F06 — Dashboard

#### `GET /api/v1/dashboard`

Aggregate dashboard data in a single response.

**Response: `200 OK`**

```json
{
  "stats": {
    "total_bottles": 87,
    "total_wine_records": 34,
    "drink_now_count": 8,
    "approaching_peak_count": 5
  },
  "drink_now_shelf": [
    {
      "wine_id": "uuid",
      "wine_name": "Opus One",
      "producer": "Opus One Winery",
      "vintage_year": 2018,
      "wine_type": "RED",
      "quantity": 2,
      "storage_location_name": "Wine Fridge",
      "drink_window_end": 2028,
      "readiness_status": "DRINK_NOW"
    }
  ],
  "breakdown_by_type": [
    { "wine_type": "RED", "bottle_count": 52, "percentage": 60 },
    { "wine_type": "WHITE", "bottle_count": 20, "percentage": 23 },
    { "wine_type": "ROSE", "bottle_count": 5, "percentage": 6 },
    { "wine_type": "SPARKLING", "bottle_count": 7, "percentage": 8 },
    { "wine_type": "DESSERT", "bottle_count": 2, "percentage": 2 },
    { "wine_type": "FORTIFIED", "bottle_count": 1, "percentage": 1 }
  ],
  "breakdown_by_region": [
    { "label": "Bordeaux, France", "bottle_count": 24, "percentage": 28 },
    { "label": "Napa Valley, USA", "bottle_count": 18, "percentage": 21 }
  ],
  "breakdown_by_decade": [
    { "decade": "2020s", "bottle_count": 30 },
    { "decade": "2010s", "bottle_count": 45 },
    { "decade": "2000s", "bottle_count": 12 }
  ],
  "recently_added": [
    {
      "wine_id": "uuid",
      "wine_name": "Barolo Riserva",
      "producer": "Giacomo Conterno",
      "vintage_year": 2016,
      "wine_type": "RED",
      "created_at": "2026-06-01T12:00:00Z"
    }
  ],
  "recently_consumed": [
    {
      "event_id": "uuid",
      "wine_id": "uuid",
      "wine_name": "Château Pétrus",
      "producer": "Pétrus",
      "vintage_year": 2010,
      "event_date": "2026-05-28"
    }
  ],
  "highest_rated": [
    {
      "wine_id": "uuid",
      "wine_name": "Screaming Eagle",
      "producer": "Screaming Eagle Winery",
      "vintage_year": 2019,
      "latest_rating": 5.0,
      "latest_rating_scale": "STARS_5",
      "latest_rating_date": "2026-03-15"
    }
  ]
}
```

---

#### `GET /api/v1/dashboard/stats`

Summary stats only (lightweight endpoint for stat bar updates).

**Response: `200 OK`**

```json
{
  "total_bottles": 87,
  "total_wine_records": 34,
  "drink_now_count": 8,
  "approaching_peak_count": 5
}
```

---
