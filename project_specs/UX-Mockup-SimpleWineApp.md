# UX Mockup
## SimpleWineApp — Personal Wine Collection Manager

**Project:** SimpleWineApp
**Generated:** 2026-06-03
**Based on:** UserStories-SimpleWineApp.md, JOURNEYS-SimpleWineApp.md, PRD-SimpleWineApp.md, FRD-SimpleWineApp.md
**UI Foundation:** USWDS components + TechSur brand overlay

---

## Overview

SimpleWineApp's UX is built around a single promise: answer the three core questions in seconds — *What wine do I have? Where is it stored? What should I drink next?* Every screen has one clear purpose. Navigation is direct. Data entry is fast. Discovery is immediate.

### Design Principles

1. **Speed over completeness** — required fields are the minimum; optional fields are always available but never blocking
2. **Location always visible** — storage location appears on every list card, not buried in detail views (Cross-Journey Pattern CP-01)
3. **Filter persistence** — changing one filter never clears others; chips are individually dismissible (CP-02)
4. **Tiered post-consume flow** — quick occasion note first, full tasting note second; serves all personas (CP-03)
5. **Drink Now shelf is typed** — horizontal type pills on the shelf so filtering never requires navigation (CP-04)
6. **Cellar Empty stays visible** — zero-quantity wines remain de-emphasized in the list, not hidden (CP-05)

### TechSur + USWDS Token Mapping

| Token | Value | Usage in App |
|-------|-------|-------------|
| `--color-gold-400` | `#FBCA5C` | Primary CTA buttons, Drink Now badge, FAB |
| `--color-gold-600` | `#B0832A` | Gold text on Bone backgrounds (contrast-safe) |
| `--color-canvas-dark` | `#0A0A0A` | App header/nav background, hero bands |
| `--color-bone` | `#FAFAF7` | Page background, card surfaces |
| `--color-paper` | `#F5F5F2` | Alt card surface, filter panel bg |
| `--color-ink` | `#1A1A1A` | Body text, primary labels |
| `--color-gray-400` | `#A8A59B` | Muted labels, Cellar Empty text, secondary info |
| `--font-display` | Montserrat 900 | Screen headings, section titles |
| `--font-accent` | Fraunces italic | Wine name on detail hero, accent emphasis |
| `--font-body` | Open Sans 400/600/700 | All body copy, form labels, descriptions |
| `--font-mono` | JetBrains Mono UPPERCASE | Badges, type labels, quantity pills, eyebrows |
| `--font-button` | Montserrat 700 UPPERCASE | All button text, +1px tracking |
| `--radius-button` | 2px | All button border radius |

### Readiness Status Badge Colors

| Status | Badge Color | Text | WCAG Note |
|--------|------------|------|-----------|
| DRINK NOW | Gold `#FBCA5C` bg / Black text | "DRINK NOW" | Text label required — color not sole differentiator |
| APPROACHING PEAK | Amber `#F5A623` bg / Black text | "APPROACHING" | Text label required |
| HOLD | Gray `#A8A59B` bg / Ink text | "HOLD" | Text label required |
| PAST WINDOW | Muted `#D0CEC8` bg / Gray text | "PAST WINDOW" | Text label required |
| NO WINDOW SET | Paper `#F5F5F2` bg / Gray text | "NO WINDOW" | Text label required |

### Screen Inventory

| Screen | Purpose | User Stories |
|--------|---------|-------------|
| Dashboard | Landing view — stats, Drink Now shelf, insights | US-6.1–6.5 |
| Collection List | Browse, search, filter all wines | US-0.2, US-3.1–3.3, US-4.6, US-5.2 |
| Wine Detail | Full record, actions, tasting notes, event log | US-0.3, US-1.1–1.4, US-4.3, US-5.2 |
| Add / Edit Wine Form | Create or update wine record | US-0.1, US-0.4, US-0.6, US-5.1, US-2.4 |
| Tasting Note Form | Capture tasting experience and rating | US-4.1, US-4.2, US-4.4 |
| Storage Locations | Manage named cellar locations | US-2.1–2.3 |
| Settings | Rating scale, app preferences | US-4.5 |

### Navigation Structure

```
┌──────────────────────────────────────────┐
│  NAV (usa-header / usa-nav)              │
│  Dashboard | My Cellar | Settings        │
│  [+ Add Wine] ← primary CTA             │
└──────────────────────────────────────────┘
        │           │           │
   Dashboard   Collection    Settings
                  List       (Storage
                              Locations,
                              Rating Scale)
        │
   Wine Detail ── Add Tasting Note
        │
   Edit Wine Form
        │
   Bottle Event Dialog (Consume / Gift / Open)
```

**Mobile Navigation:** Bottom tab bar (Dashboard · Cellar · Settings) + Gold FAB "+" floating above center tab

**Desktop Navigation:** `usa-header` with horizontal nav links; "+ Add Wine" button in top-right of header

---
---

## User Flows

---

### Flow 00: Add a Wine Record
**User Stories:** US-0.1, US-0.6, US-2.4, US-5.1
**Trigger:** User taps "+" FAB or "Add Wine" nav action
**Primary Persona:** Marcus T. (JRN-01.1), Richard A. (JRN-04.1)
**Target:** Complete in ≤ 60 seconds on mobile

```
[Dashboard or Collection List]
         │
         ▼ Tap "+" FAB or "Add Wine"
[Add Wine Form — Required Fields visible]
  Wine Name* / Producer* / Vintage* / Type*
  Quantity* / Storage Location* (dropdown)
         │
         ├── Location not in list?
         │         ▼
         │   [Inline Create Location modal]
         │   Enter name → Save → auto-select
         │         │
         │         ▼
         │   [Back to Add Wine Form]
         │         │
         ▼         ▼
[Optional Fields — visible, not collapsed]
  Country / Region / Grape / Bottle Size
  Purchase Date / Source / Price
  Drinking Window Start / End
  Notes
         │
         ▼ Tap "Add Wine" (primary CTA)
         │
         ├── Validation fails ──▶ [Inline errors on failed fields]
         │                         Form NOT cleared; data retained
         │                         Error: "Please correct the fields below"
         │
         ▼ Validation passes
[Wine Detail View — newly created record]
  Toast: "Wine added to your cellar." (bottom, 3s auto-dismiss)
```

**Steps:**
1. "+" FAB visible on every screen (bottom-right, Gold `#FBCA5C` circle, 56px, `usa-button`)
2. Form opens: required fields at top, optional fields below with clear visual grouping
3. Storage Location dropdown lists all locations alphabetically; "Add new location..." at bottom triggers inline modal
4. Drinking Window fields are optional; if both entered, Start must be ≤ End (inline error on blur)
5. Tapping "Add Wine" triggers full validation; errors shown inline with `usa-error-message` pattern
6. On success: navigate to Wine Detail; show success toast

---

### Flow 01: Browse and Find a Wine
**User Stories:** US-0.2, US-3.1, US-3.2, US-3.3, US-4.6, US-5.2
**Trigger:** User navigates to "My Cellar" tab or taps a stat tile on Dashboard
**Primary Persona:** Marcus T. (JRN-01.2), Priya S. (JRN-03.1)
**Target:** Locate a wine via search in ≤ 15 seconds

