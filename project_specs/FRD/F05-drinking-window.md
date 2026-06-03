---

## F05: Drinking Window Management

**PRD Reference:** F5 — Priority P1 (High)

**Description:** The drinking window is the date range during which a wine is expected to be at or near its peak quality. This feature automatically calculates a readiness status for every wine in the collection by comparing the wine's stored start and end year against the current year — giving users an immediate, color-coded "What should I drink now?" answer without any manual refresh. Readiness status drives the dashboard's Drink Now shelf (F06), filter options (F03), and a prominent badge on every wine card and detail view. Wines with no drinking window entered display a neutral "No Window Set" label.

---

### Terminology

| Term | Definition |
|------|-----------|
| **Drinking Window** | The inclusive date range [start_year, end_year] during which a wine is considered to be at or near its peak. Entered by the user on the wine form; not sourced from any external database in v1. |
| **Readiness Status** | Calculated label assigned to each wine based on the current year and its drinking window. Five possible values: Drink Now, Approaching Peak, Hold, Past Window, No Window Set. |
| **Drink Now** | Readiness status indicating the current year falls within the drinking window (start_year ≤ current_year ≤ end_year). |
| **Approaching Peak** | Readiness status indicating the current year is 1–2 years before the window start (start_year − 2 ≤ current_year < start_year). |
| **Hold** | Readiness status indicating the current year is more than 2 years before the window start (current_year < start_year − 2). |
| **Past Window** | Readiness status indicating the current year exceeds the window end (current_year > end_year). |
| **No Window Set** | Readiness status for wines where neither drink_window_start nor drink_window_end has been entered. |
| **Readiness Badge** | A color-coded UI element displaying the readiness status label, shown on wine list cards and detail views. |

---

### Sub-Features

- **F05.1 — Drinking Window Entry:** Capture start and end year on the wine add/edit form (part of F00)
- **F05.2 — Readiness Status Calculation:** Compute status on each app load/render
- **F05.3 — Readiness Badge Display:** Show color-coded badge on wine list cards and detail view
- **F05.4 — Drink Now Shelf Integration:** Surface Drink Now wines on the dashboard (F06)
- **F05.5 — Filter Integration:** Enable readiness status as a filter dimension (F03)

---

### Process

#### F05.2 — Readiness Status Calculation

The readiness status is a pure calculation from stored data and the current date. It is computed on every render — no separate calculation job, no stored status field (status is derived, not persisted).

**Algorithm (evaluated in order):**

```
current_year = current calendar year (UTC)

IF drink_window_start IS NULL AND drink_window_end IS NULL:
  → status = NO_WINDOW_SET

ELSE IF drink_window_start IS NOT NULL AND current_year >= drink_window_start AND (drink_window_end IS NULL OR current_year <= drink_window_end):
  → status = DRINK_NOW

ELSE IF drink_window_start IS NOT NULL AND current_year >= (drink_window_start - 2) AND current_year < drink_window_start:
  → status = APPROACHING_PEAK

ELSE IF drink_window_start IS NOT NULL AND current_year < (drink_window_start - 2):
  → status = HOLD

ELSE IF drink_window_end IS NOT NULL AND current_year > drink_window_end:
  → status = PAST_WINDOW

ELSE:
  → status = NO_WINDOW_SET
```

**Edge Cases:**

| Scenario | Behavior |
|----------|---------|
| Only `drink_window_start` set (no end) | DRINK_NOW if current ≥ start; APPROACHING_PEAK / HOLD if before start; no PAST_WINDOW can be reached (no end defined) |
| Only `drink_window_end` set (no start) | DRINK_NOW if current ≤ end; PAST_WINDOW if current > end; cannot be HOLD or APPROACHING_PEAK (no start defined) |
| Both set, start = end (single-year window) | DRINK_NOW when current_year = that year; HOLD/APPROACHING_PEAK before; PAST_WINDOW after |
| Cellar Empty wine (quantity = 0) | Readiness status still calculated and displayed; badge is shown in muted style alongside Cellar Empty label |

**Calculation timing:**
- Status is recalculated client-side on each app load (page refresh or navigation to the wine list / detail view).
- No server-side calculation job or cron required in v1.
- If serving pre-rendered pages, status must be recalculated at request time using `CURRENT_DATE`, not cached from a prior render.

#### F05.3 — Readiness Badge Display

**Badge specifications:**

