# Technical Architecture Document
## SimpleWineApp — Personal Wine Collection Manager

**Project:** SimpleWineApp
**TechArch Version:** 1.0
**PRD Reference:** PRD-SimpleWineApp.md v1.0
**FRD Reference:** FRD-SimpleWineApp.md v1.0
**Date:** 2026-06-03
**Status:** Draft
**Author:** Pivota Spec TechArch Generator

---

## 1. Architectural Overview

### 1.1 Architecture Pattern

SimpleWineApp is a **full-stack web application** following a **layered monolith** pattern with a clear client/server separation. The architecture prioritizes simplicity, fast iteration, and data sovereignty — the defining constraints of a single-user personal-use MVP.

**Pattern:** Next.js Full-Stack Monolith (App Router)
- Frontend: React (via Next.js App Router) with USWDS + TechSur brand overlay
- Backend: Next.js API Routes (serverless-compatible) serving REST endpoints at `/api/v1`
- Database: PostgreSQL (primary) with SQLite as a portable alternative for local/self-hosted deployments
- All data remains within the user's own deployment environment — no external SaaS data dependencies

**Rationale for Next.js:**
- Unified codebase reduces operational complexity for a single-developer/personal-use project
- App Router enables server-side rendering for readiness status calculation at request time (required by F05)
- API routes provide a clean REST surface without a separate server process
- First-class TypeScript support for type-safe API boundaries
- Strong ecosystem compatibility with USWDS (vanilla CSS + JS design system)
- Excellent static export and self-hosting options satisfy the data sovereignty requirement

**Why not a SPA + separate API server?**  
Adds deployment complexity (two processes, CORS configuration, separate hosting) with no benefit for a single-user app. Next.js API routes eliminate this overhead.

**Why PostgreSQL (primary)?**  
The FRD DDL uses PostgreSQL-specific syntax (`gen_random_uuid()`, `TIMESTAMPTZ`, functional indexes on `LOWER()`). PostgreSQL provides the CHECK constraints, cascade rules, and index types required. SQLite is supported as a portable fallback for local-only deployments (minor DDL adaptation needed for UUID generation and some constraints).

---

### 1.2 System Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────────┐
│                        Browser (Client)                             │
│                                                                     │
│  ┌──────────────────────────────────────────────────────────────┐   │
│  │                    Next.js App Router                        │   │
│  │                                                              │   │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐  │   │
│  │  │  Dashboard  │  │  Wine List  │  │  Wine Detail / Form │  │   │
│  │  │   (F06)     │  │  + Filter   │  │  + Tasting Notes    │  │   │
│  │  │             │  │   (F03)     │  │  + Bottle Events    │  │   │
│  │  └─────────────┘  └─────────────┘  └─────────────────────┘  │   │
│  │                                                              │   │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐  │   │
│  │  │  Storage    │  │  Settings   │  │  Client-Side Filter │  │   │
│  │  │  Locations  │  │  (F04.6)    │  │  Engine (F03)       │  │   │
│  │  │   (F02)     │  │             │  │                     │  │   │
│  │  └─────────────┘  └─────────────┘  └─────────────────────┘  │   │
│  │                                                              │   │
│  │  ┌──────────────────────────────────────────────────────┐   │   │
│  │  │           USWDS + TechSur Brand CSS Layer            │   │   │
│  │  │   Self-hosted fonts (Montserrat, Fraunces, Open      │   │   │
│  │  │   Sans, JetBrains Mono) · Mobile-first responsive    │   │   │
│  │  └──────────────────────────────────────────────────────┘   │   │
│  └──────────────────────────────────────────────────────────────┘   │
│                                                                     │
│           Service Worker (offline read cache — progressive)         │
└────────────────────────────┬────────────────────────────────────────┘
                             │ HTTPS / HTTP (same origin)
                             │ JSON (application/json)