```
[Collection List — default: newest first]
  [Search bar — always visible at top]
  [Filter button] [Sort control] [Result count]
  [Active filter chips — if any]
  [Wine cards / table rows]
         │
         ├── Type in search bar
         │         ▼
         │   [Real-time results — 100ms debounce]
         │   Matches: wine_name, producer, region, grape
         │         │
         │         ├── No results ──▶ Empty state message
         │         │
         │         ▼
         │   [Filtered wine list + search]
         │
         ├── Tap Filter (funnel icon)
         │         ▼
         │   [Filter Panel — bottom drawer / sidebar]
         │   Wine Type (multi-check) | Producer (autocomplete)
         │   Country/Region (cascading) | Vintage range
         │   Grape (text) | Location (dropdown)
         │   Readiness (multi-check) | Rating range
         │         │
         │   Filters apply live as user interacts
         │         │
         │         ▼
         │   [Filter chips appear above list]
         │   Dismiss individual chip → removes that filter
         │   "Clear all" → removes all panel filters
         │
         ├── Tap sort control
         │         ▼
         │   [Sort dropdown]: Date Added / Name / Vintage /
         │   Quantity / Rating (asc/desc)
         │
         ▼ Tap any wine card or row
[Wine Detail View]
```

**Steps:**
1. Search bar is a `usa-search` component, always visible (not collapsible)
2. Filter button opens bottom drawer on mobile (`usa-modal` pattern), sidebar on desktop
3. Each filter applies immediately; no "Apply" button needed
4. Result count label: "Showing [N] of [Total] wines" uses JetBrains Mono UPPERCASE
5. Active filter chips: one per dimension, "×" dismiss; "Clear all" link when any active
6. Sort control: `usa-select` at top-right of list header

---

### Flow 02: Open / Consume a Bottle
**User Stories:** US-1.1, US-1.2, US-1.3, US-4.1, US-4.2
**Trigger:** User taps "Open / Consume Bottle" on Wine Detail
**Primary Persona:** Diane L. (JRN-02.1), Priya S. (JRN-03.2)

```
[Wine Detail View]
  Tap "Open / Consume Bottle"
         │
         ▼
[Action Sheet — 3 options]
  ┌─────────────────┐
  │  Consumed       │
  │  Gifted         │
  │  Opened         │
  │  [Cancel]       │
  └─────────────────┘
         │
         ├── "Consumed" ──▶ [Consume Dialog]
         │   Date consumed (today default)
         │   Notes (optional, 500 chars)
         │   "Add Tasting Note?" toggle (ON default)
         │         │
         │   [Confirm] → quantity −1
         │         │
         │         ├── Toggle ON ──▶ [Add Tasting Note Form]
         │         │                 (pre-filled: today, event link)
         │         │
         │         └── Toggle OFF ──▶ [Wine Detail]
         │                            Toast: "Bottle marked as consumed."
         │
         ├── "Gifted" ──▶ [Gift Dialog]
         │   Date gifted (today) / Recipient (opt) / Notes (opt)
         │   [Confirm] → quantity −1
         │   Toast: "Bottle marked as gifted."
         │
         └── "Opened" ──▶ [Open Dialog]
             Date opened (today) / Notes (opt)
             [Confirm] → is_open = true, NO qty change
             "OPEN" badge shown on detail view
```

**Error path:** If quantity = 0 when "Consumed" or "Gifted" selected:
→ Inline error: "No bottles remain in the cellar for this wine."

---

### Flow 03: Delete a Wine Record
**User Stories:** US-0.5
**Trigger:** User taps "Delete" on Wine Detail view
**Primary Persona:** Marcus T.

```
[Wine Detail View]
  Tap "Delete"
         │
         ▼
[Confirmation Modal — usa-modal]
  "Delete [Wine Name]?
   This will permanently remove this wine
   and all associated tasting notes.
   This cannot be undone."
  [Cancel]  [Delete] ← destructive, Ink fill
         │
         ├── Cancel ──▶ Modal closes; no change
         │
         └── Delete ──▶ Cascade delete (wine + notes + events)
                        Navigate to Collection List
                        Toast: "Wine record deleted."
```

---

### Flow 04: Add a Tasting Note
**User Stories:** US-4.1, US-4.2, US-4.4
**Trigger:** "Add Tasting Note" button on Wine Detail, or post-consume redirect
**Primary Persona:** Diane L. (JRN-02.1)
**Target:** Full note in ≤ 2 minutes on mobile

```
[Wine Detail View]
  Tap "Add Tasting Note"
         │  (or auto-navigated from Consume flow)
         ▼
[Tasting Note Form]
  Date Tasted* (required, not future)
  Appearance / Aroma / Flavor+Palate / Finish (optional text)
  Personal Rating (star picker or number input per scale)
  Would Buy Again? (Yes / No / Maybe toggle)
  Occasion (optional) / Guest Feedback (optional)
         │
         ▼ Tap "Save Note"
         │
         ├── Validation fails ──▶ Inline errors
         │
         └── Passes ──▶ [Wine Detail — Tasting Notes section]
                        New note at top of chronological list
                        Toast: "Tasting note saved."
                        wine.latest_rating updated
```

---

### Flow 05: Manage Storage Locations
**User Stories:** US-2.1, US-2.2, US-2.3
**Trigger:** Settings → Storage Locations
**Primary Persona:** Richard A.

```
[Settings Screen]
  Tap "Storage Locations"
         │
         ▼
[Storage Locations List]
  "Location Unknown" entry (if any) — top, with Reassign link
  [Location Name] — [Bottle Count] — [Edit] [Delete]
  [+ Add Location] button
         │
         ├── Add Location ──▶ [Inline text input modal]
         │   Name (max 100 chars) → Save
         │   Uniqueness check → Toast: "Location added."
         │
         ├── Edit (Rename) ──▶ [Pre-filled text input]
         │   → Toast: "Location renamed."
         │
         └── Delete ──▶ [Confirmation Modal]
             "Delete '[Name]'? [N] wine(s) will be marked
              as Location Unknown. This cannot be undone."
             [Cancel] [Delete]
             → Toast: "Location deleted. [N] wine(s) marked as Location Unknown."
```

---
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
---

### Screen 02: Wine Detail View

**Purpose:** Full record view for a single wine — all fields, actions, tasting notes, and bottle event history in one place.
**User Stories:** US-0.3, US-0.4, US-0.5, US-1.1, US-1.2, US-1.3, US-1.4, US-4.3, US-5.2

#### Mobile Wireframe (375px)

