# User Stories
## SimpleWineApp — Personal Wine Collection Manager

**Project:** SimpleWineApp
**Version:** 1.0 — MVP
**Date:** 2026-06-03
**Status:** Draft
**Author:** Pivota Spec User Stories Generator
**PRD Reference:** PRD-SimpleWineApp.md v1.0
**FRD Reference:** FRD-SimpleWineApp.md v1.0
**Personas Reference:** PERSONAS-SimpleWineApp.md

---

## Priority Definitions

| Priority | Label | Meaning |
|----------|-------|---------|
| P0 | Critical | MVP cannot ship without this story |
| P1 | High | Strong MVP requirement; included in v1 release |
| P2 | Medium | Valuable addition; Phase 2 candidate |
| P3 | Low | Future enhancement; Phase 3+ candidate |

---

## Personas

| ID | Name | Role |
|----|------|------|
| PER-01 | Marcus T. | Casual Collector |
| PER-02 | Diane L. | Enthusiast |
| PER-03 | Priya S. | Home Entertainer |
| PER-04 | Richard A. | Serious Collector |

---

## Epic 0: Wine Inventory CRUD (F0)

The foundational capability for the entire application. All other features depend on wine records existing in the system.

---

### US-0.1: Add a New Wine Record
**As a** casual collector (Marcus T.), **I want to** add a new wine record quickly after a purchase, **so that** my collection stays up-to-date without interrupting my day.

**Acceptance Criteria:**
- [ ] A "+" floating action button (FAB) or "Add Wine" navigation action is visible from the main collection view
- [ ] The Add Wine form displays with required fields marked by an asterisk: Wine Name, Producer, Vintage Year, Wine Type, Quantity, Storage Location
- [ ] Optional fields are available: Country, Region, Appellation, Grape Variety, Bottle Size, Purchase Date, Purchase Source, Purchase Price, Estimated Value, Drinking Window Start, Drinking Window End, Notes
- [ ] Submitting the form with all required fields saves the record and navigates to the Wine Detail view
- [ ] A success toast displays: "Wine added to your cellar."
- [ ] A new `wine_id` (UUID), `created_at`, and `updated_at` are assigned automatically
- [ ] A new wine can be added in ≤ 60 seconds on mobile

**Priority:** P0 | **Feature Ref:** F0

---

### US-0.2: Browse the Wine Collection List
**As a** home entertainer (Priya S.), **I want to** see all my wines in a browsable list with key details, **so that** I can quickly scan what I have without opening each wine individually.

**Acceptance Criteria:**
- [ ] The Wine List is the main collection view, showing all wine records sorted by date added (newest first) by default
- [ ] Each entry shows: Wine Name, Producer, Vintage, Wine Type badge, Readiness Status badge, Quantity, Storage Location
- [ ] Mobile view renders wines as cards; desktop view renders as a table row with additional columns (Country, Region, Purchase Price)
- [ ] Wines with quantity = 0 ("Cellar Empty") are visually de-emphasized but still visible in the list
- [ ] The list renders within 300ms for collections up to 500 records on a mid-range mobile device
- [ ] Active filter chips are displayed above the list when any filters are applied
- [ ] If the collection has no wine records at all (brand-new user or all records deleted), the Wine List displays: "Your cellar is empty. Tap '+' to add your first wine." with a prominent "Add Wine" CTA button
- [ ] If the wine list fails to load due to an API error, an inline error banner displays: "Unable to load wines. Pull to refresh or try again." The "+" FAB remains accessible

**Priority:** P0 | **Feature Ref:** F0

---

### US-0.3: View Full Wine Record Detail
**As an** enthusiast (Diane L.), **I want to** view all fields and history for a single wine, **so that** I have a complete picture of that bottle in one place.

**Acceptance Criteria:**
- [ ] Tapping a wine card or row navigates to the Wine Detail view for that wine
- [ ] All fields are displayed, grouped by section: Identity, Provenance & Purchase, Storage, Drinking Window, Tasting Notes, Bottle Event Log
- [ ] The Readiness Status badge is displayed prominently in the header area
- [ ] Action buttons are visible: "Edit," "Open / Consume Bottle," "Add Tasting Note," "Delete"
- [ ] The view loads correctly for wines with no tasting notes and no bottle events
- [ ] If the wine detail fails to load due to an API error, an inline error banner displays: "Unable to load wine details. Pull to refresh or try again." Action buttons are hidden until data loads successfully

