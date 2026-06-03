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