```
┌─────────────────────────────────────┐
│ ← Back to Cellar                    │  ← breadcrumb nav
├─────────────────────────────────────┤
│ ▓▓▓ HERO BAND (Black #0A0A0A) ▓▓▓▓ │
│                                     │
│  [RED]      [DRINK NOW]  [OPEN ●]  │  ← type · readiness · open badge
│  *Château Margaux*                  │  ← Fraunces italic, large
│  Margaux · 2018                     │  ← producer · vintage, Open Sans
│                                     │
│  Qty: − [2] +   📍 Wine Fridge      │  ← qty controls + location (hero)
│  ★★★★☆  Rated 2025-11-14           │  ← latest rating + date
│                                     │
│  [Edit]  [Open/Consume] [Add Note]  │  ← primary action row
│  [Delete ⚠]                         │  ← destructive, below
├─────────────────────────────────────┤
│                                     │
│  ── IDENTITY ─────────────────────  │
│  Wine Name    Château Margaux       │
│  Producer     Château Margaux       │
│  Vintage      2018                  │
│  Wine Type    Red                   │
│  Grape        Cabernet Sauvignon,   │
│               Merlot                │
│  Bottle Size  750ml                 │
│                                     │
│  ── PROVENANCE & PURCHASE ────────  │
│  Country      France                │
│  Region       Bordeaux              │
│  Appellation  Margaux AOC           │
│  Purchased    2022-03-15            │
│  Source       Chateau direct        │
│  Price        $185.00 / bottle      │
│  Est. Value   $210.00 / bottle      │
│                                     │
│  ── STORAGE ───────────────────────  │
│  Location     Wine Fridge — Top     │
│               Shelf                 │
│  Quantity     2 bottles             │
│                                     │
│  ── DRINKING WINDOW ───────────────  │
│  Window       2020 – 2035           │
│  Status       [DRINK NOW]           │
│                                     │
│  ── NOTES ─────────────────────────  │
│  "Great structure, will age well."  │
│                                     │
│  ── TASTING NOTES ─────────────────  │
│  ┌───────────────────────────────┐  │
│  │ ★★★★☆ · 2025-11-14          │  │
│  │ 🛒 Would buy again: YES       │  │
│  │ Occasion: Anniversary dinner  │  │
│  │ Cherry, tobacco, oak on nose… │  │
│  │ [Expand ▾]  [Edit] [Delete]   │  │
│  └───────────────────────────────┘  │
│  ┌───────────────────────────────┐  │
│  │ ★★★☆☆ · 2024-06-20          │  │
│  │ … [Expand ▾]  [Edit] [Delete] │  │
│  └───────────────────────────────┘  │
│  "No tasting notes yet. Add one     │
│   after your next bottle."          │
│                                     │
│  ── BOTTLE HISTORY ────────────────  │
│  [🍷] Consumed  2025-11-14          │
│       "Great evening."              │
│       View tasting note →           │
│  [🎁] Gifted    2024-12-25          │
│       To: Sarah & Tom               │
│  [🔓] Opened    2024-06-20          │
│  "No bottle events recorded yet."   │
│                                     │
└─────────────────────────────────────┘
```

#### Desktop Wireframe (1024px) — Two-Column

```
┌──────────────────────────────────────────────────────────────────┐
│ ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ HEADER ▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓▓ │
├──────────────────────────────────────────────────────────────────┤
│ ← My Cellar > Château Margaux                                    │
├────────────────────────┬─────────────────────────────────────────┤
│  LEFT COLUMN (60%)     │  RIGHT COLUMN (40%)                     │
│                        │                                         │
│  ▓▓▓ HERO BAND ▓▓▓▓▓▓ │  ACTIONS                                │
│  [RED] [DRINK NOW]     │  [Edit Wine]                            │
│  *Château Margaux*     │  [Open / Consume Bottle]                │
│  Margaux · 2018        │  [Add Tasting Note]                     │
│                        │  [Delete Wine ⚠]                        │
│  Qty: − [2] +          │                                         │
│  📍 Wine Fridge        │  QUICK STATS                            │
│  ★★★★☆  Nov 14, 2025 │  Total Qty:    2                        │
│                        │  Latest Rating: ★★★★☆                  │
│  ── IDENTITY ────────  │  Drink Window: 2020–2035               │
│  [field table]         │  Status:       DRINK NOW                │
│                        │                                         │
│  ── PROVENANCE ──────  │                                         │
│  [field table]         │                                         │
│                        │                                         │
│  ── TASTING NOTES ───  │                                         │
│  [note cards]          │                                         │
│                        │                                         │
│  ── BOTTLE HISTORY ──  │                                         │
│  [event rows]          │                                         │
└────────────────────────┴─────────────────────────────────────────┘
```

#### Information Hierarchy

| Priority | Content | Placement |
|----------|---------|-----------|
| Primary | Wine Name, Type, Readiness Status | Hero band, always above fold |
| Primary | Quantity controls, Storage Location | Hero band — answers "where is it?" immediately |
| Primary | Action buttons (Edit, Consume, Add Note) | Hero band, always visible |
| Secondary | Rating + date, Open badge | Hero band, secondary row |
| Secondary | Tasting Notes section | Below field groups |
| Tertiary | Full field sections (Identity, Provenance, etc.) | Scrollable body |
| Tertiary | Bottle History | Bottom of page |

#### States

| State | Appearance | User Feedback |
|-------|------------|---------------|
| Default | All sections rendered | N/A |
| Loading | Skeleton on hero band and sections | — |
| Cellar Empty (qty=0) | "CELLAR EMPTY" badge in hero; "−" btn disabled | "−" greyed, `aria-disabled="true"` |
| Open bottle | "OPEN" badge in hero band (Gold outline) | Badge displayed until Consumed/Gifted |
| No tasting notes | Tasting Notes section shows placeholder | "No tasting notes yet. Add one after your next bottle." |
| No bottle events | Bottle History shows placeholder | "No bottle events recorded yet." |
| Location Unknown | Warning banner below hero | "⚠ Location Unknown — reassign this wine to a storage location." |

#### Interactive Elements

| Element | Type | Behavior |
|---------|------|----------|
| "−" button | `usa-button--outline` small | Decrement qty; disabled at 0 (`aria-disabled`) |
| "+" button | `usa-button--outline` small | Increment qty; max 9999 |
| Edit | `usa-button--outline` | Opens Edit Wine form (pre-filled) |
| Open / Consume Bottle | `usa-button` Gold | Opens action sheet (Consumed / Gifted / Opened) |
| Add Tasting Note | `usa-button--outline` | Opens Tasting Note form |
| Delete | `usa-button--secondary` Destructive | Opens confirmation modal |
| Note expand/collapse | Chevron toggle | Reveals full note fields inline |
| Note "Edit" | Text link | Opens Tasting Note form (pre-filled) |
| Note "Delete" | Text link, destructive | Opens confirmation modal |
| Bottle event "View tasting note" | Link | Scrolls to or opens linked tasting note |

---
---

### Screen 03: Add / Edit Wine Form

**Purpose:** Create a new wine record or update an existing one. Optimized for speed — under 60 seconds on mobile for required fields only.
**User Stories:** US-0.1, US-0.4, US-0.6, US-2.4, US-5.1

#### Mobile Wireframe (375px)

