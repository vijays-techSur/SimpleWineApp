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
