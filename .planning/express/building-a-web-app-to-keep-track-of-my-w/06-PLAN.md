---
phase: 03-frontend
plan: 06
type: execute
wave: 6
depends_on: [2, 3, 4]
files_modified:
  - app/cellar/page.tsx
  - components/wine-list/WineListPage.tsx
  - components/wine-list/WineCard.tsx
  - components/wine-list/WineTableRow.tsx
  - components/wine-list/ReadinessBadge.tsx
  - components/wine-list/QuantityPill.tsx
  - components/wine-list/SearchBar.tsx
  - components/wine-list/FilterPanel.tsx
  - components/wine-list/FilterChip.tsx
  - components/wine-list/SortControl.tsx
  - components/wine-list/WineListEmpty.tsx
  - hooks/useWineList.ts
  - hooks/useFilterPersistence.ts
  - types/wine.ts
autonomous: true

features:
  implements: ["F0", "F1", "F3", "F5"]
  depends_on: ["F0", "F1", "F2", "F3", "F5"]
  enables: ["F3", "F6"]

must_haves:
  truths:
    - "User can see all wines as scrollable cards on mobile (375px) — each card shows wine name, type badge, readiness badge, rating (if any), quantity pill, producer+vintage, and storage location"
    - "User can search by typing in the always-visible search bar — list filters client-side with 100ms debounce using Fuse.js"
    - "User can open a filter panel (bottom drawer on mobile, sidebar on desktop) and apply wine type, readiness, vintage range, grape variety, location, and rating range filters"
    - "Active filters appear as dismissible chips above the list with a 'Clear all' link — removing a chip removes only that filter, never others (CP-02)"
    - "Wines with quantity=0 are shown with 40% opacity badges and 70% card opacity — visually de-emphasized but not hidden (CP-05)"
    - "Storage location appears on every wine list card (CP-01)"
    - "Readiness badge shows correct color and text label for all 5 statuses (F5 badge spec exact colors)"
    - "Quantity pill shows EMPTY label in JetBrains Mono when quantity=0"
    - "Filter state persists within the browser session (CP-02)"
    - "Desktop view renders as table rows with additional columns (Country, Region, Purchase Price)"
    - "Result count label reads 'SHOWING N OF TOTAL WINES' in JetBrains Mono UPPERCASE"
  artifacts:
    - path: "components/wine-list/ReadinessBadge.tsx"
      provides: "ReadinessBadge component with exact status colors from UX-Mockup"
      exports: ["ReadinessBadge"]
      contains: "DRINK_NOW"
    - path: "components/wine-list/QuantityPill.tsx"
      provides: "QuantityPill component showing count or EMPTY label"
      exports: ["QuantityPill"]
    - path: "components/wine-list/WineCard.tsx"
      provides: "WineCard mobile card component"
      exports: ["WineCard"]
    - path: "components/wine-list/FilterPanel.tsx"
      provides: "FilterPanel — bottom drawer mobile, sidebar desktop"
      exports: ["FilterPanel"]
    - path: "components/wine-list/SearchBar.tsx"
      provides: "SearchBar with Fuse.js 100ms debounce"
      exports: ["SearchBar"]
    - path: "hooks/useWineList.ts"
      provides: "useWineList hook — fetches wines, manages Fuse index, exposes filteredWines"
      exports: ["useWineList"]
    - path: "types/wine.ts"
      provides: "WineRecord, ReadinessStatus, FilterState, WineSortKey shared types"
      exports: ["WineRecord", "ReadinessStatus", "FilterState", "WineSortKey"]
  key_links:
    - from: "hooks/useWineList.ts"
      to: "app/api/v1/wines"
      via: "fetch('/api/v1/wines') on mount"
      pattern: "fetch.*api/v1/wines"
    - from: "components/wine-list/FilterPanel.tsx"
      to: "lib/filter/filterWines.ts"
      via: "import { filterWines } from '@/lib/filter/filterWines'"
      pattern: "filterWines"
    - from: "components/wine-list/WineCard.tsx"
      to: "components/wine-list/ReadinessBadge.tsx"
      via: "import { ReadinessBadge }"
      pattern: "ReadinessBadge"
    - from: "hooks/useFilterPersistence.ts"
      to: "sessionStorage"
      via: "sessionStorage.setItem / getItem for filter state persistence (CP-02)"
      pattern: "sessionStorage"

integration_contracts:
  requires:
    - from_plan: "02"
      artifact: "app/api/v1/wines/route.ts"
      exports: ["GET"]
      verify: "grep -n 'export.*function GET\\|export.*GET' app/api/v1/wines/route.ts && echo CONTRACT_OK"
    - from_plan: "02"
      artifact: "lib/business/readiness.ts"
      exports: ["calculateReadinessStatus", "ReadinessStatus"]
      verify: "grep -n 'export function calculateReadinessStatus\\|export.*calculateReadinessStatus' lib/business/readiness.ts && echo CONTRACT_OK"
    - from_plan: "03"
      artifact: "app/api/v1/locations/route.ts"
      exports: ["GET"]
      verify: "grep -n 'export.*function GET\\|export.*GET' app/api/v1/locations/route.ts && echo CONTRACT_OK"
    - from_plan: "04"
      artifact: "lib/filter/filterWines.ts"
      exports: ["filterWines", "FilterState"]
      verify: "grep -n 'export.*filterWines\\|export.*FilterState' lib/filter/filterWines.ts && echo CONTRACT_OK"
    - from_plan: "04"
      artifact: "lib/filter/sortWines.ts"
      exports: ["sortWines"]
      verify: "grep -n 'export.*sortWines' lib/filter/sortWines.ts && echo CONTRACT_OK"
  provides:
    - artifact: "types/wine.ts"
      exports: ["WineRecord", "ReadinessStatus", "FilterState", "WineSortKey"]
      shape: |
        export type ReadinessStatus = 'DRINK_NOW' | 'APPROACHING_PEAK' | 'HOLD' | 'PAST_WINDOW' | 'NO_WINDOW_SET'
        export type WineType = 'RED' | 'WHITE' | 'ROSE' | 'SPARKLING' | 'DESSERT' | 'FORTIFIED'
        export type WineSortKey = 'created_at_desc' | 'created_at_asc' | 'wine_name_asc' | 'wine_name_desc' | 'vintage_year_desc' | 'vintage_year_asc' | 'quantity_desc' | 'quantity_asc' | 'rating_desc' | 'rating_asc' | 'drink_window_end_asc' | 'drink_window_end_desc'
        export interface WineRecord {
          wine_id: string; wine_name: string; producer: string; vintage_year: number;
          wine_type: WineType; grape_variety: string | null; country: string | null;
          region: string | null; quantity: number; is_open: boolean;
          storage_location_id: string | null; storage_location_name: string | null;
          location_unknown: boolean; drink_window_start: number | null;
          drink_window_end: number | null; latest_rating: number | null;
          latest_rating_scale: string | null; purchase_price: number | null;
          readiness_status: ReadinessStatus; created_at: string; updated_at: string;
        }
        export interface FilterState { ... } // matches lib/filter/filterWines.ts FilterState
      verify: "grep -n 'export.*WineRecord\\|export.*ReadinessStatus\\|export.*FilterState\\|export.*WineSortKey' types/wine.ts && echo CONTRACT_OK"
    - artifact: "components/wine-list/ReadinessBadge.tsx"
      exports: ["ReadinessBadge"]
      shape: |
        interface ReadinessBadgeProps { status: ReadinessStatus; muted?: boolean }
        export function ReadinessBadge({ status, muted }: ReadinessBadgeProps): JSX.Element
      verify: "grep -n 'export.*ReadinessBadge\\|export function ReadinessBadge' components/wine-list/ReadinessBadge.tsx && echo CONTRACT_OK"
    - artifact: "components/wine-list/QuantityPill.tsx"
      exports: ["QuantityPill"]
      shape: |
        interface QuantityPillProps { quantity: number; muted?: boolean }
        export function QuantityPill({ quantity, muted }: QuantityPillProps): JSX.Element
      verify: "grep -n 'export.*QuantityPill\\|export function QuantityPill' components/wine-list/QuantityPill.tsx && echo CONTRACT_OK"
    - artifact: "components/wine-list/WineCard.tsx"
      exports: ["WineCard"]
      shape: |
        interface WineCardProps { wine: WineRecord; onClick: () => void }
        export function WineCard({ wine, onClick }: WineCardProps): JSX.Element
      verify: "grep -n 'export.*WineCard\\|export function WineCard' components/wine-list/WineCard.tsx && echo CONTRACT_OK"
    - artifact: "hooks/useWineList.ts"
      exports: ["useWineList"]
      shape: |
        export function useWineList(): {
          wines: WineRecord[]; filteredWines: WineRecord[];
          isLoading: boolean; error: string | null;
          searchQuery: string; setSearchQuery: (q: string) => void;
          filters: FilterState; setFilters: (f: FilterState) => void;
          sortKey: WineSortKey; setSortKey: (k: WineSortKey) => void;
          clearAllFilters: () => void;
        }
      verify: "grep -n 'export.*useWineList\\|export function useWineList' hooks/useWineList.ts && echo CONTRACT_OK"
