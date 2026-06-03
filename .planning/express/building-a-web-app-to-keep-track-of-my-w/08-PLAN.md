---
phase: 03-frontend-dashboard
plan: 08
type: execute
wave: 8
depends_on: [2, 3, 4]
files_modified:
  - app/dashboard/page.tsx
  - components/dashboard/StatsTile.tsx
  - components/dashboard/DrinkNowShelf.tsx
  - components/dashboard/DrinkNowCard.tsx
  - components/dashboard/BreakdownByType.tsx
  - components/dashboard/BreakdownByRegion.tsx
  - components/dashboard/BreakdownByDecade.tsx
  - components/dashboard/RecentlyAddedSection.tsx
  - components/dashboard/RecentlyConsumedSection.tsx
  - components/dashboard/HighestRatedSection.tsx
  - components/dashboard/DashboardSkeleton.tsx
  - components/dashboard/DashboardEmpty.tsx
  - e2e/dashboard.spec.ts
autonomous: true

features:
  implements: ["F6"]
  depends_on: ["F0", "F1", "F4", "F5"]
  enables: ["F0", "F1", "F2", "F3", "F4", "F5", "F6"]

must_haves:
  truths:
    - "Dashboard is the default landing page at app root (/)"
    - "4-tile stats bar renders: Total Bottles, Wine Records, Drink Now, Approaching Peak — each tappable → Wine List filtered"
    - "Drink Now shelf shows up to 10 wines with DRINK_NOW status and qty>0, sorted by drink_window_end ascending; horizontal scroll on mobile"
    - "Drink Now shelf has type pills (All / Red / White / Sparkling etc.) that filter shelf cards in-place per CP-04"
    - "Collection breakdowns render: By Wine Type (6 rows, proportional bar, count, %, tappable), By Country/Region (top 5 + Other, tappable), By Vintage Decade (desc, proportional bar, count, tappable)"
    - "Recently Added shows 5 most recent wines with relative date ('2 days ago') and View all link"
    - "Recently Consumed shows 5 most recent CONSUMED events with relative date and View all link"
    - "Highest Rated shows top 5 wines by latest_rating with rating display per user scale and tappable rows"
    - "All empty states render correctly (no Drink Now wines, no consumed events, no rated wines, empty collection onboarding)"
    - "Loading state shows skeleton shimmer on stat tiles and cards"
    - "Mobile (375px): vertical stacking, horizontal scroll shelf; Desktop (1024px+): grid layout for stats bar"
  artifacts:
    - path: "app/dashboard/page.tsx"
      provides: "Dashboard page component — Next.js App Router page"
      exports: ["default"]
    - path: "components/dashboard/StatsTile.tsx"
      provides: "Single stat tile with number, label, and navigation link"
      exports: ["StatsTile"]
    - path: "components/dashboard/DrinkNowShelf.tsx"
      provides: "Drink Now shelf with type pill filters and horizontal scroll"
      exports: ["DrinkNowShelf"]
    - path: "components/dashboard/BreakdownByType.tsx"
      provides: "Wine type breakdown with proportional bar"
      exports: ["BreakdownByType"]
    - path: "components/dashboard/BreakdownByRegion.tsx"
      provides: "Country/region breakdown top 5 + Other"
      exports: ["BreakdownByRegion"]
    - path: "components/dashboard/BreakdownByDecade.tsx"
      provides: "Vintage decade breakdown with proportional bar"
      exports: ["BreakdownByDecade"]
    - path: "components/dashboard/RecentlyAddedSection.tsx"
      provides: "Recently added wines list (5 items, relative date)"
      exports: ["RecentlyAddedSection"]
    - path: "components/dashboard/RecentlyConsumedSection.tsx"
      provides: "Recently consumed events list (5 items, relative date)"
      exports: ["RecentlyConsumedSection"]
    - path: "components/dashboard/HighestRatedSection.tsx"
      provides: "Top 5 highest rated wines with rating display"
      exports: ["HighestRatedSection"]
    - path: "components/dashboard/DashboardSkeleton.tsx"
      provides: "Shimmer skeleton for dashboard loading state"
      exports: ["DashboardSkeleton"]
    - path: "components/dashboard/DashboardEmpty.tsx"
      provides: "Onboarding empty state with Add Wine CTA"
      exports: ["DashboardEmpty"]
    - path: "e2e/dashboard.spec.ts"
      provides: "Playwright E2E tests for dashboard page behaviors"
      exports: []
  key_links:
    - from: "app/dashboard/page.tsx"
      to: "/api/v1/dashboard"
      via: "fetch in async server component or useQuery"
      pattern: "api/v1/dashboard"
    - from: "app/dashboard/page.tsx"
      to: "components/dashboard/StatsTile.tsx"
      via: "import StatsTile, renders 4 tiles from stats data"
      pattern: "StatsTile"
    - from: "components/dashboard/DrinkNowShelf.tsx"
      to: "components/dashboard/DrinkNowCard.tsx"
      via: "maps drink_now_shelf array, filtered by selectedType pill"
      pattern: "DrinkNowCard"
    - from: "app/dashboard/page.tsx"
      to: "/cellar?readiness=DRINK_NOW"
      via: "StatsTile onClick navigation for Drink Now tile"
      pattern: "readiness=DRINK_NOW"