┌────────────────────────────▼────────────────────────────────────────┐
│                     Next.js API Routes (/api/v1)                    │
│                      (Node.js runtime)                              │
│                                                                     │
│  ┌────────────┐ ┌──────────────┐ ┌────────────┐ ┌───────────────┐  │
│  │  /wines    │ │  /locations  │ │ /dashboard │ │  /settings    │  │
│  │  (F00/F01) │ │    (F02)     │ │   (F06)    │ │  (F04 scale)  │  │
│  └────────────┘ └──────────────┘ └────────────┘ └───────────────┘  │
│                                                                     │
│  ┌──────────────────────────────────────────────────────────────┐   │
│  │           Business Logic Layer                               │   │
│  │  · Validation (Zod schemas)                                  │   │
│  │  · Readiness status calculation (F05 algorithm)              │   │
│  │  · latest_rating denormalization (F04 post-write)            │   │
│  │  · location_unknown flag management (F02 delete cascade)     │   │
│  └──────────────────────────────────────────────────────────────┘   │
│                                                                     │
│  ┌──────────────────────────────────────────────────────────────┐   │
│  │           Data Access Layer (node-postgres / pg)             │   │
│  │                 Parameterized SQL queries                    │   │
│  └──────────────────────────────────────────────────────────────┘   │
└────────────────────────────┬────────────────────────────────────────┘
                             │ TCP (local network or loopback)
┌────────────────────────────▼────────────────────────────────────────┐
│                        PostgreSQL                                   │
│                                                                     │
│   wines · storage_locations · bottle_events                         │
│   tasting_notes · user_settings                                     │
│                                                                     │
│   (SQLite alternative: better-sqlite3 driver, adapted DDL)          │
└─────────────────────────────────────────────────────────────────────┘
```

---

### 1.3 Deployment Topology

SimpleWineApp is designed for **self-hosted single-user deployment**. The application is a unified Next.js process that handles both the web UI and the REST API.

```
┌─────────────────────────────────────────────┐
│               Deployment Host               │
│         (VPS, home server, or local)        │
│                                             │
│  ┌────────────────────────────────────────┐ │
│  │     Next.js process (npm start)        │ │
│  │     PORT 3000 (or env-configured)      │ │
│  └────────────────────────────────────────┘ │
│                                             │
│  ┌────────────────────────────────────────┐ │
│  │  PostgreSQL (local or Docker)          │ │
│  │  Port 5432 (loopback only)             │ │
│  └────────────────────────────────────────┘ │
│                                             │
│  ┌────────────────────────────────────────┐ │
│  │  Reverse proxy: Nginx / Caddy          │ │
│  │  · HTTPS termination                   │ │
│  │  · Proxy → Next.js :3000               │ │
│  └────────────────────────────────────────┘ │
└─────────────────────────────────────────────┘
```

**Alternatively:** The app can be deployed to any Node.js-compatible PaaS (Railway, Fly.io, Render, DigitalOcean App Platform) with a managed PostgreSQL add-on, provided the user controls the database and no data is transmitted to third-party analytics.

**Environment variables:**
```
DATABASE_URL=postgresql://user:pass@localhost:5432/simplewineapp
NODE_ENV=production
NEXT_PUBLIC_APP_VERSION=1.0.0
```

---

### 1.4 Key Architectural Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Framework | Next.js 14+ (App Router) | Unified full-stack, SSR for readiness calculation, TypeScript-first |
| Language | TypeScript | Type safety across API boundaries; reduces runtime errors |
| Database (primary) | PostgreSQL 15+ | FRD DDL is PostgreSQL-native; supports all required constraints |
| Database (alt) | SQLite via better-sqlite3 | Portable local deployment; simpler ops for single-user |
| ORM/Query | Raw SQL via node-postgres (pg) | Full control of query shape; no ORM abstraction overhead for simple queries |
| Validation | Zod | Runtime schema validation for all API inputs; TypeScript inference |
| State management | React Query (TanStack Query) | Server state, caching, background refetch for wine list |
| Client-side filter | In-memory JS (Fuse.js for text) | ≤500 records target; no server round-trip; instant search (F03 NFR) |
| Font delivery | Self-hosted WOFF2 | Privacy requirement — no CDN calls to Google Fonts |
| USWDS delivery | npm bundle (no CDN) | Privacy + offline requirements |
| Offline read | Service Worker + Cache API | Progressive enhancement; read-only offline (F03 NFR) |
| Auth | None (v1) | Single-user personal-use; no auth required in MVP |
| UUID generation | `crypto.randomUUID()` (app layer) | Portable; no DB-specific extension required beyond `gen_random_uuid()` |

---
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
---

## 3. Data Model

### 3.1 Entity Relationship Diagram

```
┌──────────────────────┐
│   storage_locations  │
│──────────────────────│
│ location_id  PK      │
│ location_name        │
│ created_at           │
│ updated_at           │
└──────────┬───────────┘
           │ SET NULL on delete
           │ 1 ──── 0..*