---

<objective>
Build the Wine List (My Cellar) page — the primary collection browse screen — with mobile card layout, desktop table layout, Fuse.js client-side search, multi-attribute filter panel, active filter chips with session persistence, ReadinessBadge component (5 exact UX-Mockup colors), and QuantityPill component.

Purpose: This is the core discovery screen where users find, filter, and navigate to their wines. Implements F0 list view, F1 quantity display, F3 search/filter with Fuse.js, and F5 readiness badges. The WineCard component and ReadinessBadge are also consumed by the Dashboard (wave 9).
Output: 14 files — 1 page, 7 components, 2 hooks, 1 types file, and 3 sub-components.
</objective>

<feature_dependencies>
Implements: F0: Wine Inventory CRUD (list view — WineListPage, WineCard, WineTableRow showing all wines with CRUD navigation), F1: Quantity & Bottle Status Tracking (QuantityPill showing current count or EMPTY badge, Cellar Empty card state), F3: Search & Filter (SearchBar with Fuse.js 100ms debounce, FilterPanel with all filter dimensions per FRD F03, FilterChip dismissal, session-persistent filter state CP-02, SortControl with all WineSortKey options), F5: Drinking Window Management (ReadinessBadge displaying all 5 statuses with exact colors from UX-Mockup spec)
Depends on: Wave 2 — GET /api/v1/wines (wines data), lib/business/readiness.ts (calculateReadinessStatus); Wave 3 — GET /api/v1/locations (location dropdown in filter); Wave 4 — filterWines.ts + sortWines.ts (client-side filter/sort engine)
Enables: F3 full filter UX, F6 dashboard (WineCard + ReadinessBadge reused in DrinkNowShelf), wave 9 dashboard page
</feature_dependencies>

<execution_context>
@/app/workspaces/.pivota-home/opencode-xdg/opencode/pivota_spec-framework/workflows/execute-plan.md
</execution_context>

<context>
@.planning/PROJECT.md
@.planning/express/building-a-web-app-to-keep-track-of-my-w/WAVE-SCHEDULE.md
@project_specs/UX-Mockup-SimpleWineApp.md
@project_specs/PRD-SimpleWineApp.md
@.planning/express/building-a-web-app-to-keep-track-of-my-w/04-PLAN.md
</context>

<tasks>

<task type="auto">
  <name>Task 1: Shared types, ReadinessBadge, QuantityPill, WineCard, WineTableRow, and WineListEmpty</name>
  <files>
    types/wine.ts
    components/wine-list/ReadinessBadge.tsx
    components/wine-list/QuantityPill.tsx
    components/wine-list/WineCard.tsx
    components/wine-list/WineTableRow.tsx
    components/wine-list/WineListEmpty.tsx
  </files>
  <action>
Create `types/` and `components/wine-list/` directories and write 6 files.

---

**types/wine.ts** — Shared TypeScript types. These must match the DB column names from TechArch §3.2 exactly (no renaming):

```typescript
// types/wine.ts
export type ReadinessStatus =
  | 'DRINK_NOW'
  | 'APPROACHING_PEAK'
  | 'HOLD'
  | 'PAST_WINDOW'
  | 'NO_WINDOW_SET';

export type WineType = 'RED' | 'WHITE' | 'ROSE' | 'SPARKLING' | 'DESSERT' | 'FORTIFIED';

export type WineSortKey =
  | 'created_at_desc'
  | 'created_at_asc'
  | 'wine_name_asc'
  | 'wine_name_desc'
  | 'vintage_year_desc'
  | 'vintage_year_asc'
  | 'quantity_desc'
  | 'quantity_asc'
  | 'rating_desc'
  | 'rating_asc'
  | 'drink_window_end_asc'
  | 'drink_window_end_desc';

export interface WineRecord {
  wine_id: string;
  wine_name: string;
  producer: string;
  vintage_year: number;
  wine_type: WineType;
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
  readiness_status: ReadinessStatus;  // injected by API, never stored in DB (ADR-007)
  created_at: string;
  updated_at: string;
}

// Matches lib/filter/filterWines.ts FilterState exactly
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

export interface StorageLocation {
  location_id: string;
  location_name: string;
  bottle_count: number;
}
```

---

**components/wine-list/ReadinessBadge.tsx** — Exact badge colors per UX-Mockup §ReadinessStatusBadgeColors:

```
| Status          | Badge Color                           | Text Label    |
| DRINK_NOW       | Gold #FBCA5C bg / Black text          | "DRINK NOW"   |
| APPROACHING_PEAK| Amber #F5A623 bg / Black text         | "APPROACHING" |
| HOLD            | Gray #A8A59B bg / Ink text            | "HOLD"        |
| PAST_WINDOW     | Muted #D0CEC8 bg / Gray text          | "PAST WINDOW" |
| NO_WINDOW_SET   | Paper #F5F5F2 bg / Gray text          | "NO WINDOW"   |
```

All badges: JetBrains Mono UPPERCASE, +1px tracking, 2px border-radius.
WCAG 2.1 AA: color is never the sole differentiator — text label always present.
When `muted=true` (Cellar Empty card per CP-05): apply 40% opacity on the badge.

```typescript
// components/wine-list/ReadinessBadge.tsx
'use client';
import type { ReadinessStatus } from '@/types/wine';

interface ReadinessBadgeProps {
  status: ReadinessStatus;
  muted?: boolean;
}

const BADGE_CONFIG: Record<ReadinessStatus, { bg: string; textColor: string; label: string }> = {
  DRINK_NOW:        { bg: '#FBCA5C', textColor: '#0A0A0A', label: 'DRINK NOW' },
  APPROACHING_PEAK: { bg: '#F5A623', textColor: '#0A0A0A', label: 'APPROACHING' },
  HOLD:             { bg: '#A8A59B', textColor: '#1A1A1A', label: 'HOLD' },
  PAST_WINDOW:      { bg: '#D0CEC8', textColor: '#A8A59B', label: 'PAST WINDOW' },
  NO_WINDOW_SET:    { bg: '#F5F5F2', textColor: '#A8A59B', label: 'NO WINDOW' },
};

export function ReadinessBadge({ status, muted = false }: ReadinessBadgeProps) {
  const config = BADGE_CONFIG[status];
  return (
    <span
      style={{
        backgroundColor: config.bg,
        color: config.textColor,
        opacity: muted ? 0.4 : 1,
        fontFamily: "'JetBrains Mono', monospace",
        fontSize: '0.65rem',
        fontWeight: 500,
        textTransform: 'uppercase',
        letterSpacing: '0.05em',
        padding: '2px 6px',
        borderRadius: '2px',
        display: 'inline-block',
        lineHeight: '1.4',
        whiteSpace: 'nowrap',
      }}
      aria-label={`Readiness: ${config.label}`}
    >
      {config.label}
    </span>
  );
}
```

---

**components/wine-list/QuantityPill.tsx** — Quantity pill showing count or "EMPTY" when qty=0. JetBrains Mono UPPERCASE bold. When `muted=true` (Cellar Empty): gray pill per UX-Mockup.

```typescript
// components/wine-list/QuantityPill.tsx
'use client';

interface QuantityPillProps {
  quantity: number;
  muted?: boolean;
}

export function QuantityPill({ quantity, muted = false }: QuantityPillProps) {
  const isEmpty = quantity === 0;
  const bg = isEmpty || muted ? '#A8A59B' : '#1A1A1A';
  const textColor = '#FAFAF7';

  return (
    <span
      style={{
        backgroundColor: bg,
        color: textColor,
        fontFamily: "'JetBrains Mono', monospace",
        fontSize: '0.7rem',
        fontWeight: 700,
        textTransform: 'uppercase',
        letterSpacing: '0.04em',
        padding: '2px 7px',
        borderRadius: '2px',
        display: 'inline-block',
        lineHeight: '1.4',
        minWidth: '1.8rem',
        textAlign: 'center',
      }}
      aria-label={isEmpty ? 'No bottles in cellar' : `${quantity} bottle${quantity === 1 ? '' : 's'}`}
    >
      {isEmpty ? 'EMPTY' : quantity}
    </span>
  );
}
```

---

**components/wine-list/WineCard.tsx** — Mobile card component per UX-Mockup Screen 01 card anatomy:

