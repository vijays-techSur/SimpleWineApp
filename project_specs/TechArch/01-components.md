---

## 2. Component Architecture

### 2.1 Frontend Components

All UI components are React components rendered via Next.js App Router. USWDS provides the structural markup patterns and accessibility baseline; TechSur brand tokens (CSS custom properties) override the USWDS defaults.

```
app/
├── layout.tsx                    ← Root layout: fonts, USWDS CSS, brand tokens, nav shell
├── page.tsx                      ← Dashboard (F06) — default landing route
├── wines/
│   ├── page.tsx                  ← Wine List view (F00.2, F03)
│   ├── new/page.tsx              ← Add Wine form (F00.1)
│   └── [wine_id]/
│       ├── page.tsx              ← Wine Detail view (F00.3)
│       └── edit/page.tsx         ← Edit Wine form (F00.4)
├── locations/
│   └── page.tsx                  ← Storage Locations list (F02.6)
├── settings/
│   └── page.tsx                  ← Settings: rating scale (F04.6)
└── api/v1/                       ← API route handlers (see §3 API Design)
    ├── wines/
    │   ├── route.ts              ← GET (list), POST
    │   └── [wine_id]/
    │       ├── route.ts          ← GET, PUT, PATCH, DELETE
    │       ├── events/route.ts   ← POST, GET
    │       ├── quantity/route.ts ← PATCH
    │       └── tasting-notes/
    │           ├── route.ts      ← GET, POST
    │           └── [note_id]/route.ts ← GET, PUT, DELETE
    ├── locations/
    │   ├── route.ts              ← GET, POST
    │   └── [location_id]/route.ts ← PUT, DELETE
    ├── dashboard/
    │   ├── route.ts              ← GET (full dashboard)
    │   └── stats/route.ts        ← GET (stats only)
    └── settings/
        └── rating-scale/route.ts ← GET, PUT
```

#### Core UI Component Groups

**Navigation Shell**
- `AppHeader` — site header with logo (TechSur wordmark), primary nav links, mobile hamburger
- `AppNav` — primary navigation: Dashboard, My Wines, Settings
- `MobileBottomNav` — bottom tab bar on mobile (Dashboard, Wines, Add, Settings)
- `FloatingAddButton` — Gold FAB ("+" icon) fixed to bottom-right; navigates to Add Wine

**Wine List & Cards**
- `WineListPage` — orchestrates search bar, filter panel, sort control, wine list
- `WineCard` — mobile card layout: name, producer, vintage, type badge, readiness badge, quantity pill, location
- `WineTableRow` — desktop table row (same data + country/region/price columns)
- `ReadinessBadge` — color-coded status pill (DRINK_NOW → Gold, APPROACHING_PEAK → Amber, HOLD → Gray, PAST_WINDOW → Muted, NO_WINDOW_SET → Ghost)
- `WineTypeBadge` — wine type enum label with color accent
- `QuantityPill` — bottle count badge; "Cellar Empty" state

**Search & Filter (F03)**
- `SearchBar` — persistent text input with clear button; debounced 100ms client-side filter
- `FilterPanel` — collapsible drawer (mobile) / sidebar (desktop) with all filter controls
- `FilterChip` — dismissible active filter chip; rendered above wine list
- `SortControl` — dropdown/select for sort dimension + direction
- `FilterEngine` — pure function (no UI) that applies search + all filters to wine array client-side

**Wine Forms (F00, F01, F04)**
- `WineForm` — unified Add/Edit form with all fields; USWDS form components throughout
- `FormSection` — labeled section group (Identity, Provenance, Storage, Drinking Window, Notes)
- `StorageLocationSelect` — required dropdown with "Add new location..." inline option
- `DrinkingWindowFields` — paired year inputs with cross-field validation display
- `BottleEventSheet` — action sheet with Consumed / Gifted / Opened options
- `ConsumeEventDialog` — consume event form (date, notes, tasting note toggle)
- `GiftEventDialog` — gift event form (date, recipient, notes)
- `OpenEventDialog` — open event form (date, notes)

**Tasting Notes (F04)**
- `TastingNoteForm` — add/edit form with all sensory fields + rating widget + would-buy-again
- `RatingWidget` — renders as 5-star selector or 0–100 numeric input per user setting
- `WouldBuyAgainToggle` — three-state toggle: YES / NO / MAYBE
- `TastingNoteCard` — collapsed and expanded note display in history list
- `TastingNoteHistory` — chronological list of notes on wine detail

**Wine Detail (F00.3, F01.7)**
- `WineDetailPage` — full record view with all sections
- `BottleHistorySection` — chronological bottle event log (F01.7)
- `BottleEventRow` — single event with type icon, date, notes; links to tasting note if linked
- `QuantityControls` — +/− buttons with current count; − disabled at 0

