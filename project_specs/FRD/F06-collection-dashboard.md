---

## F06: Collection Dashboard & Insights

**PRD Reference:** F6 — Priority P1 (High)

**Description:** The dashboard is the home screen of the application. It gives the user an immediate picture of their collection — total bottles, wines ready to drink, and simple breakdowns by type, region, and vintage decade — without requiring any navigation. The "Drink Now" shelf surfaces the most actionable bottles prominently, answering the core question "What should I open tonight?" The dashboard is data-driven: all cards and stats pull from the live wine collection and update on every app load. All dashboard cards link to the full filtered wine list for the corresponding segment, enabling the user to drill down from summary to detail in one tap.

---

### Terminology

| Term | Definition |
|------|-----------|
| **Summary Stats Bar** | The persistent row of aggregate metrics at the top of the dashboard (total bottles, total wine records, Drink Now count, Approaching Peak count). |
| **Drink Now Shelf** | A horizontally scrollable row (or vertical compact list on mobile) of wine cards with DRINK_NOW readiness status, sorted by urgency (soonest end year first). |
| **Collection Breakdown** | Visual segmentation of the collection by wine type, by country/region, and by vintage decade, shown as simple count + percentage lists or bar indicators. |
| **Recently Added** | The 5 wine records most recently created, sorted by `created_at` descending. |
| **Recently Consumed** | The 5 most recent CONSUMED bottle events, sorted by `event_date` descending. |
| **Highest Rated** | The top 5 wine records by `latest_rating` (descending), only wines with at least one tasting note with a rating. |
| **Dashboard Card** | An individual panel on the dashboard containing one data segment (e.g., the Drink Now shelf, Recently Added list). Each card links to a filtered wine list view. |

---

### Sub-Features

- **F06.1 — Summary Stats Bar:** Four key metrics always visible at the top of the dashboard
- **F06.2 — Drink Now Shelf:** Scrollable row of wines ready to drink now
- **F06.3 — Collection Breakdown by Type:** Wine type distribution (count + %)
- **F06.4 — Collection Breakdown by Region:** Top 5 countries/regions by bottle count
- **F06.5 — Collection Breakdown by Decade:** Bottle count grouped by vintage decade
- **F06.6 — Recently Added:** Last 5 wines added to the collection
- **F06.7 — Recently Consumed:** Last 5 consumed bottle events
- **F06.8 — Highest Rated:** Top 5 wines by personal rating
- **F06.9 — Dashboard Navigation:** All cards link to filtered wine list for that segment

---

### Process

#### Dashboard Load

1. Dashboard is the default landing view on app open.
2. On load, system fetches all wine data needed for dashboard (single optimized query or set of queries — see `Y1-api.md §F06`).
3. System calculates all derived values (readiness statuses, breakdowns, counts) using live data and `CURRENT_DATE`.
4. System renders all dashboard sections in the layout order below.
5. If the collection is empty (no wine records), system displays an onboarding empty state: "Your cellar is empty. Tap '+' to add your first wine." with a prominent "Add Wine" CTA button.

#### F06.1 — Summary Stats Bar

Displayed as a horizontal strip of four stat tiles (stack 2×2 on narrow mobile if needed):

| Stat | Calculation |
|------|------------|
| **Total Bottles** | `SUM(quantity)` across all wine records where quantity > 0 |
| **Wine Records** | `COUNT(*)` of all wine records (including Cellar Empty records) |
| **Drink Now** | `COUNT(*)` of wine records with readiness_status = DRINK_NOW AND quantity > 0 |
| **Approaching Peak** | `COUNT(*)` of wine records with readiness_status = APPROACHING_PEAK AND quantity > 0 |

- Each stat tile is tappable: taps navigate to the Wine List filtered for that segment.
- Stats update on each app load; no manual refresh button required.

#### F06.2 — Drink Now Shelf

1. System queries all wine records where readiness_status = DRINK_NOW AND quantity > 0.
2. Results sorted by `drink_window_end` ascending (soonest expiring first). If `drink_window_end` is NULL (only start was set), sorted to the end of the shelf.
3. Up to 10 wines displayed on the shelf. "See all [N]" link navigates to the filtered wine list with Drink Now filter active.
4. Each shelf card displays: wine name, producer, vintage year, Drink Now badge, quantity, storage location.
5. If zero wines have DRINK_NOW status: shelf card shows "No wines are ready to drink right now." (card still visible, showing empty state, not hidden).
6. Shelf is horizontally scrollable on mobile; may display as a 2-column grid on desktop.

#### F06.3 — Collection Breakdown by Wine Type

1. System counts the sum of `quantity` for each wine type (RED, WHITE, ROSE, SPARKLING, DESSERT, FORTIFIED) across all wine records with quantity > 0.
2. Displayed as a vertical list of rows, each showing: type label, bottle count, percentage of total (rounded to nearest integer).
3. Types with zero bottles are shown with count = 0 (not hidden).
4. Tapping a type row navigates to Wine List filtered by that wine type.

#### F06.4 — Collection Breakdown by Country / Region

1. System groups wines by `country` (or `region` if country not set), sums `quantity` per group.
2. Displays the top 5 country/region groups by bottle count, descending.
3. An "Other" row shows the aggregate count of all remaining countries/regions not in the top 5 (if any).
4. Wines with no country or region set are grouped under "Unknown Origin."
5. Displayed as a vertical list: country/region name, bottle count, percentage of total.
6. Tapping a row navigates to Wine List filtered by that country (if country is set) or region.