```
Row 1: [TYPE BADGE]  [READINESS BADGE]  [★★★]   ← badges + rating
Row 2: Wine Name                        [qty]    ← name + qty pill
Row 3: Producer · Vintage Year                   ← producer · vintage
Row 4: 📍 Storage Location Name                  ← location (CP-01)
```

Cellar Empty cards (qty=0): entire card at 70% opacity; badges at 40% opacity; qty pill shows EMPTY.
Card uses `usa-card` class for USWDS baseline; TechSur overrides via CSS variables (bone bg, ink text, 2px radius).
Storage location truncated at 30 chars + ellipsis.
Tappable — full card is a button, `onClick` navigates to Wine Detail.

```typescript
// components/wine-list/WineCard.tsx
'use client';
import Link from 'next/link';
import type { WineRecord } from '@/types/wine';
import { ReadinessBadge } from './ReadinessBadge';
import { QuantityPill } from './QuantityPill';

interface WineCardProps {
  wine: WineRecord;
}

const TYPE_COLORS: Record<string, string> = {
  RED:       '#6B2D3E',
  WHITE:     '#5A7FA0',
  ROSE:      '#C26E8D',
  SPARKLING: '#8B9E6E',
  DESSERT:   '#B07040',
  FORTIFIED: '#7A5C8A',
};

function TypeBadge({ wineType, muted }: { wineType: string; muted: boolean }) {
  const bg = TYPE_COLORS[wineType] ?? '#888';
  return (
    <span
      style={{
        backgroundColor: bg,
        color: '#FAFAF7',
        opacity: muted ? 0.4 : 1,
        fontFamily: "'JetBrains Mono', monospace",
        fontSize: '0.65rem',
        fontWeight: 500,
        textTransform: 'uppercase',
        letterSpacing: '0.05em',
        padding: '2px 6px',
        borderRadius: '2px',
        display: 'inline-block',
        lineHeight: '1.4',
      }}
    >
      {wineType}
    </span>
  );
}

function StarRating({ rating, scale }: { rating: number | null; scale: string | null }) {
  if (!rating) return null;
  if (scale === 'STARS_5' || !scale) {
    const stars = Math.round(rating);
    return (
      <span
        aria-label={`Rating: ${stars} out of 5 stars`}
        style={{ color: '#B0832A', fontSize: '0.75rem' }}
      >
        {'★'.repeat(stars)}{'☆'.repeat(Math.max(0, 5 - stars))}
      </span>
    );
  }
  return (
    <span
      aria-label={`Rating: ${rating} points`}
      style={{
        fontFamily: "'JetBrains Mono', monospace",
        fontSize: '0.7rem',
        color: '#B0832A',
        fontWeight: 600,
      }}
    >
      {rating}
    </span>
  );
}

export function WineCard({ wine }: WineCardProps) {
  const isEmpty = wine.quantity === 0;
  const cardOpacity = isEmpty ? 0.7 : 1;
  const locationDisplay = wine.storage_location_name
    ? wine.storage_location_name.length > 30
      ? wine.storage_location_name.slice(0, 30) + '…'
      : wine.storage_location_name
    : wine.location_unknown
    ? 'Location Unknown'
    : '—';

  return (
    <Link
      href={`/wines/${wine.wine_id}`}
      style={{
        display: 'block',
        textDecoration: 'none',
        opacity: cardOpacity,
      }}
    >
      <div
        className="usa-card__container"
        style={{
          backgroundColor: 'var(--color-bone, #FAFAF7)',
          borderRadius: '2px',
          border: '1px solid #E8E6E1',
          padding: '12px 14px',
          cursor: 'pointer',
          marginBottom: '8px',
        }}
      >
        {/* Row 1: Type badge | Readiness badge | Rating */}
        <div style={{ display: 'flex', alignItems: 'center', gap: '6px', marginBottom: '6px' }}>
          <TypeBadge wineType={wine.wine_type} muted={isEmpty} />
          <ReadinessBadge status={wine.readiness_status} muted={isEmpty} />
          <span style={{ marginLeft: 'auto' }}>
            <StarRating rating={wine.latest_rating} scale={wine.latest_rating_scale} />
          </span>
        </div>

        {/* Row 2: Wine name | Qty pill */}
        <div style={{ display: 'flex', alignItems: 'baseline', justifyContent: 'space-between', gap: '8px', marginBottom: '4px' }}>
          <span
            style={{
              fontFamily: "'Open Sans', sans-serif",
              fontWeight: 700,
              fontSize: '1rem',
              color: 'var(--color-ink, #1A1A1A)',
              flex: 1,
              minWidth: 0,
              overflow: 'hidden',
              textOverflow: 'ellipsis',
              whiteSpace: 'nowrap',
            }}
          >
            {wine.wine_name}
          </span>
          <QuantityPill quantity={wine.quantity} muted={isEmpty} />
        </div>

        {/* Row 3: Producer · Vintage */}
        <div
          style={{
            fontFamily: "'Open Sans', sans-serif",
            fontSize: '0.85rem',
            color: '#1A1A1A',
            marginBottom: '4px',
          }}
        >
          {wine.producer} · {wine.vintage_year}
        </div>

        {/* Row 4: Storage location (CP-01) */}
        <div
          style={{
            fontFamily: "'Open Sans', sans-serif",
            fontSize: '0.8rem',
            color: 'var(--color-gray-400, #A8A59B)',
          }}
          aria-label={`Storage: ${locationDisplay}`}
        >
          📍 {locationDisplay}
        </div>
      </div>
    </Link>
  );
}
```

---

**components/wine-list/WineTableRow.tsx** — Desktop table row. Shows Name, Producer, Vintage, Type badge, Readiness badge, Qty pill, plus Country and Region at ≥1024px.

```typescript
// components/wine-list/WineTableRow.tsx
'use client';
import Link from 'next/link';
import type { WineRecord } from '@/types/wine';
import { ReadinessBadge } from './ReadinessBadge';
import { QuantityPill } from './QuantityPill';

interface WineTableRowProps {
  wine: WineRecord;
}

export function WineTableRow({ wine }: WineTableRowProps) {
  const isEmpty = wine.quantity === 0;
  return (
    <tr
      style={{
        opacity: isEmpty ? 0.7 : 1,
        backgroundColor: 'var(--color-bone, #FAFAF7)',
        cursor: 'pointer',
      }}
    >
      <td>
        <Link
          href={`/wines/${wine.wine_id}`}
          style={{
            color: 'var(--color-ink, #1A1A1A)',
            textDecoration: 'none',
            fontFamily: "'Open Sans', sans-serif",
            fontWeight: 700,
          }}
        >
          {wine.wine_name}
        </Link>
      </td>
      <td style={{ fontFamily: "'Open Sans', sans-serif", fontSize: '0.9rem' }}>{wine.producer}</td>
      <td style={{ fontFamily: "'JetBrains Mono', monospace", fontSize: '0.85rem' }}>{wine.vintage_year}</td>
      <td>
        <span
          style={{
            fontFamily: "'JetBrains Mono', monospace",
            fontSize: '0.65rem',
            textTransform: 'uppercase',
            letterSpacing: '0.05em',
          }}
        >
          {wine.wine_type}
        </span>
      </td>
      <td><ReadinessBadge status={wine.readiness_status} muted={isEmpty} /></td>
      <td><QuantityPill quantity={wine.quantity} muted={isEmpty} /></td>
      {/* Extra cols visible on desktop: Country, Region */}
      <td className="usa-table__cell--desktop-only" style={{ fontSize: '0.85rem' }}>{wine.country ?? '—'}</td>
      <td className="usa-table__cell--desktop-only" style={{ fontSize: '0.85rem' }}>{wine.region ?? '—'}</td>
    </tr>
  );
}
```

---

**components/wine-list/WineListEmpty.tsx** — Empty state for zero collection and zero-results states.

