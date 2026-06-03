---

## F03: Search & Filter

**PRD Reference:** F3 — Priority P0 (Critical)

**Description:** As a wine collection grows, browsing a flat list becomes impractical. This feature provides two complementary discovery mechanisms: a full-text search bar that matches across multiple wine attributes as the user types (client-side, no server round-trip), and a multi-attribute filter panel that lets users narrow the collection by wine type, producer, region, vintage, grape, storage location, drinking readiness status, and personal rating range. Sort options allow users to re-order results by any key dimension. Active filters are displayed as dismissible chips and persist for the session.

---

### Terminology

| Term | Definition |
|------|-----------|
| **Search Query** | A free-text string entered in the search bar, matched against `wine_name`, `producer`, `region`, and `grape_variety` fields. |
| **Filter** | A specific attribute criterion applied to narrow the wine list (e.g., wine type = RED, vintage = 2018). |
| **Filter Panel** | A collapsible sidebar (desktop) or bottom drawer (mobile) containing all filter controls. |
| **Filter Chip** | A small dismissible UI element displayed above the wine list representing one active filter. |
| **Sort Order** | The ordering applied to the wine list after search and filter have been applied. |
| **Readiness Status** | Calculated status (Drink Now, Hold, Approaching Peak, Past Window, No Window Set) derived by F05; used as a filter dimension here. |
| **Session Persistence** | Filter and sort state retained in memory for the duration of the browser session; reset on app close or hard refresh. |

---

### Sub-Features

- **F03.1 — Full-Text Search Bar:** Real-time text matching across wine name, producer, region, grape
- **F03.2 — Wine Type Filter:** Single or multi-select by wine type
- **F03.3 — Producer Filter:** Filter to wines from a specific producer
- **F03.4 — Country & Region Filter:** Filter by country and/or region
- **F03.5 — Vintage Filter:** Filter by exact year or year range
- **F03.6 — Grape Variety Filter:** Filter by grape variety (partial match)
- **F03.7 — Storage Location Filter:** Filter to wines in a specific storage location
- **F03.8 — Readiness Status Filter:** Filter by drinking readiness status (from F05)
- **F03.9 — Rating Range Filter:** Filter by personal rating minimum/maximum
- **F03.10 — Active Filter Chips:** Display and dismiss individual active filters
- **F03.11 — Clear All Filters:** Reset all active filters and search query at once
- **F03.12 — Sort Controls:** Sort the wine list by multiple dimensions

---

### Process

#### F03.1 — Full-Text Search

1. Search bar is permanently visible at the top of the Wine List view.
2. User types into the search bar.
3. System applies the search client-side with no server request, filtering in real time (debounce: 100ms after last keystroke).
4. Matching fields: `wine_name`, `producer`, `region`, `grape_variety`. Match is case-insensitive, substring match (e.g., "cab" matches "Cabernet Sauvignon").
5. Wine list updates immediately to show only matching records.
6. If no wines match, system displays: "No wines match your search. Try a different term or clear filters."
7. Search query is treated as an additive filter alongside any active panel filters (AND logic: results must satisfy both search AND all active filters).
8. A "×" clear button appears in the search bar when text is present; tapping it clears the query.

#### F03.2–F03.9 — Filter Panel Filters

1. User taps the "Filter" button (funnel icon) to open the filter panel.
   - Mobile: panel slides up as a bottom sheet drawer.
   - Desktop: panel appears as a sidebar alongside the wine list.
2. Filter panel sections:

   **Wine Type (F03.2):** Multi-select checkboxes: Red, White, Rosé, Sparkling, Dessert, Fortified. Selecting multiple types returns wines matching ANY selected type (OR logic within this filter).

   **Producer (F03.3):** Text input with autocomplete dropdown listing all unique producers in the collection. Selecting a producer filters to that producer exactly (exact match, case-insensitive).

   **Country / Region (F03.4):** Two cascading selects: Country (dropdown of all unique countries in collection), Region (dropdown populated based on selected country; if no country selected, shows all unique regions). Either or both may be selected.

   **Vintage (F03.5):** Two numeric inputs: "From year" and "To year." If only "From" is provided, shows wines with vintage ≥ From. If only "To" is provided, shows wines with vintage ≤ To. If both provided, shows wines with vintage in range [From, To] inclusive.

   **Grape Variety (F03.6):** Text input; substring match against `grape_variety` field (case-insensitive). E.g., entering "Cab" matches "Cabernet Sauvignon," "Cabernet Franc."

   **Storage Location (F03.7):** Dropdown of all defined locations plus "Location Unknown" option. Single-select.

   **Drinking Readiness (F03.8):** Multi-select checkboxes: Drink Now, Approaching Peak, Hold, Past Window, No Window Set. OR logic within this filter.

   **Rating Range (F03.9):** Two inputs: "Min rating" and "Max rating." On 5-star scale: 1–5 (integers). On 100-point scale: 1–100. Only active if at least one tasting note with a rating exists in the collection. Filters wines by their most recent tasting note rating.

3. Each filter is applied as the user interacts (live results update if data is client-side). No "Apply" button required.
4. All active filters are combined with AND logic (wine must satisfy ALL active filters and search query simultaneously).

#### F03.10 — Active Filter Chips

1. Above the wine list, system displays one chip per active filter.
2. Chip format: "[Filter Type]: [Value]" (e.g., "Type: Red, White", "Vintage: 2015–2020", "Location: Wine Fridge").
3. Each chip has an "×" dismiss button. Tapping dismisses that individual filter.
4. The search query is NOT shown as a chip (it has its own clear button in the search bar).

