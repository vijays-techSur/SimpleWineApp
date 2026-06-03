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