```
┌─────────────────────────────────────┐
│ ← Cancel          Add Wine          │  ← Edit Wine when editing
│                                     │
├─────────────────────────────────────┤
│                                     │
│  ─── REQUIRED ─────────────────────  │  ← JetBrains Mono eyebrow
│                                     │
│  Wine Name *                        │
│  ┌───────────────────────────────┐  │
│  │ e.g., Château Margaux         │  │  ← usa-input
│  └───────────────────────────────┘  │
│  ⚠ Wine name is required.           │  ← usa-error-message (on error)
│                                     │
│  Producer / Winery *                │
│  ┌───────────────────────────────┐  │
│  │ e.g., Château Margaux         │  │
│  └───────────────────────────────┘  │
│                                     │
│  Vintage Year *                     │
│  ┌──────────┐                       │
│  │ 2018     │                       │  ← numeric input, 4-digit
│  └──────────┘                       │
│  ⚠ Vintage must be between 1900     │
│    and 2027.                        │
│                                     │
│  Wine Type *                        │
│  ○ Red  ○ White  ○ Rosé             │  ← usa-radio group
│  ○ Sparkling  ○ Dessert  ○ Fortified│
│                                     │
│  Quantity *                         │
│  ┌──────────┐                       │
│  │ 1        │                       │  ← integer input, min 1
│  └──────────┘                       │
│                                     │
│  Storage Location *                 │
│  ┌───────────────────────────────┐  │
│  │ [Select location...         ▾]│  │  ← usa-select
│  └───────────────────────────────┘  │
│    + Add new location...            │  ← inline create trigger
│                                     │
│  ─── OPTIONAL ─────────────────────  │
│                                     │
│  Country                            │
│  ┌───────────────────────────────┐  │
│  │ e.g., France                  │  │
│  └───────────────────────────────┘  │
│                                     │
│  Region                             │
│  ┌───────────────────────────────┐  │
│  │ e.g., Bordeaux                │  │
│  └───────────────────────────────┘  │
│                                     │
│  Appellation                        │
│  ┌───────────────────────────────┐  │
│  │ e.g., Margaux AOC             │  │
│  └───────────────────────────────┘  │
│                                     │
│  Grape Variety                      │
│  ┌───────────────────────────────┐  │
│  │ e.g., Cabernet Sauvignon      │  │
│  └───────────────────────────────┘  │
│                                     │
│  Bottle Size                        │
│  ○ 375ml  ● 750ml  ○ 1.5L  ○ 3L   │  ← default 750ml
│                                     │
│  ─── PURCHASE ─────────────────────  │
│                                     │
│  Purchase Date                      │
│  ┌───────────────────────────────┐  │
│  │ MM/DD/YYYY                    │  │  ← date picker, not future
│  └───────────────────────────────┘  │
│                                     │
│  Purchase Source                    │
│  ┌───────────────────────────────┐  │
│  │ e.g., Wine.com                │  │
│  └───────────────────────────────┘  │
│                                     │
│  Purchase Price (per bottle)        │
│  ┌──────────────┐                   │
│  │ $ 0.00       │                   │
│  └──────────────┘                   │
│                                     │
│  Estimated Value (per bottle)       │
│  ┌──────────────┐                   │
│  │ $ 0.00       │                   │
│  └──────────────┘                   │
│                                     │
│  ─── DRINKING WINDOW ──────────────  │
│                                     │
│  Start Year                         │
│  ┌──────────┐                       │
│  │ 2020     │                       │  ← integer 1900–2200
│  └──────────┘                       │
│                                     │
│  End Year                           │
│  ┌──────────┐                       │
│  │ 2035     │                       │  ← integer 1900–2200, ≥ start
│  └──────────┘                       │
│  ⚠ Drink by start year must be      │
│    before or equal to end year.     │
│                                     │
│  ─── NOTES ────────────────────────  │
│                                     │
│  Notes (optional)                   │
│  ┌───────────────────────────────┐  │
│  │                               │  │
│  │                               │  │  ← textarea, 5000 chars max
│  └───────────────────────────────┘  │
│                                     │
│  ┌───────────────────────────────┐  │
│  │      ADD WINE / SAVE WINE     │  │  ← Gold #FBCA5C, Montserrat 700
│  └───────────────────────────────┘  │
│             [Cancel]                │
│                                     │
└─────────────────────────────────────┘
```

#### Inline Create Location Modal

```
┌──────────────────────────────┐
│  Add Storage Location        │
│  ─────────────────────────── │
│  Location name *             │
│  ┌────────────────────────┐  │
│  │ e.g., Basement Cellar  │  │
│  └────────────────────────┘  │
│  ⚠ A location with that name │
│    already exists.           │
│  [Cancel]    [Add Location]  │
└──────────────────────────────┘
```

#### Field Grouping — Visual Sections

| Section | Fields | Section Style |
|---------|--------|---------------|
| REQUIRED | Wine Name, Producer, Vintage, Type, Quantity, Storage Location | Bone bg `#FAFAF7`, gold-600 eyebrow |
| OPTIONAL | Country, Region, Appellation, Grape, Bottle Size | Paper bg `#F5F5F2`, gray eyebrow |
| PURCHASE | Purchase Date, Source, Price, Est. Value | Paper bg `#F5F5F2`, gray eyebrow |
| DRINKING WINDOW | Start Year, End Year | Paper bg `#F5F5F2`, gray eyebrow |
| NOTES | Free text notes | Paper bg `#F5F5F2`, gray eyebrow |

#### Information Hierarchy

| Priority | Content | Placement |
|----------|---------|-----------|
| Primary | Required fields (6) | Top of form, Bone background |
| Secondary | Optional identity fields | After required, Paper background |
| Secondary | Purchase details | Third group |
| Tertiary | Drinking Window | Fourth group |
| Tertiary | Notes | Bottom of form |

#### States

| State | Appearance | User Feedback |
|-------|------------|---------------|
| Default (Add) | Empty form, required fields marked `*` | N/A |
| Default (Edit) | Form pre-filled with all existing values | N/A |
| Validation error | Failed fields get red border + `usa-error-message` | Field-specific messages inline |
| Saving | Button shows spinner, disabled | "Saving…" |
| Location creating | Inline modal open, form behind overlay | N/A |

#### Validation Rules Summary

| Field | Rule | Error Message |
|-------|------|---------------|
| Wine Name | Required, max 200 chars | "Wine name is required." |
| Producer | Required, max 200 chars | "Producer is required." |
| Vintage Year | Required, int 1900–(current+1) | "Vintage must be between 1900 and [year]." |
| Wine Type | Required, one of 6 | "Wine type is required." |
| Quantity | Required, int ≥ 1 | "Quantity must be at least 1." |
| Storage Location | Required, existing location | "Storage location is required." |
| Purchase Date | Optional, not future | "Purchase date cannot be in the future." |
| Drink Window Start ≤ End | Conditional | "Drink by start year must be before or equal to end year." |

#### Interactive Elements