integration_contracts:
  requires:
    - from_plan: "02"
      artifact: "lib/business/readiness.ts"
      exports: ["calculateReadinessStatus", "ReadinessStatus"]
      verify: "grep -n 'export function calculateReadinessStatus\\|export.*calculateReadinessStatus' lib/business/readiness.ts && echo CONTRACT_OK"
    - from_plan: "02"
      artifact: "app/api/v1/wines/route.ts"
      exports: ["GET"]
      verify: "grep -n 'export.*function GET\\|export.*GET' app/api/v1/wines/route.ts && echo CONTRACT_OK"
    - from_plan: "03"
      artifact: "app/api/v1/locations/route.ts"
      exports: ["GET"]
      verify: "grep -n 'export.*GET\\|export async function GET' app/api/v1/locations/route.ts && echo CONTRACT_OK"
    - from_plan: "04"
      artifact: "app/api/v1/dashboard/route.ts"
      exports: ["GET"]
      verify: "grep -n 'export.*GET' app/api/v1/dashboard/route.ts && echo CONTRACT_OK"
    - from_plan: "04"
      artifact: "app/api/v1/dashboard/stats/route.ts"
      exports: ["GET"]
      verify: "grep -n 'export.*GET' app/api/v1/dashboard/stats/route.ts && echo CONTRACT_OK"
    - from_plan: "04"
      artifact: "lib/queries/dashboard.ts"
      exports: ["getDashboard", "getDashboardStats"]
      verify: "grep -n 'export.*getDashboard\\|export.*getDashboardStats' lib/queries/dashboard.ts && echo CONTRACT_OK"
  provides:
    - artifact: "app/dashboard/page.tsx"
      exports: ["default"]
      shape: |
        Default export: Next.js App Router page at route /dashboard (also set as root redirect)
        Fetches GET /api/v1/dashboard on load; renders all dashboard sections
        Accepts no props; handles loading, empty-collection, and data states
      verify: "test -f app/dashboard/page.tsx && grep -n 'export default' app/dashboard/page.tsx && echo CONTRACT_OK"
    - artifact: "components/dashboard/StatsTile.tsx"
      exports: ["StatsTile"]
      shape: |
        interface StatsTileProps { label: string; value: number; href: string; colorScheme?: 'default' | 'gold' }
        export function StatsTile(props: StatsTileProps): JSX.Element
      verify: "grep -n 'export.*StatsTile\\|export function StatsTile' components/dashboard/StatsTile.tsx && echo CONTRACT_OK"
    - artifact: "components/dashboard/DrinkNowShelf.tsx"
      exports: ["DrinkNowShelf"]
      shape: |
        interface DrinkNowShelfProps { wines: DrinkNowCard[]; totalCount: number }
        export function DrinkNowShelf(props: DrinkNowShelfProps): JSX.Element
        // Internally manages selectedType pill state; renders type pills (CP-04) and filtered DrinkNowCards
      verify: "grep -n 'export.*DrinkNowShelf\\|export function DrinkNowShelf' components/dashboard/DrinkNowShelf.tsx && echo CONTRACT_OK"
---

<objective>
Build the Dashboard page — the default landing view for SimpleWineApp. Renders all insight cards: 4-tile stats bar, Drink Now shelf with type pills (CP-04), three collection breakdowns (by type, region, decade), recently added/consumed sections, and highest rated list. All data from GET /api/v1/dashboard and GET /api/v1/dashboard/stats. Full empty states and loading skeleton. Mobile-first (375px) with desktop grid at 1024px+.

Purpose: Dashboard answers the app's core promise — "What do I have? What should I drink next?" — on first load. It is the default route and the primary value demonstration for all personas.
Output: 12 React component files + 1 E2E test file covering all US-6.x user stories.
</objective>

<feature_dependencies>
Implements: F6: Collection Dashboard & Insights (F06.1 Summary Stats Bar, F06.2 Drink Now Shelf, F06.3 Breakdown by Type, F06.4 Breakdown by Region, F06.5 Breakdown by Decade, F06.6 Recently Added, F06.7 Recently Consumed, F06.8 Highest Rated, F06.9 Dashboard Navigation)
Depends on: F0: Wine Inventory CRUD (wines data via GET /api/v1/dashboard), F1: Quantity & Bottle Status (bottle_events for recently consumed), F4: Tasting Notes & Ratings (latest_rating for highest rated, user rating scale from GET /api/v1/settings/rating-scale), F5: Drinking Window Management (readiness_status from API for Drink Now shelf and stats)
Enables: All features — Dashboard is the landing page that links to every other feature in the app
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
  <name>Task 1: Dashboard page, stats bar, Drink Now shelf with type pills, and skeleton/empty states</name>
  <files>
    app/dashboard/page.tsx
    components/dashboard/StatsTile.tsx
    components/dashboard/DrinkNowShelf.tsx
    components/dashboard/DrinkNowCard.tsx
    components/dashboard/DashboardSkeleton.tsx
    components/dashboard/DashboardEmpty.tsx
  </files>
  <action>
Create the Dashboard page and its primary above-the-fold components. The page fetches `GET /api/v1/dashboard` and orchestrates all sections.

---

**Data shape consumed from GET /api/v1/dashboard** (from plan 04 lib/queries/dashboard.ts):
```typescript
interface DashboardResponse {
  stats: {
    total_bottles: number;
    total_wine_records: number;
    drink_now_count: number;
    approaching_peak_count: number;
  };
  drink_now_shelf: Array<{
    wine_id: string;
    wine_name: string;
    producer: string;
    vintage_year: number;
    wine_type: string;       // 'RED'|'WHITE'|'ROSE'|'SPARKLING'|'DESSERT'|'FORTIFIED'
    quantity: number;
    storage_location_name: string | null;
    drink_window_end: number | null;
    readiness_status: string; // always 'DRINK_NOW' here
  }>;
  breakdown_by_type: Array<{ wine_type: string; bottle_count: number; percentage: number }>;
  breakdown_by_region: Array<{ label: string; bottle_count: number; percentage: number }>;
  breakdown_by_decade: Array<{ decade: string; bottle_count: number }>;
  recently_added: Array<{ wine_id: string; wine_name: string; producer: string; vintage_year: number; wine_type: string; created_at: string }>;
  recently_consumed: Array<{ event_id: string; wine_id: string; wine_name: string; producer: string; vintage_year: number; event_date: string }>;
  highest_rated: Array<{ wine_id: string; wine_name: string; producer: string; vintage_year: number; latest_rating: number; latest_rating_scale: string; latest_rating_date: string }>;
}
```

---

**app/dashboard/page.tsx** — Next.js App Router page. Use `'use client'` with `useEffect` + `fetch` to load dashboard data (or async server component — use whichever approach plan 05/06 established for other pages; if neither exists yet, use client component with React state). Render sections in order per UX-Mockup Screen 00 information hierarchy.

