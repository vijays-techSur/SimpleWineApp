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