```typescript
// components/wine-list/WineListEmpty.tsx
'use client';
import Link from 'next/link';

interface WineListEmptyProps {
  type: 'collection' | 'no-results';
  onClearFilters?: () => void;
}

export function WineListEmpty({ type, onClearFilters }: WineListEmptyProps) {
  if (type === 'collection') {
    return (
      <div
        style={{
          textAlign: 'center',
          padding: '64px 24px',
          fontFamily: "'Open Sans', sans-serif",
          color: 'var(--color-gray-400, #A8A59B)',
        }}
        role="status"
        aria-live="polite"
      >
        <p style={{ fontSize: '1.1rem', marginBottom: '24px', color: '#1A1A1A' }}>
          Your cellar is empty. Tap &ldquo;+&rdquo; to add your first wine.
        </p>
        <Link
          href="/wines/add"
          className="usa-button"
          style={{
            backgroundColor: 'var(--color-gold-400, #FBCA5C)',
            color: '#0A0A0A',
            fontFamily: "'Montserrat', sans-serif",
            fontWeight: 700,
            textTransform: 'uppercase',
            letterSpacing: '0.04em',
            borderRadius: '2px',
            padding: '12px 28px',
            textDecoration: 'none',
            display: 'inline-block',
          }}
        >
          ADD WINE
        </Link>
      </div>
    );
  }

  return (
    <div
      style={{
        textAlign: 'center',
        padding: '48px 24px',
        fontFamily: "'Open Sans', sans-serif",
        color: '#1A1A1A',
      }}
      role="status"
      aria-live="polite"
    >
      <p style={{ fontSize: '1rem', marginBottom: '16px' }}>
        No wines match your search. Try a different term or clear filters.
      </p>
      {onClearFilters && (
        <button
          onClick={onClearFilters}
          className="usa-button usa-button--outline"
          style={{ borderRadius: '2px', fontFamily: "'Montserrat', sans-serif", fontWeight: 700, textTransform: 'uppercase' }}
        >
          CLEAR FILTERS
        </button>
      )}
    </div>
  );
}
```
  </action>
  <verify>grep -n 'export.*WineRecord\|export.*ReadinessStatus\|export.*FilterState\|export.*WineSortKey' types/wine.ts && grep -n 'export function ReadinessBadge' components/wine-list/ReadinessBadge.tsx && grep -n 'DRINK_NOW\|APPROACHING_PEAK\|HOLD\|PAST_WINDOW\|NO_WINDOW_SET' components/wine-list/ReadinessBadge.tsx && grep -n 'export function QuantityPill' components/wine-list/QuantityPill.tsx && grep -n 'EMPTY' components/wine-list/QuantityPill.tsx && grep -n 'export function WineCard' components/wine-list/WineCard.tsx && grep -n 'ReadinessBadge\|QuantityPill' components/wine-list/WineCard.tsx && echo CONTRACT_OK</verify>
  <done>
- types/wine.ts exports WineRecord (all TechArch column names), ReadinessStatus (5 values), FilterState, WineSortKey, StorageLocation
- ReadinessBadge.tsx: DRINK_NOW=#FBCA5C/Black, APPROACHING_PEAK=#F5A623/Black, HOLD=#A8A59B/Ink, PAST_WINDOW=#D0CEC8/Gray, NO_WINDOW_SET=#F5F5F2/Gray — exact from UX-Mockup; text label always present (WCAG 2.1 AA)
- ReadinessBadge accepts muted prop (40% opacity) for Cellar Empty cards
- QuantityPill shows count or "EMPTY" in JetBrains Mono UPPERCASE; accepts muted prop
- WineCard renders all 4 rows per UX-Mockup anatomy (type badge, readiness badge, rating | name + qty | producer + vintage | location CP-01); Cellar Empty at 70% opacity; location truncated at 30 chars
- WineTableRow renders desktop table columns including Country + Region extra cols
- WineListEmpty handles both 'collection' (no wines) and 'no-results' (search/filter) states with correct messages from UX spec
  </done>
</task>

<feature_dependencies>
Implements: F0: Wine Inventory CRUD (WineCard/WineTableRow — list display), F1: Quantity & Bottle Status Tracking (QuantityPill — EMPTY badge when qty=0), F5: Drinking Window Management (ReadinessBadge — 5 status colors and labels)
Depends on: types/wine.ts (created in this task), lib/business/readiness.ts (calculateReadinessStatus from plan 02)
Enables: Task 2 (WineListPage, SearchBar, FilterPanel, hooks all depend on these components)
</feature_dependencies>

<task type="auto">
  <name>Task 2: SearchBar, FilterPanel, FilterChip, SortControl, hooks, and WineListPage assembly</name>
  <files>
    components/wine-list/SearchBar.tsx
    components/wine-list/FilterPanel.tsx
    components/wine-list/FilterChip.tsx
    components/wine-list/SortControl.tsx
    hooks/useWineList.ts
    hooks/useFilterPersistence.ts
    app/cellar/page.tsx
    components/wine-list/WineListPage.tsx
  </files>
  <action>
Create the remaining 8 files for the complete Wine List feature.

---

**hooks/useFilterPersistence.ts** — Session-persistent filter state (CP-02). Persists FilterState and WineSortKey to sessionStorage so filters survive navigation within the session but reset on app close.

```typescript
// hooks/useFilterPersistence.ts
'use client';
import { useState, useEffect, useCallback } from 'react';
import type { FilterState, WineSortKey } from '@/types/wine';

const FILTER_STORAGE_KEY = 'wine_list_filters';
const SORT_STORAGE_KEY = 'wine_list_sort';
const EMPTY_FILTERS: FilterState = {};

function loadFromSession<T>(key: string, fallback: T): T {
  if (typeof window === 'undefined') return fallback;
  try {
    const raw = sessionStorage.getItem(key);
    return raw ? JSON.parse(raw) : fallback;
  } catch {
    return fallback;
  }
}

function saveToSession(key: string, value: unknown) {
  if (typeof window === 'undefined') return;
  try {
    sessionStorage.setItem(key, JSON.stringify(value));
  } catch {
    // Storage full or private mode — fail silently
  }
}

export function useFilterPersistence() {
  const [filters, setFiltersState] = useState<FilterState>(() =>
    loadFromSession(FILTER_STORAGE_KEY, EMPTY_FILTERS)
  );
  const [sortKey, setSortKeyState] = useState<WineSortKey>(() =>
    loadFromSession(SORT_STORAGE_KEY, 'created_at_desc' as WineSortKey)
  );

  const setFilters = useCallback((f: FilterState) => {
    setFiltersState(f);
    saveToSession(FILTER_STORAGE_KEY, f);
  }, []);

  const setSortKey = useCallback((k: WineSortKey) => {
    setSortKeyState(k);
    saveToSession(SORT_STORAGE_KEY, k);
  }, []);

  const clearAllFilters = useCallback(() => {
    setFiltersState(EMPTY_FILTERS);
    saveToSession(FILTER_STORAGE_KEY, EMPTY_FILTERS);
  }, []);

  return { filters, setFilters, sortKey, setSortKey, clearAllFilters };
}
```

---

**hooks/useWineList.ts** — Fetches all wines once on mount, maintains Fuse.js index, applies filterWines + sortWines, exposes reactive state. Auto-default sort to drink_window_end_asc when readiness=DRINK_NOW filter is active and no explicit sort override (US-3.3).

```typescript
// hooks/useWineList.ts
'use client';
import { useState, useEffect, useMemo, useCallback, useRef } from 'react';
import type { WineRecord, WineSortKey, FilterState } from '@/types/wine';
import { filterWines } from '@/lib/filter/filterWines';
import { sortWines } from '@/lib/filter/sortWines';
import { useFilterPersistence } from './useFilterPersistence';

const DEBOUNCE_MS = 100;

export function useWineList() {
  const [allWines, setAllWines] = useState<WineRecord[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [searchQuery, setSearchQueryRaw] = useState('');
  const [debouncedSearch, setDebouncedSearch] = useState('');
  const debounceTimer = useRef<ReturnType<typeof setTimeout> | null>(null);
  const { filters, setFilters, sortKey, setSortKey, clearAllFilters } = useFilterPersistence();
  const [explicitSortSet, setExplicitSortSet] = useState(false);

  // Fetch all wines on mount (client-side; Fuse.js filters locally)
  useEffect(() => {
    setIsLoading(true);
    fetch('/api/v1/wines')
      .then(r => r.json())
      .then(json => {
        setAllWines(json.data ?? []);
        setIsLoading(false);
      })
      .catch(() => {
        setError('Unable to load wines. Pull to refresh or try again.');
        setIsLoading(false);
      });
  }, []);

  // 100ms debounce on search input (US-3.1)
  const setSearchQuery = useCallback((q: string) => {
    setSearchQueryRaw(q);
    if (debounceTimer.current) clearTimeout(debounceTimer.current);
    debounceTimer.current = setTimeout(() => setDebouncedSearch(q), DEBOUNCE_MS);
  }, []);

  // Effective sort key: auto-default to drink_window_end_asc when Drink Now filter active (US-3.3)
  const effectiveSortKey: WineSortKey = useMemo(() => {
    if (!explicitSortSet && filters.readiness?.includes('DRINK_NOW') && filters.readiness.length === 1) {
      return 'drink_window_end_asc';
    }
    return sortKey;
  }, [sortKey, filters.readiness, explicitSortSet]);

  const setSortKeyExplicit = useCallback((k: WineSortKey) => {
    setSortKey(k);
    setExplicitSortSet(true);
  }, [setSortKey]);

  const currentYear = useMemo(() => new Date().getFullYear(), []);

  // Apply filter + sort (pure functions from lib/filter)
  const filteredWines = useMemo(() => {
    const filtered = filterWines(allWines, filters, debouncedSearch, currentYear);
    return sortWines(filtered, effectiveSortKey);
  }, [allWines, filters, debouncedSearch, effectiveSortKey, currentYear]);

  return {
    wines: allWines,
    filteredWines,
    isLoading,
    error,
    searchQuery,
    setSearchQuery,
    filters,
    setFilters,
    sortKey: effectiveSortKey,
    setSortKey: setSortKeyExplicit,
    clearAllFilters,
    totalCount: allWines.length,
    filteredCount: filteredWines.length,
  };
}
```