**Priority:** P0 | **Feature Ref:** F0

---

### US-0.4: Edit an Existing Wine Record
**As a** serious collector (Richard A.), **I want to** update any field on a wine record, **so that** I can correct mistakes or add details I skipped when first entering the wine.

**Acceptance Criteria:**
- [ ] Tapping "Edit" on the Wine Detail view opens the Edit Wine form pre-populated with all current field values
- [ ] All fields (required and optional) are editable
- [ ] Submitting the form with valid data saves the changes and updates `updated_at` to the current timestamp
- [ ] A success toast displays: "Wine record updated."
- [ ] The user is returned to the Wine Detail view after a successful save
- [ ] Validation errors show inline messages on the failed fields; the record is not saved

**Priority:** P0 | **Feature Ref:** F0

---

### US-0.5: Delete a Wine Record
**As a** casual collector (Marcus T.), **I want to** remove a wine record I no longer need, **so that** my collection list only contains wines I actually own or care to track.

**Acceptance Criteria:**
- [ ] Tapping "Delete" on the Wine Detail view presents a confirmation modal
- [ ] The modal reads: "Delete [Wine Name]? This will permanently remove this wine and all associated tasting notes. This cannot be undone." with "Cancel" and "Delete" buttons
- [ ] Confirming the delete removes the wine record, all its tasting notes, and all its bottle events (cascade delete)
- [ ] After deletion, the user is navigated to the Wine List view
- [ ] A success toast displays: "Wine record deleted."
- [ ] Cancelling the modal closes it with no changes made

**Priority:** P0 | **Feature Ref:** F0

---

### US-0.6: Form Validation on Add and Edit
**As a** casual collector (Marcus T.), **I want to** see clear inline error messages when I submit incomplete or invalid data, **so that** I know exactly what to fix before my wine is saved.

**Acceptance Criteria:**
- [ ] Required fields (Wine Name, Producer, Vintage Year, Wine Type, Quantity, Storage Location) are enforced; submitting without them shows field-specific error messages
- [ ] Vintage Year must be an integer between 1900 and (current year + 1); non-numeric or out-of-range input shows: "Vintage must be between 1900 and [current+1]."
- [ ] Quantity must be a positive integer ≥ 1; decimal or negative values are rejected
- [ ] If Drinking Window Start and End are both provided, Start must be ≤ End; violation shows: "Drink by start year must be before or equal to end year."
- [ ] Purchase Date cannot be in the future; violation shows: "Purchase date cannot be in the future."
- [ ] The form is not saved when any validation error is present; previously entered data is retained in the form

**Priority:** P0 | **Feature Ref:** F0

---

## Epic 1: Quantity & Bottle Status Tracking (F1)

Manages the lifecycle of individual bottle units — from initial quantity through consumption, gifting, or opening. Maintains an accurate live count of bottles in the cellar.

---

### US-1.1: Track and Adjust Bottle Quantity
**As a** casual collector (Marcus T.), **I want to** increment or decrement my bottle count with a single tap, **so that** my cellar count stays accurate without a lot of effort.

**Acceptance Criteria:**
- [ ] The Wine Detail view displays the current quantity flanked by "−" and "+" buttons
- [ ] Tapping "+" increments quantity by 1 and immediately updates the displayed count (max 9999)
- [ ] Tapping "−" decrements quantity by 1 when quantity > 0; no bottle event is logged for bare decrement
- [ ] The "−" button is disabled (greyed out, `aria-disabled="true"`) when quantity = 0; quantity cannot go below 0
- [ ] Quantity is displayed as a pill/badge on every wine list card

**Priority:** P0 | **Feature Ref:** F1

---

### US-1.2: Log a Consumed Bottle Event
**As an** enthusiast (Diane L.), **I want to** log when I consume a bottle, **so that** my quantity stays accurate and I can optionally record a tasting note immediately.

**Acceptance Criteria:**
- [ ] Tapping "Open / Consume Bottle" presents an action sheet with options: "Consumed," "Gifted," "Opened"
- [ ] Selecting "Consumed" opens a dialog with: Date consumed (defaults to today), Notes (optional, 500 char max), "Add Tasting Note?" toggle (defaults ON)
- [ ] Confirming decrements quantity by 1 and saves a bottle event record with `event_type = CONSUMED`
- [ ] If quantity reaches 0, the wine record is marked "Cellar Empty"
- [ ] If "Add Tasting Note?" is ON, the user is navigated to the Add Tasting Note form pre-linked to this event
- [ ] If "Add Tasting Note?" is OFF, a success toast shows: "Bottle marked as consumed."
- [ ] Logging a Consumed event is blocked when quantity = 0; the error message shows: "No bottles remain in the cellar for this wine."