| Element | Type | Behavior |
|---------|------|----------|
| "Add new location..." | Text link below select | Opens inline Create Location modal |
| Wine Type radio | `usa-radio` | Single select, 6 options |
| Bottle Size radio | `usa-radio` | Single select, 4 options, 750ml default |
| Vintage input | Numeric `usa-input` | 4-digit, validates on blur |
| Drinking Window inputs | Numeric `usa-input` × 2 | Cross-validates Start ≤ End on blur |
| "ADD WINE / SAVE WINE" | `usa-button` Gold primary | Validates all fields, submits |
| Cancel | `usa-button--ghost` | Returns to previous screen, no save |

---
---

### Screen 04: Tasting Note Form

**Purpose:** Capture personal tasting impressions, rating, and occasion context for a wine. Supports both standalone entry and post-consume linked entry.
**User Stories:** US-4.1, US-4.2, US-4.4, US-4.5

#### Mobile Wireframe (375px)

```
┌─────────────────────────────────────┐
│ ← Cancel        Add Tasting Note    │  ← "Edit Tasting Note" on edit
│                                     │
│  For: *Château Margaux* 2018        │  ← wine context, Fraunces italic
│  Linked event: Consumed 2025-11-14  │  ← shown only for linked notes
├─────────────────────────────────────┤
│                                     │
│  Date Tasted *                      │
│  ┌───────────────────────────────┐  │
│  │ 11/14/2025                    │  │  ← date picker; pre-fill=today
│  └───────────────────────────────┘  │
│  ⚠ Tasting date cannot be in the   │
│    future.                          │
│                                     │
│  Personal Rating                    │
│  ★ ★ ★ ★ ☆  (tap to set 1–5)      │  ← star picker (5-star scale)
│    OR                               │
│  ┌──────────────┐  /100             │  ← number input (100-pt scale)
│  │ 88           │                   │  ← shown per user's scale pref
│  └──────────────┘                   │
│                                     │
│  Would Buy Again?                   │
│  [Yes] [Maybe] [No]                 │  ← usa-button-group toggle
│                                     │
│  Occasion (optional)                │
│  ┌───────────────────────────────┐  │
│  │ e.g., Anniversary dinner      │  │  ← text, 200 chars max
│  └───────────────────────────────┘  │
│                                     │
│  ─── TASTING DETAILS (OPTIONAL) ──  │
│                                     │
│  Appearance                         │
│  ┌───────────────────────────────┐  │
│  │                               │  │  ← textarea, 500 chars
│  └───────────────────────────────┘  │
│                                     │
│  Aroma / Nose                       │
│  ┌───────────────────────────────┐  │
│  │ Cherry, tobacco, leather…     │  │  ← textarea, 500 chars
│  └───────────────────────────────┘  │
│                                     │
│  Flavor / Palate                    │
│  ┌───────────────────────────────┐  │
│  │                               │  │  ← textarea, 1000 chars
│  │                               │  │
│  └───────────────────────────────┘  │
│                                     │
│  Finish                             │
│  ┌───────────────────────────────┐  │
│  │                               │  │  ← textarea, 500 chars
│  └───────────────────────────────┘  │
│                                     │
│  Guest Feedback (optional)          │
│  ┌───────────────────────────────┐  │
│  │                               │  │  ← textarea, 500 chars
│  └───────────────────────────────┘  │
│                                     │
│  ┌───────────────────────────────┐  │
│  │         SAVE NOTE             │  │  ← Gold primary button
│  └───────────────────────────────┘  │
│             [Cancel]                │
│                                     │
└─────────────────────────────────────┘
```

#### Rating Input — Scale Variants

**5-Star Scale (default):**
```
Personal Rating
☆ ☆ ☆ ☆ ☆   ← tap any star to set; filled stars = Gold #FBCA5C
★ ★ ★ ★ ☆   ← 4 stars selected
```

**100-Point Scale (user preference):**
```
Personal Rating         (1–100 scale)
┌──────────────┐
│ 88           │  /100  ← numeric input, integer, 1–100
└──────────────┘
```

Scale indicator shown as JetBrains Mono label near the rating input. If user has switched scales since previous notes were entered, old notes display: "(5-star scale)" or "(100-pt scale)" label.

#### Tasting Note Card — List Display (on Wine Detail)

```
┌────────────────────────────────────────────┐
│ ★★★★☆  2025-11-14            [Edit] [Delete]│  ← rating · date · actions
│ 🛒 Would buy again: YES                     │
│ 🍽 Anniversary dinner                       │  ← occasion
│ Cherry, tobacco, leather on the nose…       │  ← flavor preview, truncated
│ [Show full note ▾]                          │  ← expand toggle
└────────────────────────────────────────────┘
```

**Expanded state:**
```
┌────────────────────────────────────────────┐
│ ★★★★☆  2025-11-14            [Edit] [Delete]│
│ 🛒 Would buy again: YES                     │
│ 🍽 Anniversary dinner                       │
│ Appearance: Deep ruby, clear               │
│ Aroma: Cherry, tobacco, leather…           │
│ Palate: Full-bodied, firm tannins…         │
│ Finish: Long, persistent, dry              │
│ Guest Feedback: "Loved it!"                │
│ [Hide note ▴]                              │
└────────────────────────────────────────────┘
```

#### Information Hierarchy

| Priority | Content | Placement |
|----------|---------|-----------|
| Primary | Wine context (name, vintage) | Top header band |
| Primary | Date Tasted, Personal Rating | First form fields |
| Primary | Would Buy Again toggle | Second field group |
| Secondary | Occasion | Third field |
| Tertiary | Tasting Details (Appearance, Aroma, etc.) | Collapsible section below fold |

#### States

| State | Appearance | User Feedback |
|-------|------------|---------------|
| Default (standalone) | Empty form, Date=today | N/A |
| Default (post-consume) | Date=today pre-filled, linked event shown | "Linked to: Consumed [date]" |
| Default (edit) | All fields pre-filled | N/A |
| Saving | Button spinner, disabled | "Saving…" |
| Success | Returns to Wine Detail; note at top | Toast: "Tasting note saved." |
| Date validation error | Red border on date field | "Tasting date cannot be in the future." |

#### Interactive Elements

| Element | Type | Behavior |
|---------|------|----------|
| Star rating picker | Custom (5 tappable stars, Gold fill) | Tap to set 1–5; tap again to change |
| 100-pt input | `usa-input` numeric | Integer 1–100; validates on blur |
| Would Buy Again | `usa-button-group` (3 toggles) | Mutually exclusive; tap to select |
| Date Tasted | `usa-date-picker` | Today's date default; future dates blocked |
| Textarea fields | `usa-textarea` | Character counts shown at 80% of limit |
| "SAVE NOTE" | `usa-button` Gold | Validates date, submits |
| Cancel | Ghost button | Returns to Wine Detail, no save |

---

### Screen 05: Storage Locations Management

**Purpose:** Define, view, rename, and delete named storage locations. Accessible from Settings.
**User Stories:** US-2.1, US-2.2, US-2.3

#### Mobile Wireframe (375px)