| Status | Badge Label | Background | Text Color | Icon |
|--------|------------|-----------|-----------|------|
| DRINK_NOW | "Drink Now" | Gold 400 `#FBCA5C` | Black `#0A0A0A` | Glass icon |
| APPROACHING_PEAK | "Approaching Peak" | Amber `#F5A623` | Black `#0A0A0A` | Clock icon |
| HOLD | "Hold" | Gray 300 `#D4D1C9` | Ink `#1A1A1A` | Hourglass icon |
| PAST_WINDOW | "Past Window" | Gray 200 `#E8E6E1` | Gray 400 `#A8A59B` | Warning icon |
| NO_WINDOW_SET | "No Window Set" | Transparent | Gray 400 `#A8A59B` | — |

**Badge rendering rules:**
- Font: JetBrains Mono 400–500, UPPERCASE, +1px tracking (label eyebrow style).
- Badge displayed on: wine list card (below producer name), wine detail view header area, dashboard Drink Now shelf cards.
- Badge must include both the color and the text label — color alone must never be the sole differentiator (WCAG 2.1 AA compliance).
- Badge touch target: minimum 44×44px if interactive; badges are non-interactive (display only).
- "Past Window" and "No Window Set" badges are muted to not compete visually with actionable statuses.

---

### Inputs

| Field | Type | Source | Constraints |
|-------|------|--------|------------|
| `drink_window_start` | integer | User (wine add/edit form) | Optional; 1900–2200; ≤ drink_window_end if both set |
| `drink_window_end` | integer | User (wine add/edit form) | Optional; 1900–2200; ≥ drink_window_start if both set |
| `current_year` | integer | System (derived from current date at render time) | Not a user input; UTC calendar year |

**Note:** There is no separate "set drinking window" form — drinking window fields live on the standard wine add/edit form (F00). This feature specifies the calculation and display behavior only.

---

### Outputs

- **`readiness_status`** (calculated, not stored): One of DRINK_NOW, APPROACHING_PEAK, HOLD, PAST_WINDOW, NO_WINDOW_SET
- **Readiness Badge:** Color-coded pill on wine list card and wine detail view header
- **Dashboard Drink Now Shelf:** Subset of wines with DRINK_NOW status, sorted by `drink_window_end` ascending (see F06)
- **Filter Dimension:** `readiness_status` available as a filter option in F03
- **API Response:** `readiness_status` field included in all wine record responses (calculated server-side at response time)

---

### Validation Rules

- `drink_window_start`: If provided, must be integer 1900–2200.
- `drink_window_end`: If provided, must be integer 1900–2200.
- Cross-field: If both `drink_window_start` and `drink_window_end` are provided, `drink_window_start` ≤ `drink_window_end`. Violation returns `422 VALIDATION_ERROR`.
- Neither field is required. Both may be null simultaneously (→ NO_WINDOW_SET).
- `current_year` used in calculation is always derived from server/client clock at render time — never a cached value.

---

### Error States

| Scenario | HTTP Status | Error Code | User Message |
|----------|-------------|------------|-------------|
| Drinking window start > end | 422 | VALIDATION_ERROR | "Drink by start year must be before or equal to end year." |
| Drinking window start out of range | 422 | VALIDATION_ERROR | "Drinking window year must be between 1900 and 2200." |
| Drinking window end out of range | 422 | VALIDATION_ERROR | "Drinking window year must be between 1900 and 2200." |

> No additional error states specific to status calculation — the algorithm is deterministic and always produces one of the five valid statuses.

---

### API Surface (this feature)

Drinking window fields are part of the wine record (`Y1-api.md §F00`). The API includes `readiness_status` as a calculated field in all wine response objects. No dedicated drinking window endpoints.

**Calculated field in wine response:**

```json
{
  "drink_window_start": 2025,
  "drink_window_end": 2032,
  "readiness_status": "DRINK_NOW"
}
```

The `readiness_status` value is computed by the server at response time using `CURRENT_DATE`. Clients must not cache or persist this value.

---

### Schema Surface (this feature)

Drinking window is stored on the `wines` table. Readiness status is NOT stored — it is calculated at query/render time.

**Relevant columns on `wines`:** `drink_window_start` (integer, nullable), `drink_window_end` (integer, nullable).
**No additional tables** introduced by this feature.

See `Y0-schema.md §Wines` for full DDL.

---