Key behaviors:
- On mount: `fetch('/api/v1/dashboard')` → set state to response data
- Loading state: render `<DashboardSkeleton />`
- Empty collection (total_wine_records === 0): render `<DashboardEmpty />`
- Default: render full dashboard in this order:
  1. `<StatsTileBar>` — 4 tiles from `data.stats`
  2. `<DrinkNowShelf wines={data.drink_now_shelf} totalCount={data.stats.drink_now_count} />`
  3. `<BreakdownByType rows={data.breakdown_by_type} />`
  4. `<BreakdownByRegion rows={data.breakdown_by_region} />`
  5. `<BreakdownByDecade rows={data.breakdown_by_decade} />`
  6. `<RecentlyAddedSection items={data.recently_added} />`
  7. `<RecentlyConsumedSection items={data.recently_consumed} />`
  8. `<HighestRatedSection items={data.highest_rated} />`

Page layout USWDS + TechSur: `background: var(--color-bone, #FAFAF7)`, `padding: 1rem` on mobile; `padding: 1.5rem 2rem` on desktop. Page heading "My Cellar" using Montserrat 900 (hidden — screen reader only, since the visual hierarchy starts with stats tiles).

---

**components/dashboard/StatsTile.tsx** — Tappable stat tile per UX-Mockup Screen 00 stats bar.

```typescript
interface StatsTileProps {
  label: string;     // "Total Bottles", "Wine Records", "Drink Now", "Approaching Peak"
  value: number;
  href: string;      // navigation target: '/cellar', '/cellar?readiness=DRINK_NOW', etc.
  subLabel?: string; // optional sub-label like "in your cellar"
}
```

Render as `<Link href={href}>` wrapping a `<div>` card:
- Background: `var(--color-bone)` with `box-shadow: 0 1px 3px rgba(0,0,0,0.12)`
- `border-radius: 4px` (slight, not 2px — cards, not buttons)
- Value: Montserrat 900, `font-size: 2rem`, `color: var(--color-ink, #1A1A1A)`. For "Drink Now" tile: value in Gold `#B0832A` (Gold 600 for contrast on Bone background per token map).
- Label: JetBrains Mono UPPERCASE, `font-size: 0.65rem`, `letter-spacing: 0.08em`, `color: var(--color-gray-400, #A8A59B)`
- Mobile: stats bar = 2×2 grid (`display: grid; grid-template-columns: 1fr 1fr`); Desktop 1024px+: single row 4 columns (`grid-template-columns: repeat(4, 1fr)`)
- Each tile has `min-height: 80px`, centered content
- Hover: `background: var(--color-paper, #F5F5F2)`; `cursor: pointer`
- WCAG: `aria-label="{label}: {value}"` on the link element

StatsTileBar layout: render as `<section aria-label="Collection Summary">` with a `usa-grid`-based CSS Grid wrapper of the 4 tiles.

Stats navigation targets:
- Total Bottles → `/cellar` (no filter)
- Wine Records → `/cellar` (no filter)
- Drink Now → `/cellar?readiness=DRINK_NOW`
- Approaching Peak → `/cellar?readiness=APPROACHING_PEAK`

---

**components/dashboard/DrinkNowCard.tsx** — Individual card in the Drink Now shelf horizontal scroll.

```typescript
interface DrinkNowCardProps {
  wine: {
    wine_id: string;
    wine_name: string;
    producer: string;
    vintage_year: number;
    wine_type: string;
    quantity: number;
    storage_location_name: string | null;
    drink_window_end: number | null;
  };
}
```

Card dimensions: `width: 160px` (fixed, for horizontal scroll), `min-height: 180px`. TechSur styling:
- Background: `var(--color-bone)` with border `1px solid rgba(0,0,0,0.08)`
- `border-radius: 4px`, `padding: 0.75rem`
- Wine name: Open Sans 700, `font-size: 0.875rem`, max 2 lines with `overflow: hidden; text-overflow: ellipsis; display: -webkit-box; -webkit-line-clamp: 2`
- Vintage year: JetBrains Mono, `font-size: 0.75rem`, `color: var(--color-gray-400)`
- DRINK NOW badge: Gold `#FBCA5C` bg, Black text, JetBrains Mono UPPERCASE, `font-size: 0.6rem`, `padding: 2px 6px`, `border-radius: 2px`
- Quantity: `qty: {N}` in JetBrains Mono, `color: var(--color-gray-400)`
- Location: Open Sans, `font-size: 0.75rem`, truncated 1 line, prefixed with "📍 " — if null show "Location Unknown"
- Entire card wrapped in `<Link href={/wines/{wine_id}}>` — `cursor: pointer`, hover: `box-shadow: 0 2px 8px rgba(0,0,0,0.15)`

---

**components/dashboard/DrinkNowShelf.tsx** — Shelf section with type pill filter bar (CP-04) and horizontal scroll.

```typescript
interface DrinkNowShelfProps {
  wines: DrinkNowCardData[];
  totalCount: number;  // for "See all [N] →" link
}
```

Internal `selectedType` state: `'ALL' | 'RED' | 'WHITE' | 'SPARKLING' | 'ROSE' | 'DESSERT' | 'FORTIFIED'`; default `'ALL'`.

Type pills bar: `display: flex; gap: 0.5rem; overflow-x: auto; padding-bottom: 0.5rem`. Pills:
- Show only types that actually appear in `wines` array plus "All"; do NOT show empty type pills
- Active pill: Gold `#FBCA5C` bg, Black text; Inactive: `var(--color-paper)` bg, Ink text
- Style: JetBrains Mono UPPERCASE, `font-size: 0.65rem`, `padding: 4px 12px`, `border-radius: 2px`, `border: 1px solid transparent` (active) / `1px solid var(--color-gray-400)` (inactive)
- Click on pill: set `selectedType` state; "All" resets to `'ALL'`

Filtered wines: when `selectedType !== 'ALL'`, filter shelf array by `wine_type === selectedType`

Scroll container: `display: flex; gap: 1rem; overflow-x: auto; padding: 0.5rem 0 1rem; scroll-snap-type: x mandatory`. Each DrinkNowCard has `scroll-snap-align: start; flex-shrink: 0`.