┌──────────▼───────────────────────────────────────────────┐
│                          wines                           │
│──────────────────────────────────────────────────────────│
│ wine_id             PK                                   │
│ wine_name           NOT NULL                             │
│ producer            NOT NULL                             │
│ vintage_year        NOT NULL · CHECK 1900-2200           │
│ wine_type           NOT NULL · ENUM                      │
│ grape_variety                                            │
│ country                                                  │
│ region                                                   │
│ appellation                                              │
│ bottle_size         DEFAULT 750ML · ENUM                 │
│ quantity            NOT NULL DEFAULT 1 · CHECK >= 0      │
│ is_open             NOT NULL DEFAULT FALSE               │
│ storage_location_id FK → storage_locations (nullable)   │
│ location_unknown    NOT NULL DEFAULT FALSE               │
│ purchase_date                                            │
│ purchase_source                                          │
│ purchase_price      NUMERIC(10,2)                        │
│ estimated_value     NUMERIC(10,2)                        │
│ drink_window_start  CHECK 1900-2200                      │
│ drink_window_end    CHECK 1900-2200                      │
│ notes               TEXT max 5000                        │
│ latest_rating       NUMERIC(5,1) [denormalized]          │
│ latest_rating_scale [denormalized]                       │
│ latest_rating_date  [denormalized]                       │
│ created_at          NOT NULL                             │
│ updated_at          NOT NULL                             │
└──────────┬───────────────────────────────────────────────┘
           │
     ┌─────┴──────────────────────────────┐
     │ CASCADE on delete                  │ CASCADE on delete
     │ 1 ──── 0..*                        │ 1 ──── 0..*
┌────▼─────────────────┐    ┌─────────────▼────────────────┐
│    bottle_events     │    │        tasting_notes         │
│──────────────────────│    │──────────────────────────────│
│ event_id      PK     │    │ note_id         PK           │
│ wine_id       FK     │    │ wine_id         FK           │
│ event_type    ENUM   │    │ bottle_event_id FK (null OK) │
│ event_date    NOT NULL│   │ date_tasted     NOT NULL     │
│ notes         500ch  │    │ appearance      500ch        │
│ recipient     200ch  │    │ aroma           500ch        │
│ tasting_note_id FK◄──┼────│ flavor          1000ch       │
│               (null) │    │ finish          500ch        │
│ created_at           │    │ personal_rating NUMERIC(5,1) │
└──────────────────────┘    │ rating_scale    ENUM         │
                            │ would_buy_again ENUM         │
                            │ occasion        200ch        │
                            │ guest_feedback  500ch        │
                            │ created_at                   │
                            │ updated_at                   │
                            └──────────────────────────────┘

