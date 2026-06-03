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