**Priority:** P0 | **Feature Ref:** F1

---

### US-1.3: Log a Gifted or Opened Bottle Event
**As a** home entertainer (Priya S.), **I want to** log when I gift a bottle or open one without fully consuming it, **so that** my event log reflects what actually happened to each bottle.

**Acceptance Criteria:**
- [ ] Selecting "Gifted" opens a dialog with: Date gifted (defaults to today), Recipient (optional, 200 char max), Notes (optional, 500 char max)
- [ ] Confirming a Gift event decrements quantity by 1 and saves a `GIFTED` bottle event; if quantity reaches 0, wine is marked "Cellar Empty"
- [ ] Selecting "Opened" opens a dialog with: Date opened (defaults to today), Notes (optional, 500 char max)
- [ ] Confirming an Open event sets `is_open = true` on the wine record; quantity is NOT decremented
- [ ] An "Open" badge is displayed next to the wine name on the detail view while `is_open = true`
- [ ] The `is_open` flag is cleared when the user subsequently logs a Consumed or Gifted event
- [ ] Success toasts confirm: "Bottle marked as gifted." or the "Open" badge appears respectively
- [ ] Event dates cannot be in the future; violation shows: "Event date cannot be in the future."

**Priority:** P0 | **Feature Ref:** F1

---

### US-1.4: View Bottle Event History
**As a** serious collector (Richard A.), **I want to** see a chronological log of all bottle events for a wine, **so that** I can track its complete consumption history.

**Acceptance Criteria:**
- [ ] A "Bottle History" section appears on the Wine Detail view below the main fields
- [ ] Events are listed in reverse chronological order (most recent first)
- [ ] Each event row shows: event date, event type icon + label, optional notes or recipient
- [ ] Consumed events that have a linked tasting note display a "View tasting note" link
- [ ] If no events exist, the section displays: "No bottle events recorded yet."

**Priority:** P0 | **Feature Ref:** F1

---

## Epic 2: Storage Location Management (F2)

Allows users to define and manage named physical storage locations, assign wines to locations, and maintain accurate "where is it?" tracking.

---

### US-2.1: Create and Manage Storage Locations
**As a** serious collector (Richard A.), **I want to** define named storage locations for my cellar spaces, **so that** every bottle has a precise, searchable home.

**Acceptance Criteria:**
- [ ] A "Storage Locations" management screen is accessible from Settings
- [ ] Tapping "Add Location" prompts for a location name (max 100 characters)
- [ ] The new location name must be non-blank and unique (case-insensitive); duplicate names show: "A location with that name already exists."
- [ ] Successfully created locations are immediately available in the wine add/edit form's location dropdown
- [ ] A success message displays: "Location added."
- [ ] Existing locations can be renamed; renamed names must also pass uniqueness and length validation
- [ ] A success message displays: "Location renamed."

**Priority:** P0 | **Feature Ref:** F2

---

### US-2.2: Delete a Storage Location
**As a** serious collector (Richard A.), **I want to** remove obsolete storage locations, **so that** my location list stays clean and accurate.

**Acceptance Criteria:**
- [ ] Tapping "Delete" on a location row shows a confirmation modal: "Delete '[Location Name]'? [N] wine(s) assigned to this location will be marked as 'Location Unknown.' This cannot be undone."
- [ ] Confirming deletes the location; all wines that referenced it have `storage_location_id` set to NULL and `location_unknown` set to true
- [ ] A success message displays: "Location deleted. [N] wine(s) marked as Location Unknown."
- [ ] Cancelling the modal closes it with no changes made
- [ ] The confirmation modal always shows the number of affected wines before the user can confirm

**Priority:** P0 | **Feature Ref:** F2

---

### US-2.3: View All Storage Locations with Bottle Counts
**As a** serious collector (Richard A.), **I want to** see a list of all my locations with how many bottles are in each, **so that** I can understand the distribution of my collection across physical spaces.

**Acceptance Criteria:**
- [ ] The Storage Locations screen lists all user-defined locations, each showing: Location Name, Bottle Count (sum of quantity for wines at this location with quantity > 0)
- [ ] Locations with a bottle count of 0 are still shown
- [ ] If any wines have `location_unknown = true`, a synthetic "Location Unknown" entry appears at the top of the list with the count of affected wines
- [ ] The "Location Unknown" entry includes a "Reassign" link that filters the wine list to Location Unknown wines
- [ ] Each location row has "Edit" (rename) and "Delete" action buttons