┌──────────────────────┐
│    user_settings     │   (singleton — 1 row)
│──────────────────────│
│ settings_id   PK     │
│ rating_scale  ENUM   │
│ created_at           │
│ updated_at           │
└──────────────────────┘
```

**Relationship notes:**
- `storage_locations` → `wines`: one-to-many, SET NULL on location delete (FK becomes NULL, `location_unknown` flagged TRUE by app logic)
- `wines` → `bottle_events`: one-to-many, CASCADE DELETE
- `wines` → `tasting_notes`: one-to-many, CASCADE DELETE
- `bottle_events.tasting_note_id` → `tasting_notes`: optional link, SET NULL on note delete
- `tasting_notes.bottle_event_id` → `bottle_events`: optional link, SET NULL on event delete
- `user_settings`: standalone singleton table, no FK relationships

---

### 3.2 Complete DDL

> **Target:** PostgreSQL 15+. SQLite adaptation notes are included inline as comments.

#### `storage_locations` Table

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

#### `wines` Table

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

#### `bottle_events` Table

> Note: `bottle_events` references `tasting_notes` (added via ALTER after `tasting_notes` is created).

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

#### `tasting_notes` Table

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

#### `user_settings` Table

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

---

### 3.3 Migration Strategy

Use **db-migrate** or **node-pg-migrate** for version-controlled schema migrations. Migration files live in `db/migrations/`.

**Creation order (respects FK dependencies):**
1. `storage_locations`
2. `wines` (FK → storage_locations)
3. `bottle_events` (FK → wines; tasting_note_id column without FK initially)
4. `tasting_notes` (FK → wines, → bottle_events)
5. ALTER `bottle_events` ADD CONSTRAINT FK → tasting_notes
6. `user_settings` + seed row

**Index creation:** Included in the same migration as the table CREATE.

---
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
---

## 5. Security Architecture

### 5.1 Authentication

**v1 MVP: No authentication layer.** SimpleWineApp is a single-user personal-use application deployed in the user's own environment (local machine, home server, or private VPS). No user accounts, sessions, or tokens exist in v1.

**Rationale:**
- A personal app accessed only by the owner on their own network has no meaningful multi-user threat vector
- Adding auth complexity would increase the barrier to self-hosting without providing value
- PRD explicitly defers authentication to Phase 2+ ("Single-user app in v1 — no auth layer required in MVP")

**Phase 2 auth path (documented for future reference):**
- JWT sessions via Next.js middleware (`next-auth` / `lucia-auth`)
- Or HTTP Basic Auth at the reverse proxy layer (Nginx/Caddy) for minimal friction
- API routes annotated with middleware hooks to be un-commented when auth is added

---

### 5.2 Authorization

No role-based or attribute-based authorization in v1. All API routes are accessible without a token. The access model is:

```
User (sole owner) → Full access to all endpoints
```

When Phase 2 auth is added, all API routes will require a valid session. The single-user constraint means all data is owned by the authenticated user — no resource-level ownership checks are needed in v1 (only one "account" exists).

---

### 5.3 Input Validation & Injection Prevention

All API inputs are validated with **Zod** schemas before any database operation. Validation occurs at the API route handler, before reaching the query layer.

**Validation strategy:**

| Layer | Mechanism |
|-------|-----------|
| HTTP request body | Zod schema parse — rejects unknown fields, enforces types and constraints |
| Query parameters | Zod schema coerce — type-coerce strings to integers/numbers; validate enum values |
| String fields | Max length enforced by Zod before reaching DB |
| Enum fields | Zod enum validation; only exact values accepted |
| Date fields | Zod string().regex() + refine() for ISO 8601; future-date check in business logic |
| Cross-field rules | Zod `.superRefine()` for window start ≤ end, rating range, etc. |

**SQL injection prevention:**
All database queries use **parameterized queries** exclusively via `node-postgres` (`pg`). No string concatenation into SQL. Example:

```typescript
// Correct — parameterized
const result = await db.query(
  'SELECT * FROM wines WHERE wine_id = $1',
  [wineId]
);

// Never — string interpolation
// const result = await db.query(`SELECT * FROM wines WHERE wine_id = '${wineId}'`);
```

**HTML/script injection:**
All user-supplied text fields are stored as plain text. The API does not accept or return HTML. The React frontend escapes all text content by default (React's built-in XSS protection). No `dangerouslySetInnerHTML` is used.

---

### 5.4 Data Protection

**Privacy by design (PRD §8 Non-Functional Requirements):**

| Requirement | Implementation |
|-------------|---------------|
| No third-party analytics | No analytics script loaded; no telemetry calls in application code |
| No CDN font loading | All fonts bundled as WOFF2 files; served from `/public/fonts/` |
| No external API calls from client | All network requests go to same-origin `/api/v1` only |
| No third-party CDN for USWDS | USWDS installed as npm package; assets served from app bundle |
| Data residency | All data stays in user's PostgreSQL instance; no cloud sync |

**HTTPS:**
Required for production deployment. Enforced at the reverse proxy layer (Nginx/Caddy with TLS). Next.js itself runs over HTTP behind the proxy on the loopback interface only.

**Database access:**
PostgreSQL listens on loopback (`127.0.0.1:5432`) only. No external database port exposure. The application connects using environment variable `DATABASE_URL` — never hardcoded credentials.

**Environment secrets:**
```
DATABASE_URL      # Connection string (never committed to source control)
```
Use `.env.local` for development (`.gitignore`'d). Use host environment variables or a secrets manager for production.

---

### 5.5 Content Security Policy (CSP)

Configure via Next.js `headers()` in `next.config.ts`:

```
Content-Security-Policy:
  default-src 'self';
  script-src 'self' 'nonce-{RANDOM}';
  style-src 'self' 'unsafe-inline';  ← USWDS inline styles require this; tighten post-MVP
  font-src 'self';                    ← Self-hosted fonts only; no CDN
  img-src 'self' data:;
  connect-src 'self';                 ← API calls to same origin only
  frame-ancestors 'none';
  form-action 'self';