---

**components/wine-list/SearchBar.tsx** — `usa-search` component, always visible, with × clear button (US-3.1). Passes query up via onSearch callback.

```typescript
// components/wine-list/SearchBar.tsx
'use client';

interface SearchBarProps {
  value: string;
  onChange: (q: string) => void;
}

export function SearchBar({ value, onChange }: SearchBarProps) {
  return (
    <div
      className="usa-search usa-search--small"
      style={{
        display: 'flex',
        alignItems: 'center',
        backgroundColor: '#FFFFFF',
        border: '1px solid #A8A59B',
        borderRadius: '2px',
        padding: '4px 8px',
        gap: '8px',
      }}
      role="search"
    >
      <span aria-hidden="true" style={{ color: '#A8A59B', fontSize: '1rem' }}>🔍</span>
      <input
        type="search"
        className="usa-input"
        placeholder="Search wines…"
        value={value}
        onChange={e => onChange(e.target.value)}
        aria-label="Search wines"
        style={{
          flex: 1,
          border: 'none',
          outline: 'none',
          fontFamily: "'Open Sans', sans-serif",
          fontSize: '0.95rem',
          color: '#1A1A1A',
          backgroundColor: 'transparent',
          padding: '4px 0',
        }}
      />
      {value && (
        <button
          type="button"
          onClick={() => onChange('')}
          aria-label="Clear search"
          style={{
            background: 'none',
            border: 'none',
            cursor: 'pointer',
            color: '#A8A59B',
            fontSize: '1rem',
            padding: '2px',
            lineHeight: 1,
          }}
        >
          ×
        </button>
      )}
    </div>
  );
}
```

---

**components/wine-list/FilterChip.tsx** — Single dismissible filter chip. JetBrains Mono UPPERCASE. × button removes only this filter (CP-02).

```typescript
// components/wine-list/FilterChip.tsx
'use client';

interface FilterChipProps {
  label: string;
  onRemove: () => void;
}

export function FilterChip({ label, onRemove }: FilterChipProps) {
  return (
    <span
      style={{
        display: 'inline-flex',
        alignItems: 'center',
        gap: '4px',
        backgroundColor: '#1A1A1A',
        color: '#FAFAF7',
        fontFamily: "'JetBrains Mono', monospace",
        fontSize: '0.65rem',
        textTransform: 'uppercase',
        letterSpacing: '0.04em',
        padding: '4px 8px 4px 10px',
        borderRadius: '2px',
      }}
    >
      {label}
      <button
        type="button"
        onClick={onRemove}
        aria-label={`Remove filter: ${label}`}
        style={{
          background: 'none',
          border: 'none',
          cursor: 'pointer',
          color: '#FAFAF7',
          fontSize: '0.9rem',
          lineHeight: 1,
          padding: '0 2px',
          marginLeft: '2px',
        }}
      >
        ×
      </button>
    </span>
  );
}
```

---

**components/wine-list/SortControl.tsx** — `usa-select` sort dropdown. Shows all WineSortKey options. Gold 600 label on Bone background per design system.

```typescript
// components/wine-list/SortControl.tsx
'use client';
import type { WineSortKey } from '@/types/wine';

interface SortControlProps {
  value: WineSortKey;
  onChange: (key: WineSortKey) => void;
}

const SORT_OPTIONS: { value: WineSortKey; label: string }[] = [
  { value: 'created_at_desc', label: 'Date Added: Newest' },
  { value: 'created_at_asc', label: 'Date Added: Oldest' },
  { value: 'wine_name_asc', label: 'Name: A–Z' },
  { value: 'wine_name_desc', label: 'Name: Z–A' },
  { value: 'vintage_year_desc', label: 'Vintage: Newest' },
  { value: 'vintage_year_asc', label: 'Vintage: Oldest' },
  { value: 'quantity_desc', label: 'Quantity: High–Low' },
  { value: 'quantity_asc', label: 'Quantity: Low–High' },
  { value: 'rating_desc', label: 'Rating: Highest' },
  { value: 'rating_asc', label: 'Rating: Lowest' },
  { value: 'drink_window_end_asc', label: 'Drink By: Soonest' },
  { value: 'drink_window_end_desc', label: 'Drink By: Latest' },
];

export function SortControl({ value, onChange }: SortControlProps) {
  return (
    <div style={{ display: 'flex', alignItems: 'center', gap: '6px' }}>
      <label
        htmlFor="wine-sort"
        style={{
          fontFamily: "'JetBrains Mono', monospace",
          fontSize: '0.7rem',
          textTransform: 'uppercase',
          letterSpacing: '0.04em',
          color: '#B0832A',
          whiteSpace: 'nowrap',
        }}
      >
        Sort:
      </label>
      <select
        id="wine-sort"
        className="usa-select"
        value={value}
        onChange={e => onChange(e.target.value as WineSortKey)}
        style={{
          fontFamily: "'Open Sans', sans-serif",
          fontSize: '0.85rem',
          borderRadius: '2px',
          border: '1px solid #A8A59B',
          backgroundColor: '#FAFAF7',
          color: '#1A1A1A',
          padding: '4px 8px',
          cursor: 'pointer',
        }}
      >
        {SORT_OPTIONS.map(opt => (
          <option key={opt.value} value={opt.value}>{opt.label}</option>
        ))}
      </select>
    </div>
  );
}
```

---

**components/wine-list/FilterPanel.tsx** — Bottom drawer on mobile (usa-modal pattern), sidebar on desktop. Supports all F03 filter dimensions. Filters apply immediately (no Apply button). Location dropdown populated from GET /api/v1/locations.