#### F03.11 — Clear All Filters

1. A "Clear all" link/button appears next to the filter chips when any filter is active.
2. Tapping clears all active panel filters. Does not clear the search bar query.
3. The filter panel, if open, resets all controls to their default (unselected) state.

#### F03.12 — Sort Controls

1. A sort control is displayed at the top-right of the wine list.
2. Sort options:
   - **Date Added: Newest first** (default)
   - **Date Added: Oldest first**
   - **Wine Name: A → Z**
   - **Wine Name: Z → A**
   - **Vintage: Newest first** (highest year first)
   - **Vintage: Oldest first** (lowest year first)
   - **Quantity: High → Low**
   - **Quantity: Low → High**
   - **Rating: Highest first** (sorts by most recent tasting note rating; unrated wines sorted last)
   - **Rating: Lowest first** (unrated wines sorted last)
3. Sort applies to the filtered result set (sort happens after filter/search).
4. Selected sort option persists for the session.

---

### Inputs

| Input | Type | Constraints |
|-------|------|------------|
| `search_query` | string | Optional; 0–200 characters; applied client-side |
| `filter.wine_type` | enum[] | Optional; subset of [RED, WHITE, ROSE, SPARKLING, DESSERT, FORTIFIED] |
| `filter.producer` | string | Optional; exact match (case-insensitive) |
| `filter.country` | string | Optional; exact match (case-insensitive) |
| `filter.region` | string | Optional; exact match (case-insensitive) |
| `filter.vintage_from` | integer | Optional; 1900–2200; must be ≤ vintage_to if both provided |
| `filter.vintage_to` | integer | Optional; 1900–2200; must be ≥ vintage_from if both provided |
| `filter.grape_variety` | string | Optional; substring match |
| `filter.storage_location_id` | UUID or "UNKNOWN" | Optional |
| `filter.readiness_status` | enum[] | Optional; subset of [DRINK_NOW, APPROACHING_PEAK, HOLD, PAST_WINDOW, NO_WINDOW_SET] |
| `filter.rating_min` | number | Optional; 1–5 (star) or 1–100 (points) |
| `filter.rating_max` | number | Optional; ≥ rating_min |
| `sort` | enum | Optional; one of the defined sort keys; defaults to DATE_ADDED_DESC |

---

### Outputs

- **Filtered Wine List:** Subset of wine records matching all active criteria, in the selected sort order
- **Active Filter Chips:** One chip per active filter dimension (not per value within a multi-select)
- **Result Count:** "Showing [N] of [Total] wines" label above the list
- **Empty State:** "No wines match your search. Try a different term or clear filters." when result set is empty
- **URL Query Params (optional, progressive enhancement):** Filter state may be reflected in URL query params to allow sharing/bookmarking filtered views (not required in v1, but supported if feasible)

---

### Validation Rules

- `search_query`: Max 200 characters. Client-side only; no server-side validation required.
- `filter.vintage_from` and `filter.vintage_to`: If both provided, `vintage_from` must be ≤ `vintage_to`. If violated, show inline error: "Start year must be before or equal to end year."
- `filter.rating_min` and `filter.rating_max`: If both provided, `rating_min` must be ≤ `rating_max`. If violated, show inline error: "Min rating must be less than or equal to max rating."
- Rating filter values must be within the user's selected scale range (1–5 or 1–100). Out-of-range values clamped to min/max of scale.
- All filtering is performed client-side for collections ≤ 500 records (per NFR performance target). Server-side filtering may be used for larger collections in a future phase.

---

### Error States

| Scenario | Display | User Message |
|----------|---------|-------------|
| No wines match combined filters | Empty state in wine list | "No wines match your search. Try a different term or clear filters." |
| Vintage range invalid (from > to) | Inline on filter panel | "Start year must be before or equal to end year." |
| Rating range invalid (min > max) | Inline on filter panel | "Min rating must be less than or equal to max rating." |
| Collection is empty (no wines at all) | Empty state | "Your cellar is empty. Add your first wine to get started." |

---

### API Surface (this feature)

Search and filter are primarily client-side in v1. The wine list API supports query parameters for server-side filtering as a fallback for large collections.

See `Y1-api.md §F03 — Search & Filter` for query parameter spec on `GET /api/v1/wines`.

| Parameter | Type | Purpose |
|-----------|------|---------|
| `q` | string | Full-text search query |
| `wine_type` | string | Comma-separated enum values |
| `producer` | string | Exact match filter |
| `country` | string | Exact match filter |
| `region` | string | Exact match filter |
| `vintage_from` | integer | Vintage range start |
| `vintage_to` | integer | Vintage range end |
| `grape_variety` | string | Substring match filter |
| `location_id` | UUID or "unknown" | Location filter |
| `readiness` | string | Comma-separated readiness status values |
| `rating_min` | number | Minimum rating filter |
| `rating_max` | number | Maximum rating filter |
| `sort` | string | Sort key (see sort options above) |

---

### Schema Surface (this feature)

Search and filter operate against the `wines` table (with JOINs to `storage_locations` and `tasting_notes` for rating filter). No additional schema tables introduced by this feature. Readiness status is calculated at query time from `drink_window_start`, `drink_window_end`, and `CURRENT_DATE` — see `Y0-schema.md §Wines` and `F05 §Process`.

---