```
┌─────────────────────────────────────┐
│ ← Settings      Storage Locations   │
│                                     │
│  ⚠ LOCATION UNKNOWN  [3 wines]      │  ← synthetic entry at top
│     [Reassign wines →]              │  ← link → filtered wine list
│                                     │
│  ─────────────────────────────────  │
│                                     │
│  Wine Fridge — Top Shelf            │
│  12 bottles               [Edit][⛔]│
│                                     │
│  Basement Cellar — Rack A           │
│  48 bottles               [Edit][⛔]│
│                                     │
│  Basement Cellar — Rack C           │
│  12 bottles               [Edit][⛔]│
│                                     │
│  Kitchen Rack                       │
│  0 bottles                [Edit][⛔]│  ← 0-count still shown
│                                     │
│  ─────────────────────────────────  │
│                                     │
│  ┌───────────────────────────────┐  │
│  │        + ADD LOCATION         │  │  ← Gold primary button
│  └───────────────────────────────┘  │
│                                     │
└─────────────────────────────────────┘
```

#### States

| State | Appearance | User Feedback |
|-------|------------|---------------|
| Default | List of all locations with counts | N/A |
| No locations | Empty state | "No storage locations defined. Add one to get started." |
| Location Unknown present | Warning entry at top | "⚠ LOCATION UNKNOWN — [N] wine(s) need reassignment." |
| After delete | Deleted row disappears | Toast: "Location deleted. [N] wine(s) marked as Location Unknown." |
| Empty location (0 bottles) | Count shown as "0 bottles" in gray | Still shown, not hidden |

#### Delete Confirmation Modal

```
┌───────────────────────────────────────┐
│  Delete "Wine Fridge — Top Shelf"?    │
│                                       │
│  12 wine(s) assigned to this location │
│  will be marked as Location Unknown.  │
│  This cannot be undone.               │
│                                       │
│        [Cancel]    [Delete]           │
└───────────────────────────────────────┘
```

---
---

## Interaction Patterns

---

### Pattern 01: Toast Notifications

**When to use:** Confirming a completed action (save, delete, event logging). Not for errors.
**Behavior:**
- Appears at bottom of screen (mobile) or top-right (desktop)
- Auto-dismisses after 3 seconds
- Manually dismissable via "×" button
- One toast at a time; new toast replaces old if another action fires quickly
- Uses `usa-alert--success` USWDS pattern with TechSur styling

**Toast messages used in app:**
| Trigger | Message |
|---------|---------|
| Add Wine success | "Wine added to your cellar." |
| Edit Wine success | "Wine record updated." |
| Delete Wine success | "Wine record deleted." |
| Consume Bottle | "Bottle marked as consumed." |
| Gift Bottle | "Bottle marked as gifted." |
| Tasting Note saved | "Tasting note saved." |
| Tasting Note updated | "Tasting note updated." |
| Tasting Note deleted | "Tasting note deleted." |
| Location added | "Location added." |
| Location renamed | "Location renamed." |
| Location deleted | "Location deleted. [N] wine(s) marked as Location Unknown." |

---

### Pattern 02: Confirmation Modals (Destructive Actions)

**When to use:** Before any irreversible action — delete wine, delete location, delete tasting note.
**Behavior:**
- Uses `usa-modal` pattern
- Overlay dims background (50% black overlay)
- Focus trapped inside modal until dismissed
- "Cancel" is the first/default button; "Delete" is the second
- "Delete" button uses Ink `#1A1A1A` fill (not gold) to signal destructive intent
- Pressing Escape closes the modal (= Cancel)
- Body text always includes: what will be deleted, what is affected, "This cannot be undone."

**Examples used in app:**
```
Wine delete:
  "Delete [Wine Name]? This will permanently remove this wine
   and all associated tasting notes. This cannot be undone."
  [Cancel]  [Delete]

Location delete:
  "Delete '[Location Name]'? [N] wine(s) assigned to this
   location will be marked as 'Location Unknown.'
   This cannot be undone."
  [Cancel]  [Delete]

Tasting note delete:
  "Delete this tasting note? This cannot be undone."
  [Cancel]  [Delete]
```

---

### Pattern 03: Action Sheet (Bottle Events)

**When to use:** "Open / Consume Bottle" — presents mutually exclusive choices before going deeper.
**Behavior:**
- Mobile: slides up as bottom sheet (`usa-modal` variant)
- Desktop: dropdown menu below the action button
- Always includes "Cancel" as last option
- Selecting an option opens the corresponding dialog

**Structure:**
```
[Action Sheet]
  Consumed   ← proceeds to Consume dialog
  Gifted     ← proceeds to Gift dialog
  Opened     ← proceeds to Open dialog
  Cancel     ← dismisses
```

---

### Pattern 04: Inline Validation

**When to use:** All form fields — validate on blur (when user leaves the field), not on every keystroke. Re-validate on submit.
**Behavior:**
- Error border: USWDS error red on input border
- Error message: `usa-error-message` below the field in Open Sans, error red
- On fix: error clears on the next blur event (not live while typing)
- Cross-field validation (Drink Window Start/End, Vintage range in filter): validates on blur of the second field
- Form-level error: "Please correct the fields below." shown above the submit button if multiple fields fail

**USWDS components:**
- `usa-form-group--error` on the parent
- `usa-label` with asterisk for required fields (never placeholder-only labeling)
- `usa-error-message` for the message text

---

### Pattern 05: Filter Chips (Active Filters)

**When to use:** Whenever any filter is active in the Collection List view.
**Behavior:**
- One chip per filter dimension (not per value — "Type: Red, White" is one chip)
- Chip format: "[Dimension]: [Value(s)]" — JetBrains Mono text
- Each chip has an "×" dismiss icon (44×44px touch target)
- Dismissing a chip removes only that filter; all others persist (CP-02)
- "Clear all" link appears when any chip is visible; removes all panel filters but NOT the search bar text
- Filter chips scroll horizontally if they exceed the viewport width on mobile

**Visual:** Bone `#FAFAF7` background, Ink `#1A1A1A` text, 2px border `#A8A59B`, 2px radius

---

### Pattern 06: Quantity Controls (±)

**When to use:** Wine Detail view — quick quantity adjustment without logging an event.
**Behavior:**
- "−" and "+" buttons flank the quantity display
- Both are `usa-button--outline` with 44×44px touch targets
- "−" is disabled (`aria-disabled="true"`, greyed) when quantity = 0
- Updates quantity immediately on tap (optimistic UI); persists on `PATCH /wines/:id/quantity`
- Quantity display: JetBrains Mono bold, large size
- Note: bare +/− does NOT log a bottle event; use "Open / Consume Bottle" for logged events

```
  [ − ]  [  2  ]  [ + ]
          qty
```

---

### Pattern 07: Readiness Status Badge

**When to use:** On every wine card in the list and in the hero section of Wine Detail.
**Behavior:**
- Color-coded pill with text label (color is never the ONLY differentiator — WCAG 2.1 AA)
- JetBrains Mono UPPERCASE text
- Badge always present; if no window set, shows "NO WINDOW" in Paper color
- Cellar Empty wines display readiness badge in muted/desaturated style alongside "EMPTY" label
- Calculated fresh on each load — never cached