**Priority:** P0 | **Feature Ref:** F2

---

### US-2.4: Assign a Storage Location to a Wine
**As a** casual collector (Marcus T.), **I want to** assign a storage location when adding or editing a wine, **so that** I always know where to find a specific bottle.

**Acceptance Criteria:**
- [ ] The Storage Location field is a required dropdown on the Add Wine and Edit Wine forms
- [ ] The dropdown lists all existing locations in alphabetical order
- [ ] On the Add Wine form, the dropdown automatically pre-selects the most recently used storage location from the current session; if no prior location exists, no default is pre-selected
- [ ] On the Edit Wine form, the dropdown pre-selects the wine's current assigned location
- [ ] A "Add new location..." option at the bottom of the dropdown opens the Create Location flow inline and returns with the new location pre-selected
- [ ] The form cannot be saved without a storage location selected
- [ ] Wines with `location_unknown = true` display a "Location Unknown" warning on the wine card and detail view

**Priority:** P0 | **Feature Ref:** F2

---

## Epic 3: Search & Filter (F3)

Provides fast, flexible discovery mechanisms to find the right bottle — whether searching by name or browsing by attributes like type, vintage, and readiness.

---

### US-3.1: Search the Collection with Real-Time Text Search
**As a** casual collector (Marcus T.), **I want to** type a name or producer into a search bar and see instant results, **so that** I can find a specific wine in seconds without scrolling through the whole list.

**Acceptance Criteria:**
- [ ] A search bar is permanently visible at the top of the Wine List view
- [ ] Typing updates the wine list in real time (client-side, debounced at 100ms after last keystroke)
- [ ] Search matches against `wine_name`, `producer`, `region`, `grape_variety`, and `occasion` (from the most recent tasting note for each wine); matching is case-insensitive and substring-based
- [ ] A "×" clear button appears in the search bar when text is present; tapping it clears the query and restores the full list
- [ ] If no wines match, the list shows: "No wines match your search. Try a different term or clear filters."
- [ ] Search results respect any simultaneously active panel filters (AND logic)

**Priority:** P0 | **Feature Ref:** F3

---

### US-3.2: Filter the Collection by Multiple Attributes
**As a** home entertainer (Priya S.), **I want to** filter my wines by type, region, vintage, readiness, and rating, **so that** I can surface the right bottle for a specific occasion in seconds.

**Acceptance Criteria:**
- [ ] A "Filter" button (funnel icon) opens the filter panel (bottom drawer on mobile; sidebar on desktop)
- [ ] Filter panel supports: Wine Type (multi-select), Producer (text with autocomplete), Country / Region (cascading selects), Vintage range (from/to year), Grape Variety (substring match), Storage Location (single-select), Drinking Readiness Status (multi-select), Rating Range (min/max)
- [ ] Multiple wine types and readiness statuses use OR logic within each filter; all filters combined use AND logic
- [ ] Vintage range shows inline error if from > to: "Start year must be before or equal to end year."
- [ ] Rating range shows inline error if min > max: "Min rating must be less than or equal to max rating."
- [ ] The result count label above the list reads: "Showing [N] of [Total] wines"
- [ ] Filter state persists for the browser session; resets on app close or hard refresh

**Priority:** P0 | **Feature Ref:** F3

---

### US-3.3: Manage Active Filters and Sort Results
**As an** enthusiast (Diane L.), **I want to** see my active filters as dismissible chips and sort my results by different dimensions, **so that** I stay in control of my view without losing track of what's applied.

**Acceptance Criteria:**
- [ ] One dismissible chip per active filter dimension appears above the wine list (e.g., "Type: Red, White", "Vintage: 2015–2020")
- [ ] Tapping a chip's "×" dismisses that individual filter
- [ ] A "Clear all" link appears next to the chips when any filter is active; tapping it clears all panel filters (does not clear the search bar)
- [ ] A sort control at the top-right of the list offers: Date Added (newest/oldest), Wine Name (A–Z / Z–A), Vintage (newest/oldest), Quantity (high/low), Rating (highest/lowest), Drinking Window End (soonest/latest first; wines with no end year sorted last)
- [ ] When the Drinking Readiness filter is set to "Drink Now" and no other sort has been explicitly selected, the sort automatically defaults to "Drinking Window End: Soonest first" so the most urgently expiring bottles surface at the top
- [ ] Selected sort applies after filtering/searching (sort is applied last)
- [ ] Selected sort persists for the session