```

**Rationale for `unsafe-inline` on style-src:** USWDS applies some inline styles via JavaScript. This can be eliminated post-MVP by extracting USWDS to a fully static CSS bundle.

---

### 5.6 HTTP Security Headers

All responses include security headers via Next.js middleware or `next.config.ts`:

| Header | Value |
|--------|-------|
| `X-Content-Type-Options` | `nosniff` |
| `X-Frame-Options` | `DENY` |
| `Referrer-Policy` | `no-referrer` |
| `Permissions-Policy` | `camera=(), microphone=(), geolocation=()` |
| `Strict-Transport-Security` | `max-age=63072000; includeSubDomains` (set at reverse proxy) |

---

### 5.7 Data Integrity Rules

These constraints protect data integrity at the application and database layers:

| Rule | Enforcement Layer |
|------|------------------|
| `quantity` cannot go below 0 | Application (disabled − button at 0) + DB CHECK constraint |
| Required fields enforced on write | Zod validation + DB NOT NULL |
| Enum values validated | Zod enum + DB CHECK constraint |
| Vintage year 1900–(currentYear+1) | Zod refine() in application layer |
| Purchase date not in future | Application validation (Zod refine) |
| Event date not in future | Application validation + DB CHECK (CURRENT_DATE) |
| Drinking window start ≤ end | Application (Zod superRefine) + DB CHECK constraint |
| Cascade deletes (wine → events, notes) | DB ON DELETE CASCADE |
| Location delete → flag wines | Application logic (SET NULL + location_unknown = TRUE) |
| `latest_rating` cache consistency | Application logic: refresh on every tasting_note write |

---
---

## 6. Technology Stack

### 6.1 Full Stack Table

| Layer | Technology | Version | Purpose |
|-------|------------|---------|---------|
| **Framework** | Next.js | 14.x+ (App Router) | Full-stack React framework; UI + API routes in one process |
| **Language** | TypeScript | 5.x | Type-safe development across frontend and backend |
| **UI Framework** | React | 18.x | Component model for interactive UI |
| **Design System** | USWDS | Latest stable | Accessible component patterns, design tokens, grid system |
| **Brand Layer** | Custom CSS (CSS custom properties) | — | TechSur brand tokens as CSS override layer on USWDS |
| **Database (primary)** | PostgreSQL | 15+ | Relational data store; full FRD DDL support |
| **Database (alt)** | SQLite | 3.x (via better-sqlite3) | Portable local deployment alternative |
| **DB Client** | node-postgres (pg) | 8.x | PostgreSQL driver with connection pool |
| **DB Client (alt)** | better-sqlite3 | 9.x | Synchronous SQLite driver |
| **Validation** | Zod | 3.x | Runtime schema validation + TypeScript inference |
| **Server State** | TanStack Query (React Query) | 5.x | Client-side data fetching, caching, background sync |
| **Client Filter** | Fuse.js | 7.x | Fuzzy full-text search for client-side wine list filtering |
| **Migrations** | node-pg-migrate | 6.x | Version-controlled schema migrations |
| **HTTP Client** | fetch (native) | — | Browser native; no extra library needed |
| **Styling** | CSS Modules + USWDS | — | Scoped component styles + USWDS design tokens |
| **Service Worker** | Workbox (via next-pwa) | 6.x | Offline read cache (progressive enhancement) |
| **Runtime** | Node.js | 20 LTS | Server runtime for Next.js |
| **Package Manager** | npm | 10.x | Dependency management |

### 6.2 Key NPM Dependencies

```json
{
  "dependencies": {
    "next": "^14.0.0",
    "react": "^18.0.0",
    "react-dom": "^18.0.0",
    "typescript": "^5.0.0",
    "@uswds/uswds": "^3.0.0",
    "zod": "^3.0.0",
    "@tanstack/react-query": "^5.0.0",
    "fuse.js": "^7.0.0",
    "pg": "^8.0.0",
    "better-sqlite3": "^9.0.0"
  },
  "devDependencies": {
    "@types/pg": "^8.0.0",
    "@types/better-sqlite3": "^7.0.0",
    "@types/react": "^18.0.0",
    "@types/node": "^20.0.0",
    "node-pg-migrate": "^6.0.0",
    "eslint": "^8.0.0",
    "eslint-config-next": "^14.0.0"
  }
}
```

### 6.3 Fonts

Self-hosted as WOFF2 files in `/public/fonts/`. Declared in root CSS via `@font-face`. No CDN loading.

| Font Family | Weights Loaded | Usage |
|-------------|---------------|-------|
| Montserrat | 700, 900 | Headings, buttons, eyebrows |
| Fraunces | 400, 600 (italic) | Serif accent, emphasis |
| Open Sans | 400, 600, 700 | Body copy, form labels, UI text |
| JetBrains Mono | 400, 500 | Labels, badges, eyebrows (UPPERCASE) |

**CSS font-face declarations** (in `styles/fonts.css`, imported in root layout):
```css
@font-face {
  font-family: 'Montserrat';
  src: url('/fonts/montserrat-700.woff2') format('woff2'),
       url('/fonts/montserrat-700.woff') format('woff');
  font-weight: 700;
  font-style: normal;
  font-display: swap;
}
/* ... additional weights and families */
```

### 6.4 TechSur Brand Tokens (CSS Custom Properties)

Defined in `styles/techsur-tokens.css`, imported after USWDS base styles:

```css
:root {
  /* Color palette */
  --color-gold-400: #FBCA5C;   /* Primary accent: CTAs, Drink Now badge, primary buttons */
  --color-gold-500: #E6B040;   /* Serif accent on light backgrounds */
  --color-gold-600: #B0832A;   /* Gold text on light bg (contrast-safe) */
  --color-canvas-dark: #0A0A0A; /* Hero areas, nav background (dark) */
  --color-bone: #FAFAF7;        /* Light canvas, page background */
  --color-paper: #F5F5F2;       /* Alt card surface */
  --color-ink: #1A1A1A;         /* Body text on light */
  --color-gray-400: #A8A59B;    /* Muted labels, secondary text */

  /* Readiness status badge colors */
  --color-drink-now: #FBCA5C;          /* Gold 400 */
  --color-approaching-peak: #F5A623;   /* Amber */
  --color-hold: #D4D1C9;               /* Gray 300 */
  --color-past-window: #E8E6E1;        /* Gray 200 */

  /* Typography */
  --font-display: 'Montserrat', system-ui, sans-serif;
  --font-accent: 'Fraunces', Georgia, serif;
  --font-body: 'Open Sans', system-ui, sans-serif;
  --font-mono: 'JetBrains Mono', 'Courier New', monospace;

  /* Button */
  --radius-button: 2px;
}
```

**USWDS token overrides** (in same or adjacent file):
```css
/* Override USWDS font family tokens */
:root {
  --theme-font-type-sans: 'Open Sans', system-ui, sans-serif;
  --theme-font-type-serif: 'Fraunces', Georgia, serif;
  --theme-font-type-mono: 'JetBrains Mono', 'Courier New', monospace;
  --theme-color-primary: #FBCA5C;
  --theme-color-primary-dark: #E6B040;
}
```

### 6.5 Project Directory Structure

```
simplewineapp/
├── app/                          ← Next.js App Router pages + API routes
│   ├── layout.tsx
│   ├── page.tsx                  ← Dashboard
│   ├── wines/
│   ├── locations/
│   ├── settings/
│   └── api/v1/
├── components/                   ← Reusable React components
│   ├── wine/
│   ├── dashboard/
│   ├── filter/
│   ├── tasting-notes/
│   ├── locations/
│   └── shared/
├── lib/                          ← Server-side business logic + DB
│   ├── db.ts
│   ├── validation/
│   ├── queries/
│   └── business/
├── styles/                       ← Global CSS
│   ├── globals.css
│   ├── fonts.css
│   └── techsur-tokens.css
├── public/
│   ├── fonts/                    ← Self-hosted WOFF2 font files
│   └── icons/
├── db/
│   └── migrations/               ← node-pg-migrate migration files
├── types/                        ← Shared TypeScript interfaces (index.ts)
├── .env.local                    ← Local dev secrets (gitignored)
├── next.config.ts
├── tsconfig.json
└── package.json
```

---
---

## 7. Integration Points

### 7.1 Summary

SimpleWineApp v1 is deliberately minimal in external dependencies. Per the PRD privacy requirement: *"No user data sent to third-party analytics or external services in v1."* All external dependencies are either bundled into the application or served from the user's own infrastructure.

| Integration | Type | Status | Delivery |
|-------------|------|--------|---------|
| USWDS | UI design system | Required | Bundled via npm (no CDN) |
| Montserrat | Font | Required | Self-hosted WOFF2 in `/public/fonts/` |
| Fraunces | Font | Required | Self-hosted WOFF2 in `/public/fonts/` |
| Open Sans | Font | Required | Self-hosted WOFF2 in `/public/fonts/` |
| JetBrains Mono | Font | Required | Self-hosted WOFF2 in `/public/fonts/` |
| PostgreSQL | Database | Required (primary) | User's own instance (local or Docker) |
| SQLite | Database | Required (alt) | Embedded via better-sqlite3 |
| Node.js runtime | Server | Required | User's own server / PaaS |
| Service Worker (Workbox) | Offline cache | Optional (progressive) | Bundled |

---

### 7.2 USWDS Integration

| Property | Specification |
|----------|--------------|
| Source | npm package `@uswds/uswds` |
| Version | Latest stable (pin exact version in package.json) |
| Delivery | Bundled with app via Next.js CSS import chain — NOT loaded from CDN |
| CSS import | `@import '@uswds/uswds/scss/uswds';` in `styles/globals.css` |
| Token override | TechSur brand tokens in `styles/techsur-tokens.css` applied after USWDS |
| Component usage | USWDS HTML markup patterns + CSS classes; no USWDS JavaScript components required (React components replace JS behavior) |
| Accessibility | USWDS provides WCAG 2.1 AA-compliant markup patterns; all custom components must match or exceed this baseline |

---

### 7.3 Font Delivery

All four font families are self-hosted to comply with the privacy requirement (no CDN requests that expose user IP addresses).

**Delivery process:**
1. Download WOFF2 (and WOFF fallback) files from the open-source repositories
2. Place in `/public/fonts/` directory
3. Declare via `@font-face` in `styles/fonts.css`
4. Import `fonts.css` in `app/layout.tsx`

**Font licenses:** All four families are released under the SIL Open Font License (OFL). Verify license compliance at project start.

**Font loading strategy:**
- `font-display: swap` to prevent invisible text during font load
- Preload critical fonts (Montserrat 700/900, Open Sans 400) in `<head>` via Next.js `<link rel="preload">`
- JetBrains Mono loaded asynchronously (label/badge use only; not render-blocking)

---

### 7.4 Database Integration

#### PostgreSQL (Primary)

| Property | Specification |
|----------|--------------|
| Driver | `node-postgres` (`pg`) npm package |
| Connection | Pool via `new Pool({ connectionString: process.env.DATABASE_URL })` |
| Pool size | Default (10 connections) — single-user app, effectively 1 concurrent user |
| Connection string | Set via `DATABASE_URL` environment variable |
| Migration tool | `node-pg-migrate` — migrations in `db/migrations/` |
| Local dev | `docker-compose.yml` with `postgres:15` image for local development |

```yaml
# docker-compose.yml (development)
services:
  postgres:
    image: postgres:15
    environment:
      POSTGRES_DB: simplewineapp
      POSTGRES_USER: wine
      POSTGRES_PASSWORD: localdev
    ports:
      - "5432:5432"
    volumes:
      - pgdata:/var/lib/postgresql/data