**Badge reference:**
```
[DRINK NOW]     Gold bg #FBCA5C  / Black text
[APPROACHING]   Amber bg #F5A623 / Black text
[HOLD]          Gray bg  #A8A59B / Ink text
[PAST WINDOW]   Muted bg #D0CEC8 / Gray text
[NO WINDOW]     Paper bg #F5F5F2 / Gray text
```

---

### Pattern 08: Empty State Design

**When to use:** Any list or section with no data to display.
**Behavior:**
- Never show a blank screen — always show a message and (where appropriate) a CTA
- Illustration or icon optional (simple, line-art style)
- Message: concise, first-person, actionable
- CTA: Gold primary button when user action is the obvious next step

**Empty states reference:**
| Context | Message | CTA |
|---------|---------|-----|
| Empty collection | "Your cellar is empty." | "Add Wine" |
| No search results | "No wines match your search. Try a different term or clear filters." | "Clear search" |
| No tasting notes | "No tasting notes yet. Add one after your next bottle." | "Add Tasting Note" |
| No bottle events | "No bottle events recorded yet." | — |
| No consumed events | "No consumed bottles recorded yet." | — |
| No rated wines | "Rate your wines to see your favorites here." | — |
| No Drink Now wines | "No wines are ready to drink right now." | — |

---

### Pattern 09: Drink Now Shelf — Type Filter Pills

**When to use:** Dashboard Drink Now shelf — allows persona to filter shelf without navigating away (CP-04).
**Behavior:**
- Horizontal row of pills: "All · Red · White · Rosé · Sparkling · Dessert · Fortified"
- Active pill: Gold `#FBCA5C` fill, Black text, 2px radius
- Inactive pill: Paper `#F5F5F2` fill, Ink text
- "All" is active by default; selecting a type activates it and deactivates "All"
- Filters shelf cards in-place (client-side, no navigation)
- Scroll horizontally if pills overflow viewport

---

### Pattern 10: Post-Consume Tiered Prompt (CP-03)

**When to use:** After logging a Consumed bottle event.
**Behavior:**
- Step 1 (quick): Consume dialog — Date + optional Notes + "Add Tasting Note?" toggle (ON by default)
- Step 2 (if toggle ON): Full Tasting Note form, pre-filled with today's date and linked event
- Step 2 (if toggle OFF): Return to Wine Detail with success toast
- Serves all personas: Marcus (toggle OFF = quick), Priya (one occasion field), Diane (full note)

---
---

## Responsive Considerations

---

### Breakpoints

| Name | Width | Target Device |
|------|-------|--------------|
| Mobile | 375px – 767px | iPhone SE, most Android phones |
| Tablet | 768px – 1023px | iPad, Android tablets, small laptops |
| Desktop | 1024px+ | Laptops, desktops, wide monitors |

---

### Dashboard

**Mobile (375px):**
- Summary stats: 2×2 grid of tiles (Total Bottles + Wine Records top row; Drink Now + Approaching Peak bottom row)
- Drink Now shelf: horizontal scroll of wine cards (single row, 160px card width)
- Type filter pills: horizontal scroll row above shelf
- Collection breakdowns: stacked vertical sections (Type, Country, Decade)
- Recently Added / Consumed / Highest Rated: vertical list, 5 items each

**Tablet (768px):**
- Summary stats: single row of 4 tiles
- Drink Now shelf: horizontal scroll, larger cards (200px)
- Collection breakdowns: 2-column layout (Type+Country left, Decade right)
- Recently sections: still vertical list

**Desktop (1024px+):**
- Summary stats: single row of 4 tiles, wider spacing
- Drink Now shelf: 2-column card grid (up to 6 visible before "See all")
- Collection breakdowns: 3-column layout (Type | Country | Decade)
- Recently Added / Consumed: side by side (50/50 columns)
- Highest Rated: 2-column list

---

### Collection List

**Mobile (375px):**
- Full-width search bar
- Filter button opens bottom drawer (full-width bottom sheet, 75vh max)
- Sort control: `usa-select` compact
- Wine list: single-column card layout
- Active filter chips: horizontal scroll if overflow

**Tablet (768px):**
- Search bar + filter + sort in single row header
- Filter panel: opens as sidebar (280px fixed, pushes content right)
- Wine list: single-column cards, wider cards

**Desktop (1024px+):**
- Filter panel: persistent left sidebar (280px), always visible
- Wine list: `usa-table` layout with columns: Name, Producer, Vintage, Type, Status, Qty, Location, Country, Region, Price
- Sortable column headers with `▲▼` indicators
- Row hover state with subtle highlight

---

### Wine Detail

**Mobile (375px):**
- Hero band: full-width, stacked info
- Qty controls + location: single row in hero
- Action buttons: horizontal row (Edit + Consume + Add Note), Delete below
- Sections: single column, full-width
- Tasting note cards: full-width, expandable

**Tablet (768px):**
- Hero band: full-width
- Sections: single column with wider padding

**Desktop (1024px+):**
- Two-column layout: 60% left (fields + notes + events) | 40% right (actions + quick stats)
- Actions panel: sticky on scroll (right column stays visible)
- Tasting note list: shows 2 notes side by side in a 2-column grid

---

### Add / Edit Wine Form

**Mobile (375px):**
- Full-width inputs, single column
- All optional fields visible and labeled (not hidden behind toggles)
- Section headers: Bone/Paper background bands for visual separation
- Bottle Size: 2×2 radio grid
- "Add Wine" button: full width, Gold

**Tablet (768px):**
- 2-column layout for short fields: Country | Region in one row; Start Year | End Year in one row
- Full-width for Wine Name, Producer, Notes

**Desktop (1024px+):**
- 2-column form layout for most fields
- 3-column radio for Wine Type (Red | White | Rosé on row 1; Sparkling | Dessert | Fortified on row 2)
- Form card centered, max-width 760px, with shadow on Bone page background

---

### Tasting Note Form

**Mobile (375px):**
- Single column, full-width textareas
- Star rating: 5 large tap targets (48×48px each)
- Would Buy Again: 3-button group, full width

**Tablet / Desktop:**
- 2-column grouping for Date + Rating side by side
- Occasion + Would Buy Again on same row
- Textarea sections remain full-width for comfortable text entry

---

### Navigation

**Mobile (375px):**
- Bottom tab bar: Dashboard | Cellar | Settings (3 tabs)
- Gold "+" FAB floats above center of bottom nav (64px circle, elevation shadow)
- Tab labels: JetBrains Mono UPPERCASE 10px
- Active tab: Gold `#FBCA5C` icon + label
- No hamburger menu — all primary nav at bottom

**Tablet (768px):**
- Top `usa-header` with horizontal nav links
- "+" becomes a Gold "Add Wine" button in the nav bar (no FAB)
- Hamburger optional if content doesn't fit

**Desktop (1024px+):**
- Persistent `usa-header` with logo + nav links + "Add Wine" CTA button (Gold, top-right)
- No bottom nav

---

### Touch Target Requirements (USWDS Minimum)

