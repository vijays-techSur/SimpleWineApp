---

### Screen 01: Collection List (My Cellar)

**Purpose:** Browse, search, and filter the full wine collection. The primary discovery and navigation hub.
**User Stories:** US-0.2, US-3.1, US-3.2, US-3.3, US-4.6, US-5.2, US-1.1

#### Mobile Wireframe (375px) — Card Layout

```
┌─────────────────────────────────────┐
│ ▓▓▓▓ HEADER (Black) ▓▓▓▓▓▓▓▓▓▓▓▓▓ │
│  My Cellar               [+ Add]    │
├─────────────────────────────────────┤
│ ┌─────────────────────────────────┐ │
│ │ 🔍 Search wines...           [×]│ │  ← usa-search, always visible
│ └─────────────────────────────────┘ │
│ [⚗ Filter]              Sort: [▾] │  ← filter btn + sort select
│ ─────────────────────────────────── │
│ [Type: Red, White ×] [Vintage:2015–  │  ← active filter chips
│  2020 ×]  [Clear all]               │
│ Showing 14 of 62 wines              │  ← JetBrains Mono UPPERCASE
│ ─────────────────────────────────── │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ [RED]       [DRINK NOW]     ★★★★│ │  ← type badge · readiness · rating
│ │ Château Margaux              [2]│ │  ← wine name · qty pill
│ │ Margaux · 2018                  │ │  ← producer · vintage
│ │ 📍 Wine Fridge — Top Shelf      │ │  ← storage location (CP-01)
│ └─────────────────────────────────┘ │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │ [WHITE]         [HOLD]          │ │
│ │ Sancerre Rouge               [1]│ │
│ │ Vacheron · 2021                 │ │
│ │ 📍 Basement Cellar              │ │
│ └─────────────────────────────────┘ │
│                                     │
│ ┌─────────────────────────────────┐ │  ← Cellar Empty: muted/greyed
│ │ [RED]          [HOLD]    ░░░░░░ │ │
│ │ Barolo DOCG          [EMPTY] [0]│ │
│ │ Giacomo Conterno · 2015         │ │
│ │ 📍 Basement Cellar — Rack A     │ │
│ └─────────────────────────────────┘ │
│                                     │
│         [Load more / Pagination]    │
│                                     │
├─────────────────────────────────────┤
│ [Dashboard] [Cellar●] [Settings] [+]│
└─────────────────────────────────────┘
```

#### Desktop Wireframe (1024px) — Table Layout

```
┌────────────────────────────────────────────────────────────────────┐
│ ▓▓▓▓▓▓▓▓ HEADER ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ │
│  SimpleWineApp    Dashboard | My Cellar | Settings    [+ Add Wine] │
├──────────────────────┬─────────────────────────────────────────────┤
│  FILTER SIDEBAR      │  COLLECTION TABLE                           │
│  ─────────────────   │  ┌──────────┬──────────┬──────┬──────┐     │
│  Wine Type           │  │ 🔍 Search...    [×] │ Sort: [▾]  │     │
│  ☑ Red               │  └──────────────────────────────────┘      │
│  ☑ White             │  [Type: Red ×]  [Clear all]                │
│  ☐ Rosé              │  Showing 14 of 62 wines                    │
│  ☐ Sparkling         │                                             │
│  ☐ Dessert           │  NAME         PROD    VIN  TYPE   STATUS  QTY│
│  ☐ Fortified         │  ─────────────────────────────────────────  │
│                      │  Château…   Margaux 2018 [RED]  [DRINK] [2]│
│  Readiness           │  Sancerre   Vacheron 2021 [WHITE] [HOLD] [1]│
│  ☐ Drink Now         │  Barolo…    Conterno 2015 [RED]  [HOLD]  [0]│
│  ☐ Approaching Peak  │                                             │
│  ☐ Hold              │  (additional desktop cols: Country, Region, │
│  ☐ Past Window       │   Purchase Price visible at 1024px+)        │
│  ☐ No Window Set     │                                             │
│                      │                                             │
│  Vintage Range       │                                             │
│  From [____] To [___]│                                             │
│                      │                                             │
│  Storage Location    │                                             │
│  [Select location ▾] │                                             │
│                      │                                             │
│  Rating Range        │                                             │
│  Min [_] Max [_]     │                                             │
│                      │                                             │
│  [Clear all filters] │                                             │
└──────────────────────┴─────────────────────────────────────────────┘
```

#### Wine List Card — Anatomy (Mobile)

```
┌────────────────────────────────────────┐
│ [TYPE BADGE]   [READINESS BADGE]  [★★★]│  Row 1: badges + rating
│ Wine Name                          [N] │  Row 2: name + qty pill
│ Producer · Vintage Year                │  Row 3: producer · vintage
│ 📍 Storage Location Name               │  Row 4: location (CP-01)
└────────────────────────────────────────┘
```

- Type badge: JetBrains Mono UPPERCASE, color-coded pill (Red=Burgundy, White=Blue-gray, Rosé=Pink, etc.)
- Readiness badge: Per color table in Overview
- Rating: Stars (5-scale) or numeric (100-point) per user preference
- Qty pill: Bold JetBrains Mono; "EMPTY" label replaces number when qty=0
- Location: Open Sans 400, `#A8A59B`, truncated at 30 chars with ellipsis
- Cellar Empty cards: 40% opacity on type/readiness badges; gray qty pill; entire card at 70% opacity

#### Information Hierarchy

| Priority | Content | Placement |
|----------|---------|-----------|
| Primary | Wine Name, Quantity | Row 2, largest text |
| Primary | Readiness Status badge | Row 1, right of type |
| Secondary | Producer, Vintage | Row 3 |
| Secondary | Storage Location | Row 4, with pin icon |
| Tertiary | Rating (if present) | Row 1, far right |

#### States

| State | Appearance | User Feedback |
|-------|------------|---------------|
| Default | All cards rendered, newest first | N/A |
| Searching | Cards filter in real-time | Result count updates immediately |
| Filtering | Filter chips appear above list | "Showing N of Total wines" |
| No results | Empty state illustration | "No wines match your search. Try a different term or clear filters." |
| Empty collection | No cards | "Your cellar is empty. Tap '+' to add your first wine." + CTA |
| Cellar Empty wine | Muted card, EMPTY badge | Card still shown in list, visually de-emphasized |

#### Interactive Elements

| Element | Type | Behavior |
|---------|------|----------|
| Search bar | `usa-search` | Real-time client-side filter, 100ms debounce |
| Filter button | `usa-button--outline` | Opens filter panel (drawer/sidebar) |
| Sort control | `usa-select` | Re-sorts result set |
| Filter chip "×" | Icon button | Dismisses individual filter |
| "Clear all" | Link | Removes all panel filters (not search) |
| Wine card | Tappable | Navigates to Wine Detail |
| "+ Add" button | `usa-button` Gold | Opens Add Wine form |

---