Empty shelf state (no DRINK_NOW wines): render a placeholder card with message "No wines are ready to drink right now." styled as a muted card (same width/height as DrinkNowCard, `color: var(--color-gray-400)`, centered text, Paper background).

"See all [N] →" link below scroll area: `<Link href="/cellar?readiness=DRINK_NOW">See all {totalCount} →</Link>` — Open Sans 700, Gold 600 `#B0832A`, `font-size: 0.875rem`. Hide this link when totalCount === 0.

Section heading: `<h2>` Montserrat 900, `font-size: 1rem`, UPPERCASE with `letter-spacing: 0.1em`, `color: var(--color-ink)`. Preceded by a `<hr>` divider using `border-color: rgba(0,0,0,0.1)`.

---

**components/dashboard/DashboardSkeleton.tsx** — Shimmer loading skeleton.

Render placeholder shimmer blocks matching the layout of the real dashboard:
- 4 stat tile shimmers: `height: 80px`, `border-radius: 4px`, shimmer animation
- Shelf label shimmer + 3 card shimmers: `width: 160px; height: 180px`
- 2 section heading shimmers + 6 list row shimmers: `height: 20px`

Shimmer CSS animation: `@keyframes shimmer { 0% { background-position: -200px 0; } 100% { background-position: calc(200px + 100%) 0; } }` with `background: linear-gradient(90deg, #e8e6e1 25%, #f0ede8 50%, #e8e6e1 75%)`. Add CSS Modules or `<style jsx>` or inline styles — use whichever approach the rest of wave 3 established; if no pattern exists yet, use inline style with a `<style>` tag in the component.

Announce to screen readers: `<div role="status" aria-label="Loading your cellar…">` wrapping the skeleton.

---

**components/dashboard/DashboardEmpty.tsx** — Onboarding empty state for brand-new users.