```typescript
// components/wine-list/FilterPanel.tsx
'use client';
import { useState, useEffect } from 'react';
import type { FilterState, WineType, ReadinessStatus, StorageLocation } from '@/types/wine';

interface FilterPanelProps {
  filters: FilterState;
  onFiltersChange: (f: FilterState) => void;
  onClose: () => void;
  isOpen: boolean;
}

const WINE_TYPES: WineType[] = ['RED', 'WHITE', 'ROSE', 'SPARKLING', 'DESSERT', 'FORTIFIED'];
const READINESS_OPTIONS: ReadinessStatus[] = ['DRINK_NOW', 'APPROACHING_PEAK', 'HOLD', 'PAST_WINDOW', 'NO_WINDOW_SET'];
const READINESS_LABELS: Record<ReadinessStatus, string> = {
  DRINK_NOW: 'Drink Now',
  APPROACHING_PEAK: 'Approaching Peak',
  HOLD: 'Hold',
  PAST_WINDOW: 'Past Window',
  NO_WINDOW_SET: 'No Window Set',
};

export function FilterPanel({ filters, onFiltersChange, onClose, isOpen }: FilterPanelProps) {
  const [locations, setLocations] = useState<StorageLocation[]>([]);
  const [vintageError, setVintageError] = useState('');
  const [ratingError, setRatingError] = useState('');

  // Load locations for dropdown (F02.5)
  useEffect(() => {
    if (isOpen) {
      fetch('/api/v1/locations')
        .then(r => r.json())
        .then(json => setLocations(json.data ?? []))
        .catch(() => {/* silent fail */});
    }
  }, [isOpen]);

  function toggleMulti<T>(current: T[] | undefined, value: T): T[] {
    const arr = current ?? [];
    return arr.includes(value) ? arr.filter(x => x !== value) : [...arr, value];
  }

  function update(patch: Partial<FilterState>) {
    onFiltersChange({ ...filters, ...patch });
  }

  function handleVintageFrom(v: string) {
    const num = v ? Number(v) : undefined;
    const to = filters.vintage_to;
    if (num && to && num > to) {
      setVintageError('Start year must be before or equal to end year.');
    } else {
      setVintageError('');
    }
    update({ vintage_from: num });
  }

  function handleVintageTo(v: string) {
    const num = v ? Number(v) : undefined;
    const from = filters.vintage_from;
    if (from && num && from > num) {
      setVintageError('Start year must be before or equal to end year.');
    } else {
      setVintageError('');
    }
    update({ vintage_to: num });
  }

  function handleRatingMin(v: string) {
    const num = v ? Number(v) : undefined;
    const max = filters.rating_max;
    if (num && max && num > max) {
      setRatingError('Min rating must be less than or equal to max rating.');
    } else {
      setRatingError('');
    }
    update({ rating_min: num });
  }

  function handleRatingMax(v: string) {
    const num = v ? Number(v) : undefined;
    const min = filters.rating_min;
    if (min && num && min > num) {
      setRatingError('Min rating must be less than or equal to max rating.');
    } else {
      setRatingError('');
    }
    update({ rating_max: num });
  }

  const panelStyle: React.CSSProperties = {
    backgroundColor: 'var(--color-paper, #F5F5F2)',
    padding: '20px',
    overflowY: 'auto',
  };

  // Mobile: bottom drawer; Desktop: left sidebar (CSS media query via className)
  return (
    <>
      {/* Mobile backdrop */}
      {isOpen && (
        <div
          className="filter-panel__backdrop"
          onClick={onClose}
          aria-hidden="true"
          style={{
            position: 'fixed', inset: 0, backgroundColor: 'rgba(0,0,0,0.4)',
            zIndex: 100,
          }}
        />
      )}

      <aside
        className={`filter-panel ${isOpen ? 'filter-panel--open' : ''}`}
        aria-label="Filter panel"
        aria-hidden={!isOpen}
        style={{
          ...panelStyle,
          position: 'fixed', bottom: 0, left: 0, right: 0,
          zIndex: 101,
          borderRadius: '8px 8px 0 0',
          maxHeight: '80vh',
          transform: isOpen ? 'translateY(0)' : 'translateY(100%)',
          transition: 'transform 0.25s ease',
        }}
      >
        <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '16px' }}>
          <h2
            style={{
              fontFamily: "'Montserrat', sans-serif",
              fontWeight: 900,
              fontSize: '1rem',
              color: '#1A1A1A',
              margin: 0,
            }}
          >
            Filters
          </h2>
          <button
            onClick={onClose}
            aria-label="Close filter panel"
            style={{ background: 'none', border: 'none', cursor: 'pointer', fontSize: '1.4rem', color: '#1A1A1A' }}
          >
            ×
          </button>
        </div>

        {/* Wine Type — multi-select checkboxes */}
        <fieldset className="usa-fieldset" style={{ border: 'none', margin: '0 0 16px 0', padding: 0 }}>
          <legend
            style={{
              fontFamily: "'JetBrains Mono', monospace",
              fontSize: '0.65rem',
              textTransform: 'uppercase',
              letterSpacing: '0.06em',
              color: '#B0832A',
              marginBottom: '8px',
            }}
          >
            Wine Type
          </legend>
          <div style={{ display: 'flex', flexWrap: 'wrap', gap: '6px' }}>
            {WINE_TYPES.map(type => {
              const checked = (filters.wine_type ?? []).includes(type);
              return (
                <label
                  key={type}
                  style={{
                    display: 'inline-flex',
                    alignItems: 'center',
                    gap: '4px',
                    cursor: 'pointer',
                    fontFamily: "'JetBrains Mono', monospace",
                    fontSize: '0.7rem',
                    textTransform: 'uppercase',
                    color: checked ? '#FAFAF7' : '#1A1A1A',
                    backgroundColor: checked ? '#1A1A1A' : '#E8E6E1',
                    padding: '4px 10px',
                    borderRadius: '2px',
                    userSelect: 'none',
                  }}
                >
                  <input
                    type="checkbox"
                    className="usa-checkbox__input usa-sr-only"
                    checked={checked}
                    onChange={() => update({ wine_type: toggleMulti(filters.wine_type, type) })}
                  />
                  {type}
                </label>
              );
            })}
          </div>
        </fieldset>

        {/* Readiness — multi-select */}
        <fieldset className="usa-fieldset" style={{ border: 'none', margin: '0 0 16px 0', padding: 0 }}>
          <legend
            style={{
              fontFamily: "'JetBrains Mono', monospace",
              fontSize: '0.65rem',
              textTransform: 'uppercase',
              letterSpacing: '0.06em',
              color: '#B0832A',
              marginBottom: '8px',
            }}
          >
            Readiness
          </legend>
          {READINESS_OPTIONS.map(r => {
            const checked = (filters.readiness ?? []).includes(r);
            return (
              <div key={r} className="usa-checkbox" style={{ marginBottom: '6px' }}>
                <input
                  className="usa-checkbox__input"
                  type="checkbox"
                  id={`readiness-${r}`}
                  checked={checked}
                  onChange={() => update({ readiness: toggleMulti(filters.readiness, r) })}
                />
                <label
                  className="usa-checkbox__label"
                  htmlFor={`readiness-${r}`}
                  style={{ fontFamily: "'Open Sans', sans-serif", fontSize: '0.9rem' }}
                >
                  {READINESS_LABELS[r]}
                </label>
              </div>
            );
          })}
        </fieldset>

        {/* Vintage Range */}
        <div style={{ marginBottom: '16px' }}>
          <p
            style={{
              fontFamily: "'JetBrains Mono', monospace",
              fontSize: '0.65rem',
              textTransform: 'uppercase',
              letterSpacing: '0.06em',
              color: '#B0832A',
              margin: '0 0 8px 0',
            }}
          >
            Vintage Range
          </p>
          <div style={{ display: 'flex', gap: '8px', alignItems: 'center' }}>
            <input
              type="number"
              className="usa-input"
              placeholder="From"
              min={1900}
              max={2200}
              value={filters.vintage_from ?? ''}
              onChange={e => handleVintageFrom(e.target.value)}
              aria-label="Vintage from year"
              style={{ width: '90px', borderRadius: '2px', fontSize: '0.9rem' }}
            />
            <span style={{ color: '#A8A59B' }}>–</span>
            <input
              type="number"
              className="usa-input"
              placeholder="To"
              min={1900}
              max={2200}
              value={filters.vintage_to ?? ''}
              onChange={e => handleVintageTo(e.target.value)}
              aria-label="Vintage to year"
              style={{ width: '90px', borderRadius: '2px', fontSize: '0.9rem' }}
            />
          </div>
          {vintageError && (
            <p className="usa-error-message" style={{ fontSize: '0.8rem', marginTop: '4px' }}>{vintageError}</p>
          )}
        </div>

        {/* Grape Variety */}
        <div style={{ marginBottom: '16px' }}>
          <label
            htmlFor="filter-grape"
            style={{
              fontFamily: "'JetBrains Mono', monospace",
              fontSize: '0.65rem',
              textTransform: 'uppercase',
              letterSpacing: '0.06em',
              color: '#B0832A',
              display: 'block',
              marginBottom: '6px',
            }}
          >
            Grape Variety
          </label>
          <input
            id="filter-grape"
            type="text"
            className="usa-input"
            placeholder="e.g., Cabernet Sauvignon"
            value={filters.grape_variety ?? ''}
            onChange={e => update({ grape_variety: e.target.value || undefined })}
            style={{ borderRadius: '2px', fontSize: '0.9rem' }}
          />
        </div>

        {/* Storage Location */}
        <div style={{ marginBottom: '16px' }}>
          <label
            htmlFor="filter-location"
            style={{
              fontFamily: "'JetBrains Mono', monospace",
              fontSize: '0.65rem',
              textTransform: 'uppercase',
              letterSpacing: '0.06em',
              color: '#B0832A',
              display: 'block',
              marginBottom: '6px',
            }}
          >
            Storage Location
          </label>
          <select
            id="filter-location"
            className="usa-select"
            value={filters.storage_location_id ?? ''}
            onChange={e => update({ storage_location_id: e.target.value || undefined })}
            style={{ borderRadius: '2px', fontSize: '0.9rem' }}
          >
            <option value="">All locations</option>
            <option value="UNKNOWN">Location Unknown</option>
            {locations.map(loc => (
              <option key={loc.location_id} value={loc.location_id}>
                {loc.location_name}
              </option>
            ))}
          </select>
        </div>

        {/* Rating Range */}
        <div style={{ marginBottom: '20px' }}>
          <p
            style={{
              fontFamily: "'JetBrains Mono', monospace",
              fontSize: '0.65rem',
              textTransform: 'uppercase',
              letterSpacing: '0.06em',
              color: '#B0832A',
              margin: '0 0 8px 0',
            }}
          >
            Rating Range
          </p>
          <div style={{ display: 'flex', gap: '8px', alignItems: 'center' }}>
            <input
              type="number"
              className="usa-input"
              placeholder="Min"
              min={1}
              max={100}
              value={filters.rating_min ?? ''}
              onChange={e => handleRatingMin(e.target.value)}
              aria-label="Minimum rating"
              style={{ width: '80px', borderRadius: '2px', fontSize: '0.9rem' }}
            />
            <span style={{ color: '#A8A59B' }}>–</span>
            <input
              type="number"
              className="usa-input"
              placeholder="Max"
              min={1}
              max={100}
              value={filters.rating_max ?? ''}
              onChange={e => handleRatingMax(e.target.value)}
              aria-label="Maximum rating"
              style={{ width: '80px', borderRadius: '2px', fontSize: '0.9rem' }}
            />
          </div>
          {ratingError && (
            <p className="usa-error-message" style={{ fontSize: '0.8rem', marginTop: '4px' }}>{ratingError}</p>
          )}
        </div>
      </aside>
    </>
  );
}
```