volumes:
  pgdata:
```

#### SQLite (Alternative)

| Property | Specification |
|----------|--------------|
| Driver | `better-sqlite3` npm package |
| File location | `./data/simplewineapp.db` (configurable via env var) |
| UUID generation | `crypto.randomUUID()` in application layer (SQLite has no `gen_random_uuid()`) |
| DDL adaptations | Remove `TIMESTAMPTZ` → `TEXT` (ISO 8601 strings); `NUMERIC` → `REAL`; functional index on `LOWER()` → enforce in app layer |
| Selection | Active driver selected via `DATABASE_DRIVER=postgres` or `DATABASE_DRIVER=sqlite` env var |

---

### 7.5 Offline Support (Service Worker)

| Property | Specification |
|----------|--------------|
| Library | Workbox (via `next-pwa` npm package) |
| Scope | Progressive enhancement — read-only offline; no offline write in v1 |
| Cache strategy | `StaleWhileRevalidate` for wine list data; `CacheFirst` for static assets |
| Cached resources | Static assets (JS, CSS, fonts, icons) + wine list API response |
| Cache invalidation | On next successful network request, stale cache replaced |
| Registration | Service worker registered in `app/layout.tsx` (production only) |

---

### 7.6 Deferred / Explicitly Excluded Integrations

The following integrations are explicitly excluded from v1 and must not be added without a PRD revision:

| Integration | Phase | Reason |
|-------------|-------|--------|
| External wine database (Wine Searcher, Vivino) | Phase 3 | External data dependency; cost; complexity |
| Label scanning / OCR | Phase 3 | Native camera API + ML service; significant UX complexity |
| AI-assisted bottle entry | Phase 3 | LLM API cost, latency, dependency on label scanning |
| Push / drinking window alerts | Phase 2 | Notification permission flow; deferred after base workflow proven |
| CSV / Excel import | Phase 2 | Non-trivial parsing; deferred after core CRUD proven |
| PDF / spreadsheet export | Phase 2 | Low-priority future scope |
| Third-party analytics (GA, Mixpanel, etc.) | Excluded | Explicitly prohibited by PRD privacy requirement |
| OAuth / SAML authentication | Phase 2+ | Single-user app; no auth in v1 |
| Shared household accounts | Phase 4 | Multi-user architecture change |
| Wine valuation APIs | Phase 2 | User-entered value sufficient for v1 |
| Cellar map visualization | Phase 2 | Named location text sufficient for v1 |

---

## 8. Non-Functional Requirements — Implementation Notes

| Requirement | Target | Implementation |
|-------------|--------|---------------|
| Wine list render time | ≤ 300ms (500 records, mid-range mobile) | React Query caches full wine array; client-side filter in JS; no server round-trip |
| Search / filter update | ≤ 100ms | Client-side Fuse.js + pure filter function; 100ms debounce on search input |
| Dashboard API | ≤ 300ms (500 records) | Single optimized SQL query with aggregations; `GET /api/v1/dashboard` |
| WCAG 2.1 AA | All components | USWDS provides compliant baseline; readiness badges always include text label |
| Responsive | 375px, 768px, 1024px, 1280px | USWDS grid + CSS breakpoints; mobile-first; filter panel: drawer ↔ sidebar |
| Quantity floor | Never below 0 | − button `disabled` at 0; PATCH /quantity API validates `adjustment = -1` when qty = 0 |
| Offline read | Wine list + search functional offline | Service Worker caches wine list response; Fuse.js runs on cached data |
| Browser support | Chrome, Firefox, Safari, Edge (latest 2) | Next.js target: `browserslist` defaults; WOFF2 with WOFF fallback |
| Data destruction | Confirm before delete | `ConfirmationModal` required for delete wine, delete location actions |
| Touch targets | Min 44×44px | Applied via USWDS touch-target utility class on all interactive elements |

---

## 9. Architecture Decision Log

| ID | Decision | Alternatives Considered | Rationale |
|----|----------|------------------------|-----------|
| ADR-001 | Next.js 14 App Router as the framework | Vite + Express (separate API), Remix, SvelteKit | Next.js provides SSR (needed for server-side readiness calculation), unified deployment, and strong TypeScript ecosystem. Vite+Express adds ops complexity for no benefit in single-user context. |
| ADR-002 | PostgreSQL as primary database | SQLite only, MySQL, Supabase | FRD DDL is PostgreSQL-native. PostgreSQL's CHECK constraints and functional indexes are cleaner. SQLite retained as a portable alternative with minor DDL adaptation. |
| ADR-003 | Raw SQL via node-postgres (no ORM) | Prisma, Drizzle ORM, Sequelize | Collection of 5 simple tables with known query patterns. Raw SQL gives full control, zero ORM abstraction cost, and aligns with FRD DDL directly. Can migrate to Drizzle later if complexity grows. |
| ADR-004 | Client-side filtering with Fuse.js | Server-side filtering per request | ≤500 records NFR target means in-memory filtering is faster than a server round-trip. React Query caches the full list; filter runs locally. Server-side filter params provided as a future-proof fallback. |
| ADR-005 | Self-hosted fonts (WOFF2) | Google Fonts CDN | PRD §8 explicitly prohibits sending user data to external services. Google Fonts CDN would log user IPs. All four OFL-licensed fonts bundled locally. |
| ADR-006 | No authentication in v1 | Basic Auth at proxy, next-auth | Single-user personal-use app on user's own infrastructure. Auth adds complexity with no meaningful security benefit for this threat model. Phase 2 path documented. |
| ADR-007 | Readiness status calculated at response time | Stored/cached in DB column, background job | FRD F05 requires recalculation on every render using CURRENT_DATE. Pure function is trivial to compute; caching would introduce staleness risk. No scheduled job needed. |
| ADR-008 | latest_rating denormalized on `wines` table | JOIN to tasting_notes on every list query | Wine list renders per-card rating without a JOIN. Maintained by app logic after every tasting_note write. Performance trade-off is correct for this read-heavy, write-occasional pattern. |

---

*TechArch generated by Pivota Spec TechArch Generator · SimpleWineApp v1.0 MVP · 2026-06-03*