**Dashboard (F06)**
- `DashboardPage` — home screen; renders all dashboard cards
- `StatsTile` — single metric tile (total bottles, drink now count, etc.)
- `DrinkNowShelf` — horizontally scrollable wine card row; links to filtered wine list
- `BreakdownByType` — 6-row list with count + percentage + type icon
- `BreakdownByRegion` — top 5 regions with count + percentage
- `BreakdownByDecade` — decade rows with proportional bar
- `RecentlyAddedCard` — compact list of 5 most recent wines
- `RecentlyConsumedCard` — compact list of 5 most recent CONSUMED events
- `HighestRatedCard` — top 5 wines by rating

**Storage Locations (F02)**
- `LocationsPage` — list of all locations with bottle counts + create/edit/delete actions
- `LocationRow` — single location with Edit/Delete controls
- `CreateLocationModal` — inline name input form
- `DeleteLocationModal` — confirmation with affected wine count

**Shared / System**
- `ConfirmationModal` — reusable destructive action confirmation dialog
- `ToastNotification` — non-blocking success/error toast (3s auto-dismiss for success)
- `EmptyState` — centered illustration + message + primary CTA
- `ErrorBoundary` — card-level error fallback with retry

---

### 2.2 Backend Modules

The Next.js API routes delegate to a set of server-side modules:

```
lib/
├── db.ts                   ← PostgreSQL connection pool (node-postgres)
├── db-sqlite.ts            ← SQLite alternative connection (better-sqlite3)
├── validation/
│   ├── wines.ts            ← Zod schemas for wine CRUD inputs
│   ├── locations.ts        ← Zod schemas for location inputs
│   ├── events.ts           ← Zod schemas for bottle events
│   ├── tasting-notes.ts    ← Zod schemas for tasting note inputs
│   └── settings.ts         ← Zod schemas for settings inputs
├── queries/
│   ├── wines.ts            ← SQL queries: list (with filters), get, create, update, delete
│   ├── locations.ts        ← SQL queries: list (with counts), create, rename, delete
│   ├── events.ts           ← SQL queries: create event, list events, patch quantity
│   ├── tasting-notes.ts    ← SQL queries: list, create, update, delete; refresh latest_rating
│   ├── dashboard.ts        ← SQL queries: dashboard aggregate
│   └── settings.ts         ← SQL queries: get/update user_settings
├── business/
│   ├── readiness.ts        ← F05 readiness status calculation (pure function)
│   ├── rating.ts           ← latest_rating refresh logic
│   └── location.ts         ← location_unknown flag management
└── errors.ts               ← API error response factory
```

**Readiness Status Calculation** (`lib/business/readiness.ts`)  
Pure TypeScript function — no DB round-trip. Called on every API response that includes a wine record. The algorithm matches F05 §Process verbatim:

```typescript
export function calculateReadinessStatus(
  drinkWindowStart: number | null,
  drinkWindowEnd: number | null,
  currentYear: number = new Date().getUTCFullYear()
): ReadinessStatus {
  if (!drinkWindowStart && !drinkWindowEnd) return 'NO_WINDOW_SET';
  if (drinkWindowStart && currentYear >= drinkWindowStart &&
      (!drinkWindowEnd || currentYear <= drinkWindowEnd)) return 'DRINK_NOW';
  if (drinkWindowStart && currentYear >= drinkWindowStart - 2 &&
      currentYear < drinkWindowStart) return 'APPROACHING_PEAK';
  if (drinkWindowStart && currentYear < drinkWindowStart - 2) return 'HOLD';
  if (drinkWindowEnd && currentYear > drinkWindowEnd) return 'PAST_WINDOW';
  return 'NO_WINDOW_SET';
}
```

**latest_rating Refresh** (`lib/business/rating.ts`)  
After any tasting note insert/update/delete, application queries the most recent tasting note with a rating for the parent wine and updates `wines.latest_rating`, `latest_rating_scale`, `latest_rating_date`.

---

### 2.3 Client-Side Filter Engine

All filtering (F03) is performed in-memory on the client for collections up to 500 records (NFR target). The filter engine receives the full wine array from a React Query cache and applies all active criteria:

```typescript
// lib/filter/filterWines.ts — pure function, no side effects
export function filterWines(
  wines: WineRecord[],
  filters: FilterState,
  searchQuery: string,
  currentYear: number
): WineRecord[] {
  let result = wines;
  // 1. Full-text search (Fuse.js fuzzy match on name, producer, region, grape_variety)
  // 2. Wine type filter (OR within multi-select)
  // 3. Producer exact match (case-insensitive)
  // 4. Country exact match
  // 5. Region exact match
  // 6. Vintage range [from, to]
  // 7. Grape variety substring match
  // 8. Storage location exact ID match (or "UNKNOWN")
  // 9. Readiness status (calculate then filter — OR within multi-select)
  // 10. Rating range filter (on latest_rating)
  return result;
}
```

**Sort** is applied after filter as a separate pure function per the selected sort key.

---
