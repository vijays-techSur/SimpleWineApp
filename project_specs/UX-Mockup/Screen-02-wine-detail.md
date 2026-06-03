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
