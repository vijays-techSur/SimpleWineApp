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