#### F06.5 — Collection Breakdown by Vintage Decade

1. System groups wine records by vintage decade (e.g., 2010s = vintage 2010–2019), sums `quantity` per decade.
2. Displays all decades with at least one bottle, sorted by decade descending (most recent first).
3. Displayed as a bar or list: decade label (e.g., "2020s"), bottle count, simple proportional bar.
4. Tapping a decade row navigates to Wine List filtered by vintage range for that decade.

#### F06.6 — Recently Added

1. System queries the 5 wine records with the most recent `created_at`, regardless of quantity.
2. Displayed as a compact list: wine name, producer, vintage, wine type badge, date added (relative: "2 days ago").
3. Tapping a row navigates to the Wine Detail view for that wine.
4. "View all" link navigates to Wine List sorted by Date Added: Newest first.

#### F06.7 — Recently Consumed

1. System queries the 5 most recent `bottle_events` where `event_type = CONSUMED`, sorted by `event_date` descending.
2. Displayed as a compact list: wine name, producer, vintage, date consumed (relative).
3. Tapping a row navigates to the Wine Detail view for that wine.
4. If no consumed events exist: "No consumed bottles recorded yet."
5. "View all" navigates to Wine List filtered to show wines with any CONSUMED events.

#### F06.8 — Highest Rated

1. System queries wine records with at least one tasting note containing a `personal_rating`.
2. Sorted by `latest_rating` descending (ties broken by `latest_rating_date` descending — most recent rating wins the tie).
3. Top 5 displayed: wine name, producer, vintage, rating display (stars or numeric per user's scale preference).
4. If fewer than 5 rated wines exist, all rated wines are shown.
5. If no wines have ratings: card shows "Rate your wines to see your favorites here."
6. Tapping a row navigates to Wine Detail view for that wine.

---

### Inputs

All dashboard data is derived from existing wine records, bottle events, and tasting notes. No direct user input on the dashboard itself — it is a read-only aggregation view. The only user interaction is navigation (tapping cards to drill down).

| Source | Fields Used |
|--------|------------|
| `wines` table | `quantity`, `wine_type`, `country`, `region`, `vintage_year`, `drink_window_start`, `drink_window_end`, `created_at`, `storage_location_id`, `latest_rating` |
| `bottle_events` table | `event_type`, `event_date`, `wine_id` (for Recently Consumed) |
| `tasting_notes` table | `personal_rating`, `date_tasted`, `wine_id` (for Highest Rated) |
| System clock | `CURRENT_DATE` (for readiness status calculation) |

---

### Outputs

| Section | Output |
|---------|--------|
| Summary Stats Bar | 4 numeric tiles: total bottles, wine records, Drink Now count, Approaching Peak count |
| Drink Now Shelf | Up to 10 wine cards with readiness badges, sorted by end-year urgency |
| Breakdown by Type | 6 rows (one per wine type) with count and percentage |
| Breakdown by Region | Top 5 regions + "Other" row with count and percentage |
| Breakdown by Decade | All decades with bottles, sorted descending, with proportional bar |
| Recently Added | 5 wine records with name, producer, vintage, date added |
| Recently Consumed | 5 most recent CONSUMED events with wine name, date consumed |
| Highest Rated | Top 5 wines by rating with rating display |

---

### Validation Rules

- All calculations must use quantity > 0 for "active cellar" counts (Cellar Empty wines excluded from Total Bottles count, Drink Now count, Approaching Peak count, and Drink Now Shelf).
- Readiness status calculation: same algorithm as F05 §Process — no duplication allowed; F05 is the single source of truth for the calculation logic.
- If `latest_rating` is NULL (no rated notes), wine is excluded from Highest Rated.
- If collection is completely empty (no wine records at all), dashboard displays the onboarding empty state instead of all cards.
- Percentages in breakdown sections: calculated as `(group_count / total_bottles) * 100`, rounded to nearest integer. If rounding causes percentages to not sum to 100%, display as-is (cosmetic rounding tolerance accepted).

---

### Error States

| Scenario | Display |
|----------|---------|
| Empty collection | Onboarding empty state with "Add Wine" CTA |
| No Drink Now wines | Drink Now shelf shows empty state message |
| No rated wines | Highest Rated card shows "Rate your wines..." prompt |
| No consumed events | Recently Consumed shows "No consumed bottles recorded yet." |
| Data load failure | Each card shows "Unable to load. Pull to refresh." (graceful degradation) |

---

### API Surface (this feature)

See `Y1-api.md §F06 — Dashboard` for full response schemas.

| Method | Endpoint | Purpose |
|--------|----------|---------|
| GET | `/api/v1/dashboard` | Aggregate dashboard data (all sections in one response) |
| GET | `/api/v1/dashboard/stats` | Summary stats bar only (for lightweight polling if needed) |

The `/api/v1/dashboard` endpoint returns a single JSON object with all dashboard sections, minimizing round-trips. Alternatively, the client may assemble dashboard data from the existing `/api/v1/wines` and `/api/v1/wines/:id/events` endpoints with appropriate query parameters.

---

### Schema Surface (this feature)

No new tables introduced by this feature. All data is aggregated from:
- `wines` — see `Y0-schema.md §Wines`
- `bottle_events` — see `Y0-schema.md §BottleEvents`
- `tasting_notes` — see `Y0-schema.md §TastingNotes`

Dashboard queries are read-only. Performance target: dashboard API response ≤ 300ms for collections up to 500 records (per NFR).

---