**Priority:** P0 | **Feature Ref:** F3

---

## Epic 4: Tasting Notes & Personal Ratings (F4)

Enables users to record personal tasting experiences with sensory descriptors, ratings, and occasion context — building a searchable preference history over time.

---

### US-4.1: Add a Standalone Tasting Note
**As an** enthusiast (Diane L.), **I want to** add a tasting note to any wine in my collection, **so that** I can capture my impressions while they are fresh and build a searchable preference record.

**Acceptance Criteria:**
- [ ] An "Add Tasting Note" button is visible on the Wine Detail view
- [ ] The form includes: Date Tasted (required), Appearance (optional, 500 char max), Aroma (optional, 500 char max), Flavor / Palate (optional, 1000 char max), Finish (optional, 500 char max), Personal Rating, Would Buy Again (Yes/No/Maybe), Occasion (optional, 200 char max), Guest Feedback (optional, 500 char max)
- [ ] Date Tasted cannot be in the future; violation shows: "Tasting date cannot be in the future."
- [ ] Personal Rating on 5-star scale must be an integer 1–5; on 100-point scale must be an integer 1–100
- [ ] Saving a note updates the wine's `latest_rating` to the new note's rating if a rating was provided
- [ ] A success toast displays: "Tasting note saved."
- [ ] A full tasting note can be logged in ≤ 2 minutes on mobile

**Priority:** P1 | **Feature Ref:** F4

---

### US-4.2: Capture a Linked Tasting Note After Consuming a Bottle
**As an** enthusiast (Diane L.), **I want to** be prompted to add a tasting note immediately after logging a Consumed bottle event, **so that** my tasting impressions are captured in context and linked to the specific bottle I opened.

**Acceptance Criteria:**
- [ ] After confirming a Consumed bottle event with "Add Tasting Note?" toggled ON, the system navigates to the Add Tasting Note form
- [ ] The form is pre-populated with: `date_tasted = today` and the `bottle_event_id` of the consume event
- [ ] On the Bottle Event Log, the CONSUMED event row displays a "View tasting note" link after the note is saved
- [ ] The linked tasting note can only be linked to a CONSUMED event (not GIFTED or OPENED)

**Priority:** P1 | **Feature Ref:** F4

---

### US-4.3: View Tasting Note History for a Wine
**As a** serious collector (Richard A.), **I want to** see all my tasting notes for a wine in one place, **so that** I can review my impressions over time and track how the wine has evolved.

**Acceptance Criteria:**
- [ ] The Wine Detail view includes a "Tasting Notes" section showing all notes in reverse chronological order (most recent first)
- [ ] Each note entry shows: date tasted, personal rating (rendered as stars or number per user scale), would-buy-again state, occasion, and a truncated preview of flavor/palate text
- [ ] Full note details (appearance, aroma, flavor, finish, guest feedback) expand on tap
- [ ] Each note entry has "Edit" and "Delete" action buttons
- [ ] If no tasting notes exist, the section shows: "No tasting notes yet. Add one after your next bottle."

**Priority:** P1 | **Feature Ref:** F4

---

### US-4.4: Edit or Delete a Tasting Note
**As an** enthusiast (Diane L.), **I want to** correct or remove a tasting note I previously saved, **so that** my preference record remains accurate.

**Acceptance Criteria:**
- [ ] Tapping "Edit" on a note opens the form pre-populated with all current values; saving updates `updated_at` and recalculates the wine's `latest_rating` based on all remaining notes
- [ ] A success toast displays: "Tasting note updated."
- [ ] Tapping "Delete" shows a confirmation: "Delete this tasting note? This cannot be undone." with "Cancel" and "Delete" buttons
- [ ] Confirming a delete removes the note, recalculates the wine's `latest_rating` (set to next most recent note's rating, or NULL if no rated notes remain)
- [ ] A success toast displays: "Tasting note deleted."
- [ ] Cancelling the confirmation modal makes no changes

**Priority:** P1 | **Feature Ref:** F4

---

### US-4.5: Choose a Personal Rating Scale
**As an** enthusiast (Diane L.), **I want to** select whether I rate wines on a 1–5 star scale or a 1–100 point scale, **so that** ratings are recorded in the system that matches how I naturally think about wine.

