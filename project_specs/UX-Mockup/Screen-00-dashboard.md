---

## Screen Designs

---

### Screen 00: Dashboard (Home)

**Purpose:** Landing view — answers "What do I have?" and "What should I drink next?" at a glance. The default view on app open.
**User Stories:** US-6.1, US-6.2, US-6.3, US-6.4, US-6.5, US-5.2, US-3.3

#### Mobile Wireframe (375px)

```
┌─────────────────────────────────────┐
│ ▓▓▓▓ HEADER (Black #0A0A0A) ▓▓▓▓▓▓ │
│  SimpleWineApp    [≡ menu]          │
├─────────────────────────────────────┤
│                                     │
│  SUMMARY STATS BAR                  │
│  ┌──────┐ ┌──────┐ ┌──────┐ ┌────┐ │
│  │  487 │ │  62  │ │  22  │ │ 31 │ │
│  │Botls │ │Wine  │ │Drink │ │Apch│ │
│  │      │ │Recrds│ │ Now  │ │Peak│ │
│  └──────┘ └──────┘ └──────┘ └────┘ │
│  (each tile tappable → filtered list)│
│                                     │
│  ── DRINK NOW SHELF ─────────────── │
│  [All · Red · White · Sparkling]    │  ← type pills (CP-04)
│  ┌────────┐ ┌────────┐ ┌────────┐  │
│  │Château │ │Sancerre│ │Crémant │  │
│  │Margaux │ │2021    │ │d'Alsace│  │
│  │2018 ●  │ │[DRINK] │ │2022 ●  │  │
│  │qty: 2  │ │qty: 1  │ │qty: 3  │  │
│  │Wine Fr.│ │Rack B  │ │Cellar  │  │
│  └────────┘ └────────┘ └────────┘  │
│  ← scroll horizontally →            │
│  [See all 22 →]                     │
│                                     │
│  ── COLLECTION BREAKDOWN ─────────── │
│  BY WINE TYPE                        │
│  Red      ████████████░░ 48  38%    │
│  White    ████████░░░░░░ 31  24%    │
│  Sparkling████░░░░░░░░░░ 18  14%    │
│  Rosé     ██░░░░░░░░░░░░  8   6%   │
│  Dessert  █░░░░░░░░░░░░░  3   2%   │
│  Fortifed █░░░░░░░░░░░░░  2   2%   │
│                                     │
│  BY COUNTRY / REGION (top 5)        │
│  France     92  38%    [→]          │
│  Italy      48  20%    [→]          │
│  Spain      31  13%    [→]          │
│  USA        28  11%    [→]          │
│  Portugal   15   6%    [→]          │
│  Other      18   7%    [→]          │
│                                     │
│  BY VINTAGE DECADE                  │
│  2020s  ██░░░░░░  42                │
│  2010s  ████████ 198                │
│  2000s  ████░░░░  89                │
│  1990s  ██░░░░░░  45                │
│                                     │
│  ── RECENTLY ADDED ──────────────── │
│  Barolo 2018 · Giacomo Conterno     │
│  Added 2 days ago         [→]       │
│  Sancerre 2021 · Vacheron           │
│  Added 5 days ago         [→]       │
│  ... (5 items)  [View all →]        │
│                                     │
│  ── RECENTLY CONSUMED ────────────── │
│  Crémant d'Alsace · 2022            │
│  Consumed 1 day ago       [→]       │
│  "No consumed bottles." (if empty)  │
│  [View all →]                       │
│                                     │
│  ── HIGHEST RATED ─────────────────  │
│  ★★★★★ Barolo 2015 · Mascarello     │
│  ★★★★☆ Burgundy 2016 · Leflaive    │
│  ... (top 5)                        │
│  "Rate your wines to see favorites" │
│                                     │
├─────────────────────────────────────┤
│ [Dashboard] [Cellar] [Settings]  [+]│  ← bottom nav + FAB
└─────────────────────────────────────┘
```

#### Information Hierarchy

| Priority | Content | Placement |
|----------|---------|-----------|
| Primary | Summary stats (4 tiles) | Top, always above fold |
| Primary | Drink Now shelf with type filters | Second section |
| Secondary | Collection breakdown (type, region, decade) | Third section, scrollable |
| Secondary | Recently Added / Recently Consumed | Fourth section |
| Tertiary | Highest Rated | Bottom section |

#### States

| State | Appearance | User Feedback |
|-------|------------|---------------|
| Default | All sections rendered with live data | N/A |
| Loading | Skeleton shimmer on stat tiles and cards | "Loading your cellar…" |
| Empty collection | All sections hidden; onboarding empty state | "Your cellar is empty. Tap '+' to add your first wine." + Gold "Add Wine" CTA |
| No rated wines | Highest Rated shows placeholder card | "Rate your wines to see your favorites here." |
| No consumed events | Recently Consumed shows placeholder | "No consumed bottles recorded yet." |
| No Drink Now wines | Shelf card shows placeholder | "No wines are ready to drink right now." (card still visible) |

#### Interactive Elements

| Element | Type | Behavior |
|---------|------|----------|
| Stat tile (×4) | Tappable card | Navigates to Wine List pre-filtered for that segment |
| Drink Now type pills | Horizontal filter pills | Filters shelf cards in-place; "All" resets |
| Drink Now shelf card | Tappable card | Navigates to Wine Detail |
| "See all [N]" | Link | Navigates to Wine List filtered by Drink Now |
| Breakdown row | Tappable row | Navigates to Wine List filtered for that segment |
| Recently Added row | Tappable row | Navigates to Wine Detail |
| Recently Consumed row | Tappable row | Navigates to Wine Detail |
| Highest Rated row | Tappable row | Navigates to Wine Detail |
| "+" FAB | Gold circle button | Opens Add Wine form |

---