---

**components/wine-list/WineListPage.tsx** — Main collection view assembly. Orchestrates all subcomponents, exposes active filter chips, result count, and handles mobile/desktop layout split.

```typescript
// components/wine-list/WineListPage.tsx
'use client';
import { useState } from 'react';
import Link from 'next/link';
import { useWineList } from '@/hooks/useWineList';
import { WineCard } from './WineCard';
import { WineTableRow } from './WineTableRow';
import { SearchBar } from './SearchBar';
import { FilterPanel } from './FilterPanel';
import { FilterChip } from './FilterChip';
import { SortControl } from './SortControl';
import { WineListEmpty } from './WineListEmpty';
import type { FilterState } from '@/types/wine';

function buildActiveChips(filters: FilterState) {
  const chips: { label: string; key: keyof FilterState }[] = [];
  if (filters.wine_type?.length) chips.push({ label: `Type: ${filters.wine_type.join(', ')}`, key: 'wine_type' });
  if (filters.readiness?.length) chips.push({ label: `Readiness: ${filters.readiness.join(', ')}`, key: 'readiness' });
  if (filters.vintage_from || filters.vintage_to) {
    const label = `Vintage: ${filters.vintage_from ?? ''}–${filters.vintage_to ?? ''}`;
    chips.push({ label, key: 'vintage_from' });
  }
  if (filters.grape_variety) chips.push({ label: `Grape: ${filters.grape_variety}`, key: 'grape_variety' });
  if (filters.storage_location_id) chips.push({ label: `Location: ${filters.storage_location_id === 'UNKNOWN' ? 'Unknown' : 'Selected'}`, key: 'storage_location_id' });
  if (filters.rating_min || filters.rating_max) chips.push({ label: `Rating: ${filters.rating_min ?? ''}–${filters.rating_max ?? ''}`, key: 'rating_min' });
  if (filters.producer) chips.push({ label: `Producer: ${filters.producer}`, key: 'producer' });
  return chips;
}

function removeChipFilter(filters: FilterState, key: keyof FilterState): FilterState {
  const next = { ...filters };
  // Remove related fields for compound filters
  if (key === 'vintage_from') { delete next.vintage_from; delete next.vintage_to; }
  else if (key === 'rating_min') { delete next.rating_min; delete next.rating_max; }
  else delete (next as Record<string, unknown>)[key];
  return next;
}

export function WineListPage() {
  const {
    wines, filteredWines, isLoading, error,
    searchQuery, setSearchQuery,
    filters, setFilters,
    sortKey, setSortKey,
    clearAllFilters, totalCount, filteredCount,
  } = useWineList();

  const [filterPanelOpen, setFilterPanelOpen] = useState(false);
  const activeChips = buildActiveChips(filters);
  const hasActiveFilters = activeChips.length > 0;

  if (isLoading) {
    return (
      <div style={{ padding: '32px 16px', textAlign: 'center', color: '#A8A59B', fontFamily: "'Open Sans', sans-serif" }}>
        Loading your cellar…
      </div>
    );
  }

  if (error) {
    return (
      <div className="usa-alert usa-alert--error" role="alert" style={{ margin: '16px' }}>
        <div className="usa-alert__body">{error}</div>
      </div>
    );
  }

  if (wines.length === 0) {
    return <WineListEmpty type="collection" />;
  }

  return (
    <div style={{ backgroundColor: 'var(--color-bone, #FAFAF7)', minHeight: '100vh' }}>
      {/* Page header */}
      <div
        style={{
          backgroundColor: '#0A0A0A',
          padding: '12px 16px',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'space-between',
        }}
      >
        <h1
          style={{
            fontFamily: "'Montserrat', sans-serif",
            fontWeight: 900,
            fontSize: '1.25rem',
            color: '#FAFAF7',
            margin: 0,
          }}
        >
          My Cellar
        </h1>
        <Link
          href="/wines/add"
          className="usa-button"
          style={{
            backgroundColor: '#FBCA5C',
            color: '#0A0A0A',
            fontFamily: "'Montserrat', sans-serif",
            fontWeight: 700,
            textTransform: 'uppercase',
            fontSize: '0.8rem',
            letterSpacing: '0.04em',
            borderRadius: '2px',
            padding: '8px 16px',
            textDecoration: 'none',
          }}
        >
          + Add
        </Link>
      </div>

      {/* Search bar — always visible */}
      <div style={{ padding: '12px 16px 0' }}>
        <SearchBar value={searchQuery} onChange={setSearchQuery} />
      </div>

      {/* Filter + Sort controls row */}
      <div
        style={{
          padding: '10px 16px',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'space-between',
          gap: '8px',
        }}
      >
        <button
          className="usa-button usa-button--outline"
          onClick={() => setFilterPanelOpen(true)}
          aria-expanded={filterPanelOpen}
          aria-controls="filter-panel"
          style={{
            borderRadius: '2px',
            fontFamily: "'Montserrat', sans-serif",
            fontWeight: 700,
            textTransform: 'uppercase',
            fontSize: '0.8rem',
            letterSpacing: '0.04em',
            padding: '8px 14px',
            border: '1.5px solid #1A1A1A',
            color: '#1A1A1A',
            backgroundColor: 'transparent',
            cursor: 'pointer',
            display: 'flex',
            alignItems: 'center',
            gap: '6px',
          }}
        >
          ⚗ Filter {hasActiveFilters && `(${activeChips.length})`}
        </button>
        <SortControl value={sortKey} onChange={setSortKey} />
      </div>

      {/* Active filter chips (CP-02) */}
      {hasActiveFilters && (
        <div
          style={{
            padding: '0 16px 8px',
            display: 'flex',
            flexWrap: 'wrap',
            gap: '6px',
            alignItems: 'center',
          }}
        >
          {activeChips.map(chip => (
            <FilterChip
              key={chip.key}
              label={chip.label}
              onRemove={() => setFilters(removeChipFilter(filters, chip.key))}
            />
          ))}
          <button
            onClick={clearAllFilters}
            style={{
              background: 'none',
              border: 'none',
              cursor: 'pointer',
              color: '#B0832A',
              fontFamily: "'Open Sans', sans-serif",
              fontSize: '0.85rem',
              textDecoration: 'underline',
              padding: '2px 4px',
            }}
          >
            Clear all
          </button>
        </div>
      )}

      {/* Result count — JetBrains Mono UPPERCASE (UX-Mockup spec) */}
      <div
        style={{
          padding: '4px 16px 8px',
          fontFamily: "'JetBrains Mono', monospace",
          fontSize: '0.65rem',
          textTransform: 'uppercase',
          letterSpacing: '0.06em',
          color: '#A8A59B',
        }}
        aria-live="polite"
        aria-atomic="true"
      >
        {searchQuery || hasActiveFilters
          ? `Showing ${filteredCount} of ${totalCount} wines`
          : `${totalCount} wine${totalCount === 1 ? '' : 's'}`}
      </div>

      {/* Wine list — mobile cards */}
      <div className="wine-list__mobile" style={{ padding: '0 16px 80px' }}>
        {filteredWines.length === 0 ? (
          <WineListEmpty type="no-results" onClearFilters={clearAllFilters} />
        ) : (
          filteredWines.map(wine => <WineCard key={wine.wine_id} wine={wine} />)
        )}
      </div>

      {/* Desktop table (hidden on mobile via CSS) */}
      <div className="wine-list__desktop" style={{ display: 'none', padding: '0 24px' }}>
        <table className="usa-table usa-table--borderless usa-table--striped" style={{ width: '100%' }}>
          <thead>
            <tr style={{ fontFamily: "'JetBrains Mono', monospace", fontSize: '0.65rem', textTransform: 'uppercase', letterSpacing: '0.05em' }}>
              <th scope="col">Name</th>
              <th scope="col">Producer</th>
              <th scope="col">Vintage</th>
              <th scope="col">Type</th>
              <th scope="col">Status</th>
              <th scope="col">Qty</th>
              <th scope="col" className="usa-table__cell--desktop-only">Country</th>
              <th scope="col" className="usa-table__cell--desktop-only">Region</th>
            </tr>
          </thead>
          <tbody>
            {filteredWines.length === 0 ? (
              <tr>
                <td colSpan={8} style={{ textAlign: 'center', padding: '32px', color: '#A8A59B' }}>
                  No wines match your search.
                </td>
              </tr>
            ) : (
              filteredWines.map(wine => <WineTableRow key={wine.wine_id} wine={wine} />)
            )}
          </tbody>
        </table>
      </div>

      {/* Filter panel */}
      <FilterPanel
        filters={filters}
        onFiltersChange={setFilters}
        onClose={() => setFilterPanelOpen(false)}
        isOpen={filterPanelOpen}
      />
    </div>
  );
}
```