**Acceptance Criteria:**
- [ ] Settings includes a "Rating Scale" option with two choices: "5-star (1–5)" and "100-point (1–100)"
- [ ] The selected scale applies globally to all rating inputs and displays throughout the app
- [ ] Existing ratings are stored as entered; switching scales does not convert existing rating values
- [ ] If scale is switched, existing ratings display with a label indicating which scale they were entered in (display only; no conversion)

**Priority:** P1 | **Feature Ref:** F4

---

### US-4.6: See Most Recent Rating on the Wine List
**As a** home entertainer (Priya S.), **I want to** see a wine's most recent personal rating on the wine list card, **so that** I can quickly identify my best-loved bottles without opening each one.

**Acceptance Criteria:**
- [ ] The wine list card displays the most recent personal rating (rendered as stars or numeric badge per user's scale) when at least one rated tasting note exists
- [ ] The rating shown corresponds to the most recent tasting note by `date_tasted`
- [ ] No rating indicator is shown on cards for wines with no rated tasting notes
- [ ] The rating on the wine detail view shows the most recent rating and its date near the top of the detail view

**Priority:** P1 | **Feature Ref:** F4

---

## Epic 5: Drinking Window Management (F5)

Automatically calculates and displays a readiness status for every wine, giving users an at-a-glance answer to "What should I drink now?" without manual tracking.

---

### US-5.1: Set Drinking Window on a Wine Record
**As a** serious collector (Richard A.), **I want to** enter a drinking window start and end year for a wine, **so that** the app can automatically calculate whether it's ready to drink.

**Acceptance Criteria:**
- [ ] The Add Wine and Edit Wine forms include optional Drinking Window Start Year and Drinking Window End Year fields
- [ ] Both fields accept integers in the range 1900–2200
- [ ] If both are provided, Start must be ≤ End; violation shows: "Drink by start year must be before or equal to end year."
- [ ] Either or both fields may be left blank; wines with no window entered receive "No Window Set" status
- [ ] Drinking window fields are part of the standard wine form — no separate form is required

**Priority:** P1 | **Feature Ref:** F5

---

### US-5.2: See Readiness Status Automatically Calculated and Displayed
**As an** enthusiast (Diane L.), **I want to** see a readiness status badge on every wine card and detail view, **so that** I always know at a glance which bottles are ready to drink now, which need more time, and which are past their peak.

**Acceptance Criteria:**
- [ ] Readiness status is calculated automatically on each app load using the current date and the wine's drinking window fields; no manual refresh is needed
- [ ] Five statuses are possible: Drink Now (current year within window), Approaching Peak (1–2 years before start), Hold (>2 years before start), Past Window (current year > end year), No Window Set
- [ ] Each status is displayed as a color-coded badge with a text label (color alone is never the sole differentiator — WCAG 2.1 AA)
- [ ] Badge appears on wine list cards and the wine detail view header
- [ ] Cellar Empty wines still display their readiness badge (in muted style) alongside the Cellar Empty label
- [ ] Readiness status is included in all API wine record responses as a calculated field; clients must not cache or persist this value

**Priority:** P1 | **Feature Ref:** F5

---

### US-5.3: Filter and Surface Wines by Readiness Status
**As a** home entertainer (Priya S.), **I want to** filter my collection by drinking readiness status, **so that** I can instantly see which bottles are ready to open tonight and which aren't.

**Acceptance Criteria:**
- [ ] The filter panel includes a multi-select "Drinking Readiness" filter with options: Drink Now, Approaching Peak, Hold, Past Window, No Window Set
- [ ] Selecting multiple readiness statuses returns wines matching any selected status (OR logic within filter)
- [ ] The Drink Now filter on the wine list is reachable in ≤ 3 taps from the home screen
- [ ] All readiness status filter options (Drink Now, Approaching Peak, Hold, Past Window, No Window Set) return only wines with quantity > 0 — wines with quantity = 0 are excluded from readiness filter results regardless of which status is selected

**Priority:** P1 | **Feature Ref:** F5

---

## Epic 6: Collection Dashboard & Insights (F6)

The home screen of the application — a lightweight summary that gives users an immediate picture of their collection and surfaces the most actionable bottles prominently.

---

### US-6.1: View Collection Summary Stats on the Dashboard
**As a** casual collector (Marcus T.), **I want to** see my collection's key numbers at a glance when I open the app, **so that** I always know where my cellar stands without any navigation.

**Acceptance Criteria:**
- [ ] The dashboard is the default landing view on app open
- [ ] A Summary Stats Bar at the top shows four tiles: Total Bottles (sum of quantity > 0), Wine Records (total count), Drink Now (count with status = DRINK_NOW and qty > 0), Approaching Peak (count with status = APPROACHING_PEAK and qty > 0)
- [ ] Each stat tile is tappable and navigates to the Wine List filtered for that segment
- [ ] Stats update on each app load; no manual refresh is required
- [ ] If the collection is completely empty, the dashboard shows an onboarding empty state: "Your cellar is empty. Tap '+' to add your first wine." with a prominent "Add Wine" CTA

**Priority:** P1 | **Feature Ref:** F6

---

### US-6.2: Browse the Drink Now Shelf
**As an** enthusiast (Diane L.), **I want to** see my "Drink Now" wines displayed prominently on the dashboard, **so that** I can choose the right bottle to open tonight without any searching.

**Acceptance Criteria:**
- [ ] The Drink Now Shelf shows up to 10 wine cards with `readiness_status = DRINK_NOW` and quantity > 0, sorted by `drink_window_end` ascending (soonest expiring first)
- [ ] Each shelf card displays: wine name, producer, vintage year, Drink Now badge, quantity, storage location
- [ ] The shelf is horizontally scrollable on mobile; may display as a 2-column grid on desktop
- [ ] A "See all [N]" link navigates to the Wine List filtered by Drink Now status
- [ ] If no Drink Now wines exist, the shelf card shows: "No wines are ready to drink right now." (card is still visible, not hidden)

**Priority:** P1 | **Feature Ref:** F6

---

### US-6.3: View Collection Breakdowns by Type, Region, and Vintage
**As a** serious collector (Richard A.), **I want to** see how my collection breaks down by wine type, country/region, and vintage decade, **so that** I understand the composition and balance of my cellar without manual counting.

**Acceptance Criteria:**
- [ ] A "By Wine Type" breakdown shows all six wine types (Red, White, Rosé, Sparkling, Dessert, Fortified) with bottle count and percentage of total; types with 0 bottles show count = 0
- [ ] A "By Country / Region" breakdown shows the top 5 country/region groups by bottle count plus an "Other" aggregate row; wines with no country/region are grouped under "Unknown Origin"
- [ ] A "By Vintage Decade" breakdown groups wines by decade (e.g., "2020s = 2020–2029") with bottle count and a simple proportional bar; only decades with at least one bottle are shown, sorted most recent first
- [ ] Tapping any row in any breakdown navigates to the Wine List filtered for that segment
- [ ] Percentages are calculated as (group_count / total_bottles) × 100, rounded to nearest integer

**Priority:** P1 | **Feature Ref:** F6

---

### US-6.4: Review Recently Added and Recently Consumed Wines
**As a** home entertainer (Priya S.), **I want to** see what I've recently added to and consumed from my cellar, **so that** I can keep tabs on my collection activity without browsing the full list.

**Acceptance Criteria:**
- [ ] A "Recently Added" section shows the 5 wine records with the most recent `created_at`, displaying: wine name, producer, vintage, wine type badge, date added (relative format: "2 days ago")
- [ ] A "Recently Consumed" section shows the 5 most recent `CONSUMED` bottle events, displaying: wine name, producer, vintage, date consumed (relative format)
- [ ] Tapping any row in either section navigates to the Wine Detail view for that wine
- [ ] "View all" links navigate to the Wine List sorted by Date Added (newest first) and filtered by wines with CONSUMED events respectively
- [ ] If no consumed events exist, Recently Consumed shows: "No consumed bottles recorded yet."

**Priority:** P1 | **Feature Ref:** F6

---

### US-6.5: Discover Highest Rated Wines on the Dashboard
**As an** enthusiast (Diane L.), **I want to** see my top-rated wines on the dashboard, **so that** I can quickly find my favorites when choosing a bottle for a special occasion.

**Acceptance Criteria:**
- [ ] A "Highest Rated" section shows the top 5 wine records by `latest_rating` (descending); ties broken by most recent rating date
- [ ] Each entry shows: wine name, producer, vintage, rating display (stars or numeric per user's scale preference)
- [ ] If fewer than 5 rated wines exist, all rated wines are shown
- [ ] If no wines have ratings, the card shows: "Rate your wines to see your favorites here."
- [ ] Tapping any entry navigates to the Wine Detail view for that wine
- [ ] Only wines with at least one tasting note containing a `personal_rating` are included

**Priority:** P1 | **Feature Ref:** F6

---

## Story Index

| Story ID | Title | Priority | Feature Ref | Primary Persona |
|----------|-------|----------|-------------|-----------------|
| US-0.1 | Add a New Wine Record | P0 | F0 | Marcus T. (Casual Collector) |
| US-0.2 | Browse the Wine Collection List | P0 | F0 | Priya S. (Home Entertainer) |
| US-0.3 | View Full Wine Record Detail | P0 | F0 | Diane L. (Enthusiast) |
| US-0.4 | Edit an Existing Wine Record | P0 | F0 | Richard A. (Serious Collector) |
| US-0.5 | Delete a Wine Record | P0 | F0 | Marcus T. (Casual Collector) |
| US-0.6 | Form Validation on Add and Edit | P0 | F0 | Marcus T. (Casual Collector) |
| US-1.1 | Track and Adjust Bottle Quantity | P0 | F1 | Marcus T. (Casual Collector) |
| US-1.2 | Log a Consumed Bottle Event | P0 | F1 | Diane L. (Enthusiast) |
| US-1.3 | Log a Gifted or Opened Bottle Event | P0 | F1 | Priya S. (Home Entertainer) |
| US-1.4 | View Bottle Event History | P0 | F1 | Richard A. (Serious Collector) |
| US-2.1 | Create and Manage Storage Locations | P0 | F2 | Richard A. (Serious Collector) |
| US-2.2 | Delete a Storage Location | P0 | F2 | Richard A. (Serious Collector) |
| US-2.3 | View All Storage Locations with Bottle Counts | P0 | F2 | Richard A. (Serious Collector) |
| US-2.4 | Assign a Storage Location to a Wine | P0 | F2 | Marcus T. (Casual Collector) |
| US-3.1 | Search the Collection with Real-Time Text Search | P0 | F3 | Marcus T. (Casual Collector) |
| US-3.2 | Filter the Collection by Multiple Attributes | P0 | F3 | Priya S. (Home Entertainer) |
| US-3.3 | Manage Active Filters and Sort Results | P0 | F3 | Diane L. (Enthusiast) |
| US-4.1 | Add a Standalone Tasting Note | P1 | F4 | Diane L. (Enthusiast) |
| US-4.2 | Capture a Linked Tasting Note After Consuming a Bottle | P1 | F4 | Diane L. (Enthusiast) |
| US-4.3 | View Tasting Note History for a Wine | P1 | F4 | Richard A. (Serious Collector) |
| US-4.4 | Edit or Delete a Tasting Note | P1 | F4 | Diane L. (Enthusiast) |
| US-4.5 | Choose a Personal Rating Scale | P1 | F4 | Diane L. (Enthusiast) |
| US-4.6 | See Most Recent Rating on the Wine List | P1 | F4 | Priya S. (Home Entertainer) |
| US-5.1 | Set Drinking Window on a Wine Record | P1 | F5 | Richard A. (Serious Collector) |
| US-5.2 | See Readiness Status Automatically Calculated and Displayed | P1 | F5 | Diane L. (Enthusiast) |
| US-5.3 | Filter and Surface Wines by Readiness Status | P1 | F5 | Priya S. (Home Entertainer) |
| US-6.1 | View Collection Summary Stats on the Dashboard | P1 | F6 | Marcus T. (Casual Collector) |
| US-6.2 | Browse the Drink Now Shelf | P1 | F6 | Diane L. (Enthusiast) |
| US-6.3 | View Collection Breakdowns by Type, Region, and Vintage | P1 | F6 | Richard A. (Serious Collector) |
| US-6.4 | Review Recently Added and Recently Consumed Wines | P1 | F6 | Priya S. (Home Entertainer) |
| US-6.5 | Discover Highest Rated Wines on the Dashboard | P1 | F6 | Diane L. (Enthusiast) |

---

## Priority Breakdown

| Priority | Story Count | Stories |
|----------|-------------|---------|
| P0 — Critical | 17 | US-0.1 through US-0.6, US-1.1 through US-1.4, US-2.1 through US-2.4, US-3.1 through US-3.3 |
| P1 — High | 14 | US-4.1 through US-4.6, US-5.1 through US-5.3, US-6.1 through US-6.5 |
| **Total** | **31** | **All MVP stories** |

---

*UserStories generated by Pivota Spec User Stories Generator · SimpleWineApp v1.0 MVP · 2026-06-03*