Render centered content:
- Icon/illustration: 🍷 emoji in a large circle (Gold `#FBCA5C` bg, `border-radius: 50%`, `width: 80px; height: 80px`, centered `font-size: 2rem`)
- Heading: Montserrat 900, "Your cellar is empty." `font-size: 1.25rem`
- Body: Open Sans 400, "Add your first wine to get started tracking your collection." `color: var(--color-gray-400)`
- CTA button: `<Link href="/wines/new">` styled as primary `usa-button` with Gold fill (#FBCA5C bg, Black text, Montserrat 700 UPPERCASE, `border-radius: 2px`, `padding: 0.75rem 1.5rem`)
- WCAG: `role="main"` on container
  </action>
  <verify>
test -f app/dashboard/page.tsx && test -f components/dashboard/StatsTile.tsx && test -f components/dashboard/DrinkNowShelf.tsx && test -f components/dashboard/DrinkNowCard.tsx && test -f components/dashboard/DashboardSkeleton.tsx && test -f components/dashboard/DashboardEmpty.tsx && grep -n 'export.*StatsTile\|export function StatsTile' components/dashboard/StatsTile.tsx && grep -n 'export.*DrinkNowShelf\|export function DrinkNowShelf' components/dashboard/DrinkNowShelf.tsx && grep -n 'api/v1/dashboard' app/dashboard/page.tsx && grep -n 'selectedType\|type.*pill\|wine_type' components/dashboard/DrinkNowShelf.tsx && echo CONTRACT_OK
  </verify>
  <done>
- app/dashboard/page.tsx fetches GET /api/v1/dashboard on mount; renders DashboardSkeleton while loading, DashboardEmpty when total_wine_records === 0, full dashboard otherwise
- StatsTile renders 4 tiles in 2×2 grid (mobile) / 4-column row (desktop 1024px+); each tappable link to filtered Wine List per UX-Mockup navigation targets
- DrinkNowCard renders 160px fixed-width card with wine name, vintage, DRINK NOW badge (Gold), quantity, location
- DrinkNowShelf renders type pill filter bar (CP-04) showing only types present in data; active pill = Gold; filters shelf in-place; horizontal scroll container; "See all [N] →" link; empty shelf placeholder card
- DashboardSkeleton renders shimmer placeholders with role="status" aria-label="Loading your cellar…"
- DashboardEmpty renders onboarding state with Gold CTA to /wines/new
  </done>
</task>

<task type="auto">
  <name>Task 2: Collection breakdowns, recently added/consumed, highest rated + E2E tests</name>
  <files>
    components/dashboard/BreakdownByType.tsx
    components/dashboard/BreakdownByRegion.tsx
    components/dashboard/BreakdownByDecade.tsx
    components/dashboard/RecentlyAddedSection.tsx
    components/dashboard/RecentlyConsumedSection.tsx
    components/dashboard/HighestRatedSection.tsx
    e2e/dashboard.spec.ts
  </files>
  <action>
Create all remaining dashboard section components plus the Playwright E2E test suite covering US-6.1–US-6.5.

---

**Shared section heading pattern** — all sections use:
```tsx
<section aria-label="{section name}">
  <hr style={{ borderColor: 'rgba(0,0,0,0.1)', margin: '1rem 0 0.75rem' }} />
  <h2 style={{ fontFamily: 'Montserrat', fontWeight: 900, fontSize: '0.875rem',
                textTransform: 'uppercase', letterSpacing: '0.1em',
                color: 'var(--color-gray-400)', marginBottom: '0.75rem' }}>
    {SECTION_TITLE}
  </h2>
  {/* content */}
</section>
```

Shared proportional bar pattern used in BreakdownByType and BreakdownByDecade:
```
totalMax = max(bottle_count) across all rows
barWidth(count) = `${Math.round((count / totalMax) * 100)}%`
```
Bar container: `height: 8px; background: var(--color-paper); border-radius: 4px; overflow: hidden`
Bar fill: `height: 100%; background: var(--color-gold-400, #FBCA5C); border-radius: 4px; width: {barWidth}`

---

**components/dashboard/BreakdownByType.tsx**

```typescript
interface BreakdownByTypeProps {
  rows: Array<{ wine_type: string; bottle_count: number; percentage: number }>;
}
```

All 6 wine types always rendered (fill missing with bottle_count: 0, percentage: 0) in this order: Red, White, Sparkling, Rosé, Dessert, Fortified.

Each row: `<Link href={/cellar?wine_type={wine_type}}>` wrapping:
- Layout: `display: grid; grid-template-columns: 5rem 1fr 3rem 3rem; align-items: center; gap: 0.5rem; padding: 0.375rem 0`
- Type label: Open Sans 400, `font-size: 0.875rem`, `color: var(--color-ink)` — display as human-readable ("Red", "White", "Sparkling", "Rosé", "Dessert", "Fortified")
- Proportional bar: flex-grow bar using the max-based scaling above; `min-width: 4px` so zero rows show a thin bar
- Count: JetBrains Mono, `font-size: 0.75rem`, right-aligned, `color: var(--color-ink)`
- Percentage: JetBrains Mono, `font-size: 0.75rem`, `color: var(--color-gray-400)`, right-aligned; show "0%" for zero types
- Hover: `background: var(--color-paper)`; `border-radius: 2px`
- WCAG: `aria-label="{type}: {count} bottles, {percentage}%"` on link

Section heading: "BY WINE TYPE"

---

**components/dashboard/BreakdownByRegion.tsx**

```typescript
interface BreakdownByRegionProps {
  rows: Array<{ label: string; bottle_count: number; percentage: number }>;
}
```

Rows include top 5 + "Other" from API. Each row: `<Link href={buildRegionHref(label)}>` where buildRegionHref maps "France" → `/cellar?country=France`, "France, Bordeaux" → `/cellar?region=Bordeaux&country=France`, "Other" → `/cellar` (no filter), "Unknown Origin" → `/cellar?location_id=unknown`.

Each row layout: `display: flex; justify-content: space-between; align-items: center; padding: 0.375rem 0`
- Label: Open Sans 400, `font-size: 0.875rem`, `color: var(--color-ink)`
- Right side: count (JetBrains Mono) + percentage (JetBrains Mono, gray) + arrow `→`
- Row hover: `background: var(--color-paper)`; `border-radius: 2px`

Section heading: "BY COUNTRY / REGION (TOP 5)"

---

**components/dashboard/BreakdownByDecade.tsx**

```typescript
interface BreakdownByDecadeProps {
  rows: Array<{ decade: string; bottle_count: number }>;
}
```

Rows from API are already sorted most-recent first. Render each decade row:
- Layout: `display: grid; grid-template-columns: 4rem 1fr 3rem; align-items: center; gap: 0.5rem; padding: 0.375rem 0`
- Decade label: JetBrains Mono UPPERCASE, `font-size: 0.75rem`, `color: var(--color-ink)` (e.g., "2020s")
- Proportional bar (same pattern as BreakdownByType, max scaling)
- Count: JetBrains Mono, `font-size: 0.75rem`, right-aligned
- Each row wrapped in `<Link href={buildDecadeHref(decade)}>` where `buildDecadeHref("2020s")` → `/cellar?vintage_from=2020&vintage_to=2029`; parse decade as `parseInt(decade) = 2020` → to = 2020+9
- Row hover: `background: var(--color-paper)`

Section heading: "BY VINTAGE DECADE"

---

**components/dashboard/RecentlyAddedSection.tsx**

```typescript
interface RecentlyAddedSectionProps {
  items: Array<{
    wine_id: string;
    wine_name: string;
    producer: string;
    vintage_year: number;
    wine_type: string;
    created_at: string;  // ISO timestamp
  }>;
}
```

Relative date helper (pure function in same file):
```typescript
function relativeDate(isoString: string): string {
  const diffMs = Date.now() - new Date(isoString).getTime();
  const diffDays = Math.floor(diffMs / (1000 * 60 * 60 * 24));
  if (diffDays === 0) return 'Today';
  if (diffDays === 1) return 'Yesterday';
  if (diffDays < 7) return `${diffDays} days ago`;
  if (diffDays < 30) return `${Math.floor(diffDays / 7)} weeks ago`;
  if (diffDays < 365) return `${Math.floor(diffDays / 30)} months ago`;
  return `${Math.floor(diffDays / 365)} years ago`;
}
```

Each row: `<Link href={/wines/{wine_id}}>` wrapping:
- Layout: `display: flex; justify-content: space-between; align-items: flex-start; padding: 0.5rem 0; border-bottom: 1px solid rgba(0,0,0,0.06)`
- Left: `{wine_name} {vintage_year} · {producer}` in Open Sans 400, `font-size: 0.875rem`; below it: `Added {relativeDate(created_at)}` in Open Sans 400, `font-size: 0.75rem`, `color: var(--color-gray-400)`
- Right: `→` in `color: var(--color-gold-600, #B0832A)`, `font-size: 1rem`
- Hover: `background: var(--color-paper); border-radius: 2px; margin: 0 -0.5rem; padding: 0.5rem`

"View all →" footer link: `<Link href="/cellar?sort=created_at_desc">View all →</Link>` — Open Sans 700, Gold 600, `font-size: 0.875rem`

Section heading: "RECENTLY ADDED"

---

**components/dashboard/RecentlyConsumedSection.tsx**

```typescript
interface RecentlyConsumedSectionProps {
  items: Array<{
    event_id: string;
    wine_id: string;
    wine_name: string;
    producer: string;
    vintage_year: number;
    event_date: string;  // YYYY-MM-DD date string
  }>;
}
```

Relative date for `event_date` (date-only string): same logic but parse as date-only (`new Date(event_date + 'T00:00:00')` to avoid timezone issues).

Each row same layout pattern as RecentlyAdded but text: `{wine_name} · {vintage_year}` + sub: `Consumed {relativeDate(event_date)}`

Empty state (items.length === 0): render `<p style={{ color: 'var(--color-gray-400)', fontSize: '0.875rem', fontStyle: 'italic' }}>No consumed bottles recorded yet.</p>`

"View all →" footer link: `<Link href="/cellar?event_type=CONSUMED">View all →</Link>`

Section heading: "RECENTLY CONSUMED"

---

**components/dashboard/HighestRatedSection.tsx**

```typescript
interface HighestRatedSectionProps {
  items: Array<{
    wine_id: string;
    wine_name: string;
    producer: string;
    vintage_year: number;
    latest_rating: number;
    latest_rating_scale: 'STARS_5' | 'POINTS_100';
  }>;
  ratingScale?: 'STARS_5' | 'POINTS_100';  // from user settings; default 'STARS_5'
}
```

Rating display helper:
```typescript
function displayRating(rating: number, scale: 'STARS_5' | 'POINTS_100'): React.ReactNode {
  if (scale === 'STARS_5') {
    const fullStars = Math.floor(rating);
    const emptyStars = 5 - fullStars;
    return (
      <span aria-label={`${rating} out of 5 stars`} style={{ color: '#FBCA5C', fontSize: '0.875rem' }}>
        {'★'.repeat(fullStars)}{'☆'.repeat(emptyStars)}
      </span>
    );
  }
  return (
    <span style={{ fontFamily: 'JetBrains Mono, monospace', fontSize: '0.75rem', color: 'var(--color-ink)' }}>
      {rating}/100
    </span>
  );
}
```

Each row: `<Link href={/wines/{wine_id}}>` wrapping:
- Layout: `display: flex; justify-content: space-between; align-items: center; padding: 0.375rem 0; border-bottom: 1px solid rgba(0,0,0,0.06)`
- Left: `{wine_name} {vintage_year} · {producer}` Open Sans 400, `font-size: 0.875rem`
- Right: `{displayRating(latest_rating, latest_rating_scale)}`
- Hover: same as other sections

Empty state (items.length === 0):
```tsx
<div style={{ padding: '1rem', background: 'var(--color-paper)', borderRadius: '4px', textAlign: 'center' }}>
  <p style={{ color: 'var(--color-gray-400)', fontSize: '0.875rem', fontStyle: 'italic', margin: 0 }}>
    Rate your wines to see your favorites here.
  </p>
</div>
```

Section heading: "HIGHEST RATED"

**NOTE on ratingScale:** The page fetches `GET /api/v1/settings/rating-scale` alongside the dashboard data, and passes `ratingScale` down to `HighestRatedSection`. Add a second `Promise.all` in page.tsx to fetch both endpoints concurrently:
```typescript
const [dashboardRes, settingsRes] = await Promise.all([
  fetch('/api/v1/dashboard'),
  fetch('/api/v1/settings/rating-scale'),
]);
```

---

**e2e/dashboard.spec.ts** — Playwright test suite covering all US-6.x acceptance criteria.

Prerequisite: Playwright must be installed and `playwright.config.ts` must exist with `baseURL`. If Playwright is not yet installed, the executor MUST run `npm init playwright@latest --yes` before writing the test file.

```typescript
import { test, expect } from '@playwright/test';

test.describe('Dashboard (US-6.1–US-6.5)', () => {
  test.beforeEach(async ({ page }) => {
    // Mock GET /api/v1/dashboard with a non-empty collection
    await page.route('**/api/v1/dashboard', async route => {
      await route.fulfill({
        status: 200,
        contentType: 'application/json',
        body: JSON.stringify({
          stats: {
            total_bottles: 487,
            total_wine_records: 62,
            drink_now_count: 22,
            approaching_peak_count: 31,
          },
          drink_now_shelf: [
            {
              wine_id: 'wine-1',
              wine_name: 'Château Margaux',
              producer: 'Château Margaux',
              vintage_year: 2018,
              wine_type: 'RED',
              quantity: 2,
              storage_location_name: 'Wine Fridge',
              drink_window_end: 2035,
              readiness_status: 'DRINK_NOW',
            },
            {
              wine_id: 'wine-2',
              wine_name: 'Sancerre',
              producer: 'Vacheron',
              vintage_year: 2021,
              wine_type: 'WHITE',
              quantity: 1,
              storage_location_name: 'Rack B',
              drink_window_end: 2026,
              readiness_status: 'DRINK_NOW',
            },
          ],
          breakdown_by_type: [
            { wine_type: 'RED', bottle_count: 48, percentage: 38 },
            { wine_type: 'WHITE', bottle_count: 31, percentage: 24 },
            { wine_type: 'SPARKLING', bottle_count: 18, percentage: 14 },
            { wine_type: 'ROSE', bottle_count: 8, percentage: 6 },
            { wine_type: 'DESSERT', bottle_count: 3, percentage: 2 },
            { wine_type: 'FORTIFIED', bottle_count: 2, percentage: 2 },
          ],
          breakdown_by_region: [
            { label: 'France', bottle_count: 92, percentage: 38 },
            { label: 'Italy', bottle_count: 48, percentage: 20 },
            { label: 'Other', bottle_count: 18, percentage: 7 },
          ],
          breakdown_by_decade: [
            { decade: '2020s', bottle_count: 42 },
            { decade: '2010s', bottle_count: 198 },
          ],
          recently_added: [
            {
              wine_id: 'wine-3',
              wine_name: 'Barolo DOCG',
              producer: 'Giacomo Conterno',
              vintage_year: 2018,
              wine_type: 'RED',
              created_at: new Date(Date.now() - 2 * 24 * 60 * 60 * 1000).toISOString(),
            },
          ],
          recently_consumed: [
            {
              event_id: 'ev-1',
              wine_id: 'wine-2',
              wine_name: 'Sancerre',
              producer: 'Vacheron',
              vintage_year: 2021,
              event_date: new Date(Date.now() - 24 * 60 * 60 * 1000).toISOString().split('T')[0],
            },
          ],
          highest_rated: [
            {
              wine_id: 'wine-3',
              wine_name: 'Barolo DOCG',
              producer: 'Giacomo Conterno',
              vintage_year: 2015,
              latest_rating: 5,
              latest_rating_scale: 'STARS_5',
              latest_rating_date: '2025-11-01',
            },
          ],
        }),
      });
    });

    await page.route('**/api/v1/settings/rating-scale', async route => {
      await route.fulfill({
        status: 200,
        contentType: 'application/json',
        body: JSON.stringify({ rating_scale: 'STARS_5' }),
      });
    });

    await page.goto('/dashboard');
  });

  // US-6.1: Summary Stats Bar
  test('renders 4 stat tiles with correct values', async ({ page }) => {
    await expect(page.getByText('487')).toBeVisible();           // Total Bottles
    await expect(page.getByText('62')).toBeVisible();            // Wine Records
    await expect(page.getByText('22')).toBeVisible();            // Drink Now
    await expect(page.getByText('31')).toBeVisible();            // Approaching Peak
  });

  test('stat tiles navigate to filtered wine list', async ({ page }) => {
    const drinkNowTile = page.locator('[aria-label*="Drink Now"]').first();
    await expect(drinkNowTile).toHaveAttribute('href', /readiness=DRINK_NOW/);
  });

  // US-6.2: Drink Now Shelf
  test('renders Drink Now shelf with wine cards', async ({ page }) => {
    await expect(page.getByText('Château Margaux')).toBeVisible();
    await expect(page.getByText('Sancerre')).toBeVisible();
  });

  test('Drink Now type pills filter shelf cards in-place (CP-04)', async ({ page }) => {
    const whitePill = page.getByRole('button', { name: /white/i });
    if (await whitePill.isVisible()) {
      await whitePill.click();
      await expect(page.getByText('Sancerre')).toBeVisible();
      await expect(page.getByText('Château Margaux')).not.toBeVisible();
    }
  });

  test('See all link points to Drink Now filtered wine list', async ({ page }) => {
    const seeAllLink = page.getByRole('link', { name: /see all/i });
    await expect(seeAllLink).toHaveAttribute('href', /readiness=DRINK_NOW/);
  });

  // US-6.3: Collection Breakdowns
  test('renders BY WINE TYPE breakdown with all 6 types', async ({ page }) => {
    await expect(page.getByText(/by wine type/i)).toBeVisible();
    await expect(page.getByText('Red')).toBeVisible();
    await expect(page.getByText('White')).toBeVisible();
    await expect(page.getByText('Sparkling')).toBeVisible();
  });

  test('renders BY COUNTRY / REGION breakdown', async ({ page }) => {
    await expect(page.getByText(/by country/i)).toBeVisible();
    await expect(page.getByText('France')).toBeVisible();
    await expect(page.getByText('Italy')).toBeVisible();
  });

  test('renders BY VINTAGE DECADE breakdown', async ({ page }) => {
    await expect(page.getByText(/by vintage decade/i)).toBeVisible();
    await expect(page.getByText('2020s')).toBeVisible();
    await expect(page.getByText('2010s')).toBeVisible();
  });

  // US-6.4: Recently Added / Consumed
  test('renders Recently Added section with wine name', async ({ page }) => {
    await expect(page.getByText(/recently added/i)).toBeVisible();
    await expect(page.getByText('Barolo DOCG')).toBeVisible();
    await expect(page.getByText(/days ago|yesterday|today/i)).toBeVisible();
  });

  test('renders Recently Consumed section', async ({ page }) => {
    await expect(page.getByText(/recently consumed/i)).toBeVisible();
    await expect(page.getByText('Sancerre')).toBeVisible();
    await expect(page.getByText(/consumed/i)).toBeVisible();
  });

  // US-6.5: Highest Rated
  test('renders Highest Rated section with star rating', async ({ page }) => {
    await expect(page.getByText(/highest rated/i)).toBeVisible();
    await expect(page.getByText('Barolo DOCG')).toBeVisible();
    await expect(page.getByText(/★/)).toBeVisible();
  });

  // Empty states
  test('shows "No wines are ready to drink right now" when shelf is empty', async ({ page }) => {
    await page.route('**/api/v1/dashboard', async route => {
      const body = { stats: { total_bottles: 5, total_wine_records: 5, drink_now_count: 0, approaching_peak_count: 0 }, drink_now_shelf: [], breakdown_by_type: [], breakdown_by_region: [], breakdown_by_decade: [], recently_added: [], recently_consumed: [], highest_rated: [] };
      await route.fulfill({ status: 200, contentType: 'application/json', body: JSON.stringify(body) });
    });
    await page.reload();
    await expect(page.getByText(/no wines are ready/i)).toBeVisible();
  });

  test('shows onboarding empty state when collection is empty', async ({ page }) => {
    await page.route('**/api/v1/dashboard', async route => {
      const body = { stats: { total_bottles: 0, total_wine_records: 0, drink_now_count: 0, approaching_peak_count: 0 }, drink_now_shelf: [], breakdown_by_type: [], breakdown_by_region: [], breakdown_by_decade: [], recently_added: [], recently_consumed: [], highest_rated: [] };
      await route.fulfill({ status: 200, contentType: 'application/json', body: JSON.stringify(body) });
    });
    await page.reload();
    await expect(page.getByText(/your cellar is empty/i)).toBeVisible();
    await expect(page.getByRole('link', { name: /add wine/i })).toBeVisible();
  });

  test('shows placeholder when no wines are rated', async ({ page }) => {
    await page.route('**/api/v1/dashboard', async route => {
      const body = { stats: { total_bottles: 5, total_wine_records: 5, drink_now_count: 0, approaching_peak_count: 0 }, drink_now_shelf: [], breakdown_by_type: [], breakdown_by_region: [], breakdown_by_decade: [], recently_added: [], recently_consumed: [], highest_rated: [] };
      await route.fulfill({ status: 200, contentType: 'application/json', body: JSON.stringify(body) });
    });
    await page.reload();
    await expect(page.getByText(/rate your wines/i)).toBeVisible();
  });

  test('shows "No consumed bottles recorded yet" when no consumed events', async ({ page }) => {
    await page.route('**/api/v1/dashboard', async route => {
      const body = { stats: { total_bottles: 5, total_wine_records: 5, drink_now_count: 0, approaching_peak_count: 0 }, drink_now_shelf: [], breakdown_by_type: [], breakdown_by_region: [], breakdown_by_decade: [], recently_added: [], recently_consumed: [], highest_rated: [] };
      await route.fulfill({ status: 200, contentType: 'application/json', body: JSON.stringify(body) });
    });
    await page.reload();
    await expect(page.getByText(/no consumed bottles/i)).toBeVisible();
  });
});
```

**After writing all files:**
1. Verify Playwright is installed: `npx playwright --version` — if not installed, run `npm init playwright@latest --yes`
2. Run the test: `npx playwright test e2e/dashboard.spec.ts --reporter=list 2>&1 | tail -30 && echo "PLAYWRIGHT PASSED"`
  </action>
  <verify>
test -f components/dashboard/BreakdownByType.tsx && test -f components/dashboard/BreakdownByRegion.tsx && test -f components/dashboard/BreakdownByDecade.tsx && test -f components/dashboard/RecentlyAddedSection.tsx && test -f components/dashboard/RecentlyConsumedSection.tsx && test -f components/dashboard/HighestRatedSection.tsx && test -f e2e/dashboard.spec.ts && grep -n 'export.*BreakdownByType\|export function BreakdownByType' components/dashboard/BreakdownByType.tsx && grep -n 'export.*HighestRatedSection\|export function HighestRatedSection' components/dashboard/HighestRatedSection.tsx && grep -n 'rate your wines\|Rate your wines' components/dashboard/HighestRatedSection.tsx && grep -n 'No consumed bottles\|no consumed bottles' components/dashboard/RecentlyConsumedSection.tsx && npx playwright test e2e/dashboard.spec.ts --reporter=list 2>&1 | tail -30 && echo "PLAYWRIGHT PASSED"
  </verify>
  <done>
- BreakdownByType renders all 6 wine types (including zero-count types), proportional bars, count, percentage, tappable to `/cellar?wine_type={type}`
- BreakdownByRegion renders top 5 + Other rows, tappable with region/country query params
- BreakdownByDecade renders decades desc, proportional bars, counts, tappable to `/cellar?vintage_from=X&vintage_to=Y`
- RecentlyAddedSection renders 5 items with relative date ("2 days ago"), "View all →" link to `/cellar?sort=created_at_desc`
- RecentlyConsumedSection renders 5 consumed events with relative date; empty state "No consumed bottles recorded yet."; "View all →" link
- HighestRatedSection renders top 5 wines with rating display (stars for STARS_5, numeric for POINTS_100); empty state "Rate your wines to see your favorites here."
- e2e/dashboard.spec.ts Playwright tests exist and pass — covering: 4 stat tiles, stat tile navigation, Drink Now shelf cards, type pill filtering (CP-04), See all link, all 3 breakdowns, recently added, recently consumed, highest rated with stars, and all 4 empty states
  </done>
</task>

</tasks>

<verification>
After both tasks complete, run these checks:

```bash
# 1. All component files exist
ls components/dashboard/*.tsx | sort

# 2. Page file exists and fetches dashboard endpoint
grep -n 'api/v1/dashboard' app/dashboard/page.tsx

# 3. Type pills (CP-04) present in DrinkNowShelf
grep -n 'selectedType\|type.*pill\|wine_type.*filter\|setSelectedType' components/dashboard/DrinkNowShelf.tsx

# 4. Empty states wired in
grep -n 'No wines are ready\|no wines are ready' components/dashboard/DrinkNowShelf.tsx
grep -n 'No consumed bottles\|no consumed bottles' components/dashboard/RecentlyConsumedSection.tsx
grep -n 'Rate your wines\|rate your wines' components/dashboard/HighestRatedSection.tsx
grep -n 'Your cellar is empty\|cellar is empty' components/dashboard/DashboardEmpty.tsx

# 5. Navigation links to Wine List segments
grep -n 'readiness=DRINK_NOW\|readiness=APPROACHING_PEAK' components/dashboard/StatsTile.tsx app/dashboard/page.tsx

# 6. Gold brand colors applied
grep -n 'FBCA5C\|#B0832A\|color-gold' components/dashboard/StatsTile.tsx components/dashboard/DrinkNowShelf.tsx

# 7. Playwright tests exist and pass
npx playwright test e2e/dashboard.spec.ts --reporter=list 2>&1 | tail -30 && echo "PLAYWRIGHT PASSED"
```
</verification>

<success_criteria>
- Dashboard page (app/dashboard/page.tsx) is the default landing view; fetches GET /api/v1/dashboard concurrently with GET /api/v1/settings/rating-scale
- 4-tile stats bar: Total Bottles, Wine Records, Drink Now (Gold), Approaching Peak — each tappable → filtered Wine List with correct query params
- Drink Now shelf: up to 10 cards in horizontal scroll, type pills (CP-04) filter in-place showing only present types, "See all [N] →" link, empty shelf placeholder card visible
- Collection breakdowns: all 6 wine types (including zero-count), top 5 regions + Other, decades desc — all rows tappable to filtered Wine List
- Recently Added: 5 rows, relative dates, View all → link; Recently Consumed: 5 rows, relative dates, View all → link, empty state text
- Highest Rated: top 5 wines, star rendering for STARS_5 scale, numeric for POINTS_100, empty state "Rate your wines to see your favorites here."
- Loading skeleton renders with role="status" and shimmer animation
- Empty collection (total_wine_records === 0) renders onboarding state with Gold "Add Wine" CTA button
- Mobile layout 375px: 2×2 stats grid, horizontal scroll shelf; Desktop 1024px+: 4-column stats row
- WCAG 2.1 AA: Gold text uses Gold 600 (#B0832A) on Bone backgrounds; all interactive elements have aria-labels
- Playwright tests pass covering all US-6.1–US-6.5 acceptance criteria including all empty states and type pill filtering
</success_criteria>

<output>
After completion, create `.planning/express/building-a-web-app-to-keep-track-of-my-w/08-SUMMARY.md` summarizing:
- Dashboard page created with full section inventory
- Components list with exports
- Empty states implemented (list all 4)
- E2E test coverage (list test names and counts)
- Any deviations from UX-Mockup Screen 00 spec
</output>