Note: Add this CSS to globals.css or the app layout (created in plan 05 / nav shell plan):
```css
@media (min-width: 1024px) {
  .wine-list__mobile { display: none !important; }
  .wine-list__desktop { display: block !important; }
  .usa-table__cell--desktop-only { display: table-cell; }
}
@media (max-width: 1023px) {
  .usa-table__cell--desktop-only { display: none; }
  /* Filter panel: position as sidebar on desktop */
  .filter-panel { position: fixed; left: 0; top: 0; bottom: 0; right: auto; width: 320px; borderRadius: 0; transform: none; max-height: 100vh; }
}
```

---

**app/cellar/page.tsx** — Next.js App Router page (client component wrapper).

```typescript
// app/cellar/page.tsx
import type { Metadata } from 'next';
import { WineListPage } from '@/components/wine-list/WineListPage';

export const metadata: Metadata = {
  title: 'My Cellar — SimpleWineApp',
};

export default function CellarPage() {
  return <WineListPage />;
}
```
  </action>
  <verify>grep -n 'export.*useWineList\|export function useWineList' hooks/useWineList.ts && grep -n 'filterWines\|sortWines' hooks/useWineList.ts && grep -n 'sessionStorage' hooks/useFilterPersistence.ts && grep -n 'export.*SearchBar\|export function SearchBar' components/wine-list/SearchBar.tsx && grep -n 'export.*FilterPanel\|export function FilterPanel' components/wine-list/FilterPanel.tsx && grep -n 'export.*FilterChip\|export function FilterChip' components/wine-list/FilterChip.tsx && grep -n 'export.*SortControl\|export function SortControl' components/wine-list/SortControl.tsx && grep -n 'export.*WineListPage\|export function WineListPage' components/wine-list/WineListPage.tsx && grep -n 'WineListPage' app/cellar/page.tsx && echo CONTRACT_OK</verify>
  <done>
- hooks/useFilterPersistence.ts: loads/saves FilterState + WineSortKey from sessionStorage; filter state survives navigation, resets on app close (CP-02)
- hooks/useWineList.ts: fetches GET /api/v1/wines on mount; applies 100ms debounced search via filterWines (Fuse.js); applies sortWines; auto-defaults sort to drink_window_end_asc when DRINK_NOW filter active and no explicit sort (US-3.3)
- SearchBar: usa-search, always visible, × clear button, 100ms debounce via hook
- FilterPanel: bottom drawer mobile; filters apply live (no Apply button); all F03 dimensions (wine_type multi, readiness multi, vintage range, grape variety, location dropdown, rating range); vintage and rating inline error validation
- FilterChip: dismisses only its own filter (CP-02); "Clear all" link removes all chips without clearing search
- SortControl: usa-select, all 12 WineSortKey options labeled
- WineListPage: result count in JetBrains Mono UPPERCASE; error banner on API failure; mobile cards + desktop table; filter chips with × dismissal above list
- app/cellar/page.tsx: Next.js App Router page rendering WineListPage
  </done>
</task>

<feature_dependencies>
Implements: F0: Wine Inventory CRUD (WineListPage — browse all wines, navigate to detail), F1: Quantity & Bottle Status Tracking (QuantityPill shown on every card, Cellar Empty state), F3: Search & Filter (SearchBar + FilterPanel + FilterChip + SortControl + session persistence CP-02), F5: Drinking Window Management (ReadinessBadge colors, DRINK_NOW auto-sort via useWineList)
Depends on: Task 1 (types/wine.ts, ReadinessBadge, QuantityPill, WineCard, WineTableRow, WineListEmpty), lib/filter/filterWines.ts (plan 04), lib/filter/sortWines.ts (plan 04), GET /api/v1/wines (plan 02), GET /api/v1/locations (plan 03)
Enables: Wave 9 dashboard (WineCard + ReadinessBadge reused in DrinkNowShelf), wave 7 Wine Detail (uses same WineRecord type)
</feature_dependencies>

</tasks>

<verification>
After both tasks complete, run these checks:

```bash
# 1. All files exist
ls types/wine.ts \
   components/wine-list/ReadinessBadge.tsx \
   components/wine-list/QuantityPill.tsx \
   components/wine-list/WineCard.tsx \
   components/wine-list/WineTableRow.tsx \
   components/wine-list/WineListEmpty.tsx \
   components/wine-list/SearchBar.tsx \
   components/wine-list/FilterPanel.tsx \
   components/wine-list/FilterChip.tsx \
   components/wine-list/SortControl.tsx \
   hooks/useWineList.ts \
   hooks/useFilterPersistence.ts \
   components/wine-list/WineListPage.tsx \
   app/cellar/page.tsx

# 2. ReadinessBadge has all 5 status colors from UX-Mockup
grep -n 'FBCA5C\|F5A623\|A8A59B\|D0CEC8\|F5F5F2' components/wine-list/ReadinessBadge.tsx

# 3. QuantityPill shows EMPTY when qty=0
grep -n 'EMPTY' components/wine-list/QuantityPill.tsx

# 4. WineCard includes location (CP-01)
grep -n 'storage_location_name\|location_unknown' components/wine-list/WineCard.tsx

# 5. FilterPanel has all required filter dimensions
grep -n 'wine_type\|readiness\|vintage\|grape_variety\|storage_location_id\|rating' components/wine-list/FilterPanel.tsx

# 6. Filter persistence uses sessionStorage (CP-02)
grep -n 'sessionStorage' hooks/useFilterPersistence.ts

# 7. useWineList imports filterWines and sortWines from lib/filter
grep -n 'filterWines\|sortWines' hooks/useWineList.ts

# 8. Debounce is 100ms (US-3.1)
grep -n '100\|DEBOUNCE' hooks/useWineList.ts

# 9. Auto-sort to drink_window_end_asc for DRINK_NOW filter (US-3.3)
grep -n 'drink_window_end_asc\|DRINK_NOW' hooks/useWineList.ts

# 10. TypeScript check
npx tsc --noEmit 2>&1 | head -30 || true
```
</verification>

<success_criteria>
- 14 files created and all exports present
- ReadinessBadge: exact colors DRINK_NOW=#FBCA5C, APPROACHING_PEAK=#F5A623, HOLD=#A8A59B, PAST_WINDOW=#D0CEC8, NO_WINDOW_SET=#F5F5F2 — always with text label (WCAG 2.1 AA)
- QuantityPill: shows numeric count or "EMPTY" in JetBrains Mono UPPERCASE
- WineCard: all 4 rows from UX-Mockup anatomy; Cellar Empty at 70% opacity; badges at 40% opacity; location CP-01 on every card
- SearchBar: usa-search, always visible, × clear button, 100ms debounce
- FilterPanel: all F03 filter dimensions (wine type multi-select, readiness multi-select, vintage range, grape variety, location dropdown, rating range); live filters (no Apply button)
- FilterChip: individual × dismissal; "Clear all" removes all chips; never clears search bar
- SortControl: all 12 WineSortKey options including drink_window_end_asc/desc
- Filter state persists in sessionStorage (CP-02); resets on app close
- useWineList: fetches GET /api/v1/wines, applies filterWines + sortWines; auto-sort to drink_window_end_asc when DRINK_NOW filter active and no explicit sort (US-3.3)
- Desktop layout renders table with Country/Region extra cols at ≥1024px
- Result count displayed in JetBrains Mono UPPERCASE: "Showing N of Total wines"
- Error banner on API failure with correct UX-Mockup message
- app/cellar/page.tsx is a valid Next.js App Router page
</success_criteria>

<output>
After completion, create `.planning/express/building-a-web-app-to-keep-track-of-my-w/06-SUMMARY.md` summarizing:
- Components created and their props interfaces
- ReadinessBadge colors (exact hex values confirmed)
- Filter dimensions implemented in FilterPanel
- Filter persistence mechanism (sessionStorage, CP-02)
- Fuse.js search fields (wine_name, producer, region, grape_variety)
- Exports provided for reuse by Dashboard plan (WineCard, ReadinessBadge)
- Any deviations from UX-Mockup spec (expected: none)
</output>