All interactive elements must meet the 44×44px minimum touch target:
- Quantity −/+ buttons: 44×44px (icon centered in larger tap area)
- Filter chip dismiss "×": 44×44px
- Tasting note star tap areas: 48×48px (slightly larger for precision)
- Nav tab items: full tab width × 48px height
- FAB: 64×64px (exceeds minimum)
- List card rows: full width × 72px min height (card tap area)

---
---

## Accessibility Notes

**Baseline:** WCAG 2.1 AA compliance required for all components, enforced via USWDS foundation.

---

### Color Contrast

| Foreground | Background | Ratio | Status |
|-----------|-----------|-------|--------|
| Ink `#1A1A1A` | Bone `#FAFAF7` | 17.4:1 | ✅ AAA |
| Ink `#1A1A1A` | Paper `#F5F5F2` | 16.9:1 | ✅ AAA |
| Black `#0A0A0A` | Gold `#FBCA5C` | 9.6:1 | ✅ AAA |
| Gold-600 `#B0832A` | Bone `#FAFAF7` | 4.7:1 | ✅ AA |
| White `#FFFFFF` | Black `#0A0A0A` | 21:1 | ✅ AAA |
| Black `#0A0A0A` | Amber `#F5A623` | 8.3:1 | ✅ AAA |
| Ink `#1A1A1A` | Gray `#A8A59B` | 2.4:1 | ⚠ Fail — use only for decorative/non-text |

**Critical rule:** Gold 400 `#FBCA5C` text MUST NOT appear on Bone `#FAFAF7` backgrounds (contrast ratio ~2.2:1 — fails AA). Use Gold 600 `#B0832A` for any gold-colored text on light backgrounds.

**Status badges — color alone is never the sole differentiator:**
- Every readiness badge (DRINK NOW, HOLD, etc.) includes a text label
- Badge color + icon + text label = three independent differentiators
- All badge text meets minimum 4.5:1 contrast against badge background

---

### Keyboard Navigation

| Screen / Element | Keyboard Behavior |
|-----------------|------------------|
| All forms | Tab order follows visual top-to-bottom, left-to-right |
| Wine list cards | Arrow keys navigate between cards; Enter opens Wine Detail |
| FAB "+" button | Reachable via Tab; Enter/Space activates |
| Filter panel | Focus moves into panel on open; Escape closes without applying changes |
| Confirmation modal | Focus trapped inside modal; Tab cycles Cancel → Delete → Cancel; Escape = Cancel |
| Action sheet | Escape dismisses; Arrow keys navigate options; Enter selects |
| Star rating picker | Left/Right arrows adjust rating; Home = 1, End = 5 |
| Quantity −/+ buttons | Tab to each; Enter/Space activates; disabled "−" is `aria-disabled="true"` and excluded from Tab order |
| Drink Now type pills | Arrow keys navigate between pills; Enter/Space selects |
| Filter chips | Tab to each chip; Delete/Backspace or Enter on "×" dismisses |
| Tasting note expand | Enter/Space toggles expand/collapse |

**Focus management:**
- Opening a modal: focus moves to the first interactive element inside the modal
- Closing a modal: focus returns to the element that triggered it
- Navigating to a new screen: focus moves to the `<h1>` of the new view

---

### Screen Reader Considerations

**ARIA labels and roles:**

| Element | ARIA Pattern |
|---------|-------------|
| Wine list | `role="list"` on `<ul>`; each card `role="listitem"` |
| Readiness badge | `role="status"` or `<span aria-label="Readiness: Drink Now">DRINK NOW</span>` |
| Quantity "−" button | `aria-label="Decrease quantity"` + `aria-disabled="true"` when qty=0 |
| Quantity "+" button | `aria-label="Increase quantity"` |
| Star rating | `role="radiogroup"` with `aria-label="Personal rating"`, each star `role="radio"` with `aria-label="N stars"` |
| Would Buy Again toggle | `role="group"` with `aria-label="Would you buy this again?"` |
| Filter chip dismiss "×" | `aria-label="Remove [filter name] filter"` |
| "Clear all" filters link | `aria-label="Clear all active filters"` |
| FAB "+" | `aria-label="Add new wine"` |
| Toast notification | `role="status"` or `role="alert"` (alert for errors); `aria-live="polite"` |
| Confirmation modal | `role="dialog"` with `aria-modal="true"` and `aria-labelledby` pointing to modal title |
| Filter panel | `role="complementary"` or `role="dialog"` on mobile drawer with `aria-label="Filter wines"` |
| Cellar Empty card | Screen reader should announce: "[Wine Name], Cellar Empty, 0 bottles" |
| Loading state | `aria-busy="true"` on list container; hidden loading text via `aria-live` region |
| Location Unknown warning | `role="alert"` for the warning banner on Wine Detail |

**Quantity pill on list cards:** Announce as "[N] bottles" not just "[N]". Use `aria-label="[N] bottles"` on the qty pill element.

**Search results count:** The "Showing N of Total wines" label should use `aria-live="polite"` so screen readers announce the updated count after filtering.

**Wine type radio group on form:** Use `<fieldset>` with `<legend>Wine Type</legend>` — USWDS `usa-fieldset` and `usa-legend` pattern.

---

### USWDS Component Accessibility Baselines

All components must use USWDS's built-in accessibility foundations:

| USWDS Component | Used For |
|----------------|----------|
| `usa-button` | All buttons; inherits correct `type`, focus ring, and color contrast |
| `usa-form` / `usa-form-group` | All forms; ensures label-input association |
| `usa-label` | All form field labels; never placeholder-only |
| `usa-input` | Text inputs; correct `autocomplete` attributes where applicable |
| `usa-select` | Dropdowns; accessible keyboard nav |
| `usa-radio` | Wine type and bottle size selectors |
| `usa-checkbox` | Multi-select filter checkboxes |
| `usa-modal` | Confirmation modals and action sheets; includes focus trap |
| `usa-alert` | Toast notifications; `role="alert"` variant for errors |
| `usa-search` | Search bar; includes built-in label and clear button pattern |
| `usa-card` | Wine list cards; uses correct heading hierarchy |
| `usa-date-picker` | Date Tasted, Purchase Date; keyboard-accessible date picker |
| `usa-header` / `usa-nav` | App navigation; skip-link to main content |

**Skip navigation:** A "Skip to main content" link must be the first focusable element on every page (standard USWDS header pattern).

**Heading hierarchy:** Each screen maintains a single `<h1>` (screen title), with section headings as `<h2>` and sub-sections as `<h3>`. No heading levels are skipped.

**Images and icons:** All icon-only buttons have `aria-label`. Decorative icons have `aria-hidden="true"`. Wine type icons (if used) have `alt` text or `aria-label`.

---

### Motion and Animation

- All animations respect `prefers-reduced-motion: reduce` — transitions collapse to instant
- Bottom sheet drawer: slide-up animation disabled under reduced motion; sheet appears instantly
- Toast: fade-in/fade-out replaced with instant appear/disappear under reduced motion
- Loading skeleton shimmer: replaced with static skeleton under reduced motion

---

*UX Mockup generated by Pivota UX Design Partner · SimpleWineApp v1.0 MVP · 2026-06-03*
