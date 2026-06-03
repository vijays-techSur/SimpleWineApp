# Requirements Traceability Matrix
## SimpleWineApp — Personal Wine Collection Manager

**Project:** SimpleWineApp  
**RTM Version:** 1.0  
**PRD Reference:** PRD-SimpleWineApp.md v1.0  
**FRD Reference:** FRD-SimpleWineApp.md v1.0  
**TechArch Reference:** TechArch-SimpleWineApp.md v1.0  
**UserStories Reference:** UserStories-SimpleWineApp.md v1.0  
**Date:** 2026-06-03  
**Status:** Draft  
**Author:** Pivota Spec RTM Generator

---

## 1. Overview

This Requirements Traceability Matrix (RTM) provides bidirectional traceability between all SimpleWineApp specification documents. It ensures every product requirement is reflected in functional specifications, implemented via a defined technical architecture, exercised by user stories, and verified by test cases. The RTM serves as the single authoritative cross-reference for the MVP v1.0 release.

Traceability in this document is organized across four levels. The **PRD level** defines seven features (F0–F6) that constitute the MVP scope, each with a priority classification (P0 Critical or P1 High). The **FRD level** decomposes each PRD feature into named sub-features (e.g., F00.1–F00.6) with full behavioral specifications including inputs, outputs, validation rules, error states, and API/schema surface. The **TechArch level** maps each feature to architectural decision records (ADR-001–ADR-008), API endpoints (22 in total), database tables, and React component groups. The **User Story level** provides 31 stories (US-0.1–US-6.5) organized into seven epics, each with acceptance criteria that serve as the basis for test case definition.

The matrix is designed to support three use cases: forward traceability (confirming every requirement flows through to implementation), backward traceability (confirming every implementation artifact has a requirement justification), and change impact analysis (identifying which stories, specs, and tests are affected by a proposed scope change).

---

## 2. Requirements Summary

### 2.1 PRD Feature Inventory

- **F0 — Wine Inventory CRUD** (P0 Critical): Core data management — add, view, edit, and delete wine records with 20+ structured fields. Foundation for all other features.
- **F1 — Quantity & Bottle Status Tracking** (P0 Critical): Manage physical bottle count per wine; log Consumed, Gifted, and Opened events with event history.
- **F2 — Storage Location Management** (P0 Critical): User-defined named storage locations; assign per wine; handle location deletions gracefully with "Location Unknown" flagging.
- **F3 — Search & Filter** (P0 Critical): Full-text client-side search; multi-attribute filter panel (wine type, producer, region, vintage, grape, location, readiness, rating); dismissible filter chips; sort controls.
- **F4 — Tasting Notes & Personal Ratings** (P1 High): Personal tasting records with sensory fields, 1–5 star or 1–100 point rating, would-buy-again toggle; multiple notes per wine; latest rating denormalized for list display.
- **F5 — Drinking Window Management** (P1 High): Auto-calculated readiness status (Drink Now, Approaching Peak, Hold, Past Window, No Window Set) from stored start/end year and current date; color-coded badge display.
- **F6 — Collection Dashboard & Insights** (P1 High): Home screen with summary stats bar, Drink Now shelf, collection breakdowns by type/region/decade, recently added, recently consumed, and highest rated cards.

### 2.2 FRD Sub-Feature Count by Epic

- **F00 (Wine CRUD):** 6 sub-features — F00.1 Add Wine, F00.2 List View, F00.3 Detail View, F00.4 Edit Wine, F00.5 Delete Wine, F00.6 Form Validation
- **F01 (Bottle Status):** 7 sub-features — F01.1 Display Quantity, F01.2 Increment/Decrement, F01.3 Log Consume, F01.4 Log Gift, F01.5 Log Open, F01.6 Cellar Empty, F01.7 Event Log
- **F02 (Storage Locations):** 6 sub-features — F02.1 Create Location, F02.2 Rename Location, F02.3 Delete Location, F02.4 Assign Location, F02.5 Filter by Location, F02.6 Location List View
- **F03 (Search & Filter):** 12 sub-features — F03.1 Full-Text Search through F03.12 Sort Controls
- **F04 (Tasting Notes):** 7 sub-features — F04.1 Add Note, F04.2 Linked Note, F04.3 View History, F04.4 Edit Note, F04.5 Delete Note, F04.6 Rating Scale Preference, F04.7 Rating Display
- **F05 (Drinking Window):** 5 sub-features — F05.1 Window Entry, F05.2 Status Calculation, F05.3 Badge Display, F05.4 Drink Now Integration, F05.5 Filter Integration
- **F06 (Dashboard):** 9 sub-features — F06.1 Stats Bar through F06.9 Dashboard Navigation

### 2.3 TechArch Scope Summary

- **Architecture pattern:** Next.js 14+ App Router full-stack monolith (ADR-001)
- **Database:** PostgreSQL 15+ primary, SQLite alternative (ADR-002)
- **Query layer:** Raw SQL via node-postgres — no ORM (ADR-003)
- **Client filter:** In-memory Fuse.js for ≤500 records (ADR-004)
- **Privacy:** Self-hosted fonts, no CDN, no analytics (ADR-005)
- **Auth:** None in v1 (ADR-006)
- **Readiness calculation:** Pure function at response time, never cached (ADR-007)
- **Rating denormalization:** `latest_rating` maintained on `wines` table (ADR-008)
- **API endpoints:** 22 REST endpoints at `/api/v1`
- **Database tables:** `wines`, `storage_locations`, `bottle_events`, `tasting_notes`, `user_settings`
- **React component groups:** Navigation Shell, Wine List & Cards, Search & Filter, Wine Forms, Tasting Notes, Wine Detail, Dashboard, Storage Locations, Shared/System

### 2.4 User Story Count by Epic

| Epic | Feature | Priority | Story Count |
|------|---------|----------|-------------|
| Epic 0 | Wine Inventory CRUD (F0) | P0 | 6 stories |
| Epic 1 | Quantity & Bottle Status (F1) | P0 | 4 stories |
| Epic 2 | Storage Location Management (F2) | P0 | 4 stories |
| Epic 3 | Search & Filter (F3) | P0 | 3 stories |
| Epic 4 | Tasting Notes & Ratings (F4) | P1 | 6 stories |
| Epic 5 | Drinking Window Management (F5) | P1 | 3 stories |
| Epic 6 | Collection Dashboard (F6) | P1 | 5 stories |
| **Total** | | | **31 stories** |

### 2.5 Non-Functional Requirements

- **Performance:** Wine list renders ≤300ms for 500 records; search/filter updates ≤100ms (client-side)
- **Accessibility:** WCAG 2.1 AA compliance via USWDS baseline; all readiness badges include text labels; all form fields have visible labels
- **Responsiveness:** Fully functional at 375px, 768px, 1024px, 1280px viewport widths; mobile-first
- **Data Integrity:** Quantity never below zero; required fields enforced; destructive actions require confirmation
- **Privacy:** No third-party analytics; no CDN calls; all data stays in user's own database instance
- **Offline:** Core wine list read and search functional offline via Service Worker (progressive enhancement)
- **Browser Support:** Latest 2 versions of Chrome, Firefox, Safari, Edge

---

## 3. Traceability Matrix

### 3.1 PRD Feature → FRD Sub-Features → TechArch Components → User Stories

| PRD Feature | Priority | FRD Sub-Features | TechArch Arch Decision | TechArch API Endpoints | TechArch DB Tables | TechArch React Components | User Stories |
|-------------|----------|-----------------|------------------------|------------------------|-------------------|--------------------------|-------------|
| **F0: Wine Inventory CRUD** | P0 | F00.1 Add Wine<br>F00.2 Wine List View<br>F00.3 Wine Detail View<br>F00.4 Edit Wine<br>F00.5 Delete Wine<br>F00.6 Form Validation | ADR-001 (Next.js)<br>ADR-002 (PostgreSQL)<br>ADR-003 (Raw SQL) | GET /api/v1/wines<br>POST /api/v1/wines<br>GET /api/v1/wines/:wine_id<br>PUT /api/v1/wines/:wine_id<br>PATCH /api/v1/wines/:wine_id<br>DELETE /api/v1/wines/:wine_id | `wines`<br>`storage_locations` | WineListPage<br>WineCard<br>WineTableRow<br>WineDetailPage<br>WineForm<br>FormSection<br>ConfirmationModal<br>ToastNotification<br>EmptyState | US-0.1, US-0.2, US-0.3, US-0.4, US-0.5, US-0.6 |
| **F1: Quantity & Bottle Status Tracking** | P0 | F01.1 Display Quantity<br>F01.2 Increment/Decrement<br>F01.3 Log Consume<br>F01.4 Log Gift<br>F01.5 Log Open<br>F01.6 Cellar Empty<br>F01.7 Bottle Event Log | ADR-001 (Next.js)<br>ADR-002 (PostgreSQL)<br>ADR-003 (Raw SQL) | POST /api/v1/wines/:wine_id/events<br>GET /api/v1/wines/:wine_id/events<br>PATCH /api/v1/wines/:wine_id/quantity | `wines` (quantity, is_open)<br>`bottle_events` | QuantityPill<br>QuantityControls<br>BottleEventSheet<br>ConsumeEventDialog<br>GiftEventDialog<br>OpenEventDialog<br>BottleHistorySection<br>BottleEventRow | US-1.1, US-1.2, US-1.3, US-1.4 |
| **F2: Storage Location Management** | P0 | F02.1 Create Location<br>F02.2 Rename Location<br>F02.3 Delete Location<br>F02.4 Assign Location<br>F02.5 Filter by Location<br>F02.6 Location List View | ADR-001 (Next.js)<br>ADR-002 (PostgreSQL)<br>ADR-003 (Raw SQL) | GET /api/v1/locations<br>POST /api/v1/locations<br>PUT /api/v1/locations/:location_id<br>DELETE /api/v1/locations/:location_id | `storage_locations`<br>`wines` (storage_location_id, location_unknown) | LocationsPage<br>LocationRow<br>CreateLocationModal<br>DeleteLocationModal<br>StorageLocationSelect | US-2.1, US-2.2, US-2.3, US-2.4 |
| **F3: Search & Filter** | P0 | F03.1 Full-Text Search<br>F03.2 Wine Type Filter<br>F03.3 Producer Filter<br>F03.4 Country/Region Filter<br>F03.5 Vintage Filter<br>F03.6 Grape Variety Filter<br>F03.7 Location Filter<br>F03.8 Readiness Filter<br>F03.9 Rating Range Filter<br>F03.10 Filter Chips<br>F03.11 Clear All Filters<br>F03.12 Sort Controls | ADR-004 (Client-Side Filter)<br>ADR-001 (Next.js) | GET /api/v1/wines (query params: q, wine_type, producer, country, region, vintage_from, vintage_to, grape_variety, location_id, readiness, rating_min, rating_max, sort) | `wines`<br>`tasting_notes` (JOIN for rating + occasion search) | SearchBar<br>FilterPanel<br>FilterChip<br>SortControl<br>FilterEngine (pure function) | US-3.1, US-3.2, US-3.3 |
| **F4: Tasting Notes & Personal Ratings** | P1 | F04.1 Add Note (Standalone)<br>F04.2 Linked Note (Post-Consume)<br>F04.3 View History<br>F04.4 Edit Note<br>F04.5 Delete Note<br>F04.6 Rating Scale Preference<br>F04.7 Rating Display on List | ADR-008 (latest_rating denormalization)<br>ADR-001 (Next.js)<br>ADR-003 (Raw SQL) | GET /api/v1/wines/:wine_id/tasting-notes<br>POST /api/v1/wines/:wine_id/tasting-notes<br>GET /api/v1/wines/:wine_id/tasting-notes/:note_id<br>PUT /api/v1/wines/:wine_id/tasting-notes/:note_id<br>DELETE /api/v1/wines/:wine_id/tasting-notes/:note_id<br>GET /api/v1/settings/rating-scale<br>PUT /api/v1/settings/rating-scale | `tasting_notes`<br>`wines` (latest_rating, latest_rating_scale, latest_rating_date)<br>`user_settings` | TastingNoteForm<br>RatingWidget<br>WouldBuyAgainToggle<br>TastingNoteCard<br>TastingNoteHistory | US-4.1, US-4.2, US-4.3, US-4.4, US-4.5, US-4.6 |
| **F5: Drinking Window Management** | P1 | F05.1 Window Entry (via F00)<br>F05.2 Status Calculation<br>F05.3 Badge Display<br>F05.4 Drink Now Integration (F06)<br>F05.5 Filter Integration (F03) | ADR-007 (Readiness at response time)<br>ADR-001 (Next.js) | Calculated field in all GET /api/v1/wines responses (`readiness_status`) — no dedicated endpoint | `wines` (drink_window_start, drink_window_end) — readiness_status NOT stored | ReadinessBadge<br>DrinkNowShelf (via F06)<br>FilterPanel — Readiness filter (via F03) | US-5.1, US-5.2, US-5.3 |
| **F6: Collection Dashboard & Insights** | P1 | F06.1 Summary Stats Bar<br>F06.2 Drink Now Shelf<br>F06.3 Breakdown by Type<br>F06.4 Breakdown by Region<br>F06.5 Breakdown by Decade<br>F06.6 Recently Added<br>F06.7 Recently Consumed<br>F06.8 Highest Rated<br>F06.9 Dashboard Navigation | ADR-001 (Next.js SSR)<br>ADR-007 (Readiness calculation)<br>ADR-008 (latest_rating) | GET /api/v1/dashboard<br>GET /api/v1/dashboard/stats | `wines`<br>`bottle_events`<br>`tasting_notes` | DashboardPage<br>StatsTile<br>DrinkNowShelf<br>BreakdownByType<br>BreakdownByRegion<br>BreakdownByDecade<br>RecentlyAddedCard<br>RecentlyConsumedCard<br>HighestRatedCard | US-6.1, US-6.2, US-6.3, US-6.4, US-6.5 |

---

## 4. Requirements Detail

### 4.1 F0 — Wine Inventory CRUD (P0 Critical)

**PRD Summary:** Core data management enabling users to create, view, edit, and delete wine records with 20+ structured fields. Every other feature depends on wine records existing.

**FRD Sub-Features and Key Behaviors:**

- **F00.1 — Add Wine:** Form with 6 required fields (wine_name, producer, vintage_year, wine_type, quantity, storage_location_id) and 15 optional fields; success toast "Wine added to your cellar."; must complete in ≤60 seconds on mobile
- **F00.2 — Wine List View:** Default sort by date_added descending; card layout (mobile) / table row (desktop); Cellar Empty wines de-emphasized; empty state with Add Wine CTA; API error inline banner
- **F00.3 — Wine Detail View:** All fields grouped by section (Identity, Provenance, Storage, Drinking Window, Tasting Notes, Bottle Events); action buttons: Edit, Open/Consume, Add Tasting Note, Delete; API error inline banner
- **F00.4 — Edit Wine:** Pre-populated form; same validation as Add; success toast "Wine record updated."; updated_at refreshed
- **F00.5 — Delete Wine:** Confirmation modal with warning text; cascade delete of all tasting notes and bottle events; success toast "Wine record deleted."
- **F00.6 — Form Validation:** Required fields enforced; vintage_year 1900–(currentYear+1); quantity ≥ 1; window start ≤ end; purchase_date not future; field-specific inline error messages

**User Stories Covered:** US-0.1 (Add), US-0.2 (Browse List), US-0.3 (View Detail), US-0.4 (Edit), US-0.5 (Delete), US-0.6 (Validation)

---

### 4.2 F1 — Quantity & Bottle Status Tracking (P0 Critical)

**PRD Summary:** Manages the lifecycle of individual bottle units; maintains accurate live bottle count; logs Consumed, Gifted, and Opened events; maintains bottle event history.

**FRD Sub-Features and Key Behaviors:**

- **F01.1 — Display Quantity:** Quantity pill/badge on wine list card and detail view; "Cellar Empty" label when quantity = 0
- **F01.2 — Increment/Decrement Controls:** +/− buttons flanking count; − disabled (`aria-disabled="true"`) at quantity = 0; no event logged for bare decrement
- **F01.3 — Log Consume Event:** Action sheet → Consume dialog (date, notes, tasting note toggle ON by default); decrements quantity; "Cellar Empty" state if qty = 0; navigates to tasting note form if toggle ON; blocked at qty = 0 with "No bottles remain" error
- **F01.4 — Log Gift Event:** Recipient (optional), date, notes dialog; decrements quantity; "Cellar Empty" if qty = 0; success toast "Bottle marked as gifted."
- **F01.5 — Log Open Event:** Date and notes dialog; sets `is_open = true`; quantity NOT decremented; "Open" badge on detail view; cleared on subsequent Consume/Gift
- **F01.6 — Cellar Empty State:** Visual de-emphasis (muted opacity) on wine list; Cellar Empty label; readiness badge still shown in muted style
- **F01.7 — Bottle Event Log:** Reverse-chronological history on Wine Detail; event type icon + label + date + optional notes/recipient; "No bottle events recorded yet." when empty

**User Stories Covered:** US-1.1 (Track Quantity), US-1.2 (Log Consumed), US-1.3 (Log Gift/Open), US-1.4 (View History)

---

### 4.3 F2 — Storage Location Management (P0 Critical)

**PRD Summary:** User-defined named storage locations; assign each wine to one location; graceful deletion with "Location Unknown" flagging; location list with bottle counts.

**FRD Sub-Features and Key Behaviors:**

- **F02.1 — Create Location:** Settings → Storage Locations; name (max 100 chars); unique (case-insensitive); immediately available in wine form dropdown; success "Location added."
- **F02.2 — Rename Location:** Edit inline; uniqueness and length validated; all wines immediately display new name; success "Location renamed."
- **F02.3 — Delete Location:** Confirmation modal showing affected wine count; on confirm: storage_location_id → NULL; location_unknown → TRUE on affected wines; success "Location deleted. [N] wine(s) marked as Location Unknown."
- **F02.4 — Assign Location to Wine:** Required dropdown on Add/Edit Wine form; alphabetically sorted; pre-selects most recently used location on Add form; inline "Add new location…" option
- **F02.5 — Filter by Location:** Integrated with F03 filter panel; "Location Unknown" is a filterable option
- **F02.6 — Location List View:** All locations with bottle counts; Location Unknown synthetic entry with Reassign link when applicable

**User Stories Covered:** US-2.1 (Create/Manage), US-2.2 (Delete), US-2.3 (View with Counts), US-2.4 (Assign to Wine)

---

### 4.4 F3 — Search & Filter (P0 Critical)

**PRD Summary:** Full-text client-side search across wine name, producer, region, grape, occasion; multi-attribute filter panel; dismissible filter chips; sort controls; session-persistent filter state.

**FRD Sub-Features and Key Behaviors:**

- **F03.1 — Full-Text Search:** Permanent search bar; 100ms debounce; client-side Fuse.js; matches wine_name, producer, region, grape_variety, occasion (most recent tasting note); AND logic with active panel filters; "×" clear button; "No wines match…" empty state
- **F03.2–F03.9 — Filter Panel Filters:** Wine Type (multi-select, OR within), Producer (exact match autocomplete), Country/Region (cascading selects), Vintage (range), Grape Variety (substring), Storage Location (single-select + "Location Unknown"), Drinking Readiness (multi-select; excludes qty = 0 wines), Rating Range (min/max)
- **F03.10 — Active Filter Chips:** One chip per active filter dimension above the wine list; "[Filter Type]: [Value]" format; dismissible with "×"
- **F03.11 — Clear All Filters:** "Clear all" link resets panel filters; does not clear search bar
- **F03.12 — Sort Controls:** 12 sort options including Date Added, Wine Name, Vintage, Quantity, Rating, Drinking Window End; default to Date Added: Newest; auto-default to Drinking Window End: Soonest when Drink Now filter active and no explicit sort selected

**User Stories Covered:** US-3.1 (Text Search), US-3.2 (Multi-Attribute Filter), US-3.3 (Filter Chips + Sort)

---

### 4.5 F4 — Tasting Notes & Personal Ratings (P1 High)

**PRD Summary:** Personal tasting experience records with sensory fields; 1–5 star or 1–100 point rating (user-selectable globally); would-buy-again toggle; multiple notes per wine; latest rating denormalized for list display.

**FRD Sub-Features and Key Behaviors:**

- **F04.1 — Add Tasting Note (Standalone):** 8 fields (date_tasted required; appearance, aroma, flavor, finish, personal_rating, would_buy_again, occasion, guest_feedback optional); updates wines.latest_rating; success "Tasting note saved."
- **F04.2 — Linked Note (Post-Consume):** Auto-navigated after Consumed event with toggle ON; pre-populated with today's date and bottle_event_id; linked event shows "View tasting note" in event log
- **F04.3 — View Tasting Note History:** Tasting Notes section on Wine Detail; reverse-chronological; rating + would_buy_again + occasion + flavor preview; expandable full detail; Edit/Delete buttons; "No tasting notes yet." empty state
- **F04.4 — Edit Tasting Note:** Pre-populated form; recalculates wines.latest_rating after save; success "Tasting note updated."
- **F04.5 — Delete Tasting Note:** Confirmation modal; recalculates wines.latest_rating (next most recent or NULL); success "Tasting note deleted."
- **F04.6 — Rating Scale Preference:** Settings → Rating Scale; "5-star (1–5)" or "100-point (1–100)"; global scope; no automatic conversion of existing ratings; scale label displayed on mixed-scale views
- **F04.7 — Rating Display on Wine List:** Most recent rating from latest_rating on wine list card; rendered as stars (5-star) or numeric badge (100-point); no indicator if no rated notes exist

**User Stories Covered:** US-4.1 (Add Standalone), US-4.2 (Linked Note), US-4.3 (View History), US-4.4 (Edit/Delete), US-4.5 (Rating Scale), US-4.6 (Rating on List)

---

### 4.6 F5 — Drinking Window Management (P1 High)

**PRD Summary:** Automatic readiness status calculation from stored drinking window years and current date; five statuses displayed as color-coded text badges on all wine cards and detail views; drives dashboard Drink Now shelf and filter panel.

**FRD Sub-Features and Key Behaviors:**

- **F05.1 — Drinking Window Entry:** drink_window_start and drink_window_end optional fields on wine add/edit form (via F00); integers 1900–2200; start ≤ end if both provided; wines with no window → "No Window Set"
- **F05.2 — Readiness Status Calculation:** Pure function `calculateReadinessStatus()` in `lib/business/readiness.ts`; evaluated in order: NO_WINDOW_SET → DRINK_NOW → APPROACHING_PEAK (1–2 years before start) → HOLD (>2 years before start) → PAST_WINDOW; calculated at API response time using UTC year; never stored, never cached
- **F05.3 — Readiness Badge Display:** Color-coded badges on wine list card and detail view header; DRINK_NOW: Gold #FBCA5C / Black text; APPROACHING_PEAK: Amber #F5A623 / Black text; HOLD: Gray #D4D1C9 / Ink text; PAST_WINDOW: Gray #E8E6E1 / Gray-400 text; NO_WINDOW_SET: transparent / Gray-400; JetBrains Mono UPPERCASE; color + text label always (WCAG 2.1 AA)
- **F05.4 — Drink Now Shelf Integration:** Dashboard Drink Now shelf populated from DRINK_NOW + qty > 0; sorted by drink_window_end ascending
- **F05.5 — Filter Integration:** Readiness status available as multi-select filter in F03; all readiness filters exclude qty = 0 wines

**User Stories Covered:** US-5.1 (Set Window), US-5.2 (See Readiness Badge), US-5.3 (Filter by Readiness)

---

### 4.7 F6 — Collection Dashboard & Insights (P1 High)

**PRD Summary:** Home screen with summary stats bar, Drink Now shelf, collection breakdowns by type/region/decade, recently added and consumed lists, highest rated card; all cards link to filtered wine list; default landing view.

**FRD Sub-Features and Key Behaviors:**

- **F06.1 — Summary Stats Bar:** Four tiles: Total Bottles (SUM qty > 0), Wine Records (COUNT *), Drink Now (DRINK_NOW + qty > 0), Approaching Peak (APPROACHING_PEAK + qty > 0); each tile navigates to filtered Wine List; updates on each load
- **F06.2 — Drink Now Shelf:** Up to 10 wines with DRINK_NOW + qty > 0; sorted by drink_window_end ascending (NULL end sorted last); horizontal scroll on mobile; "See all [N]" link; empty state message if none
- **F06.3 — Breakdown by Type:** 6 rows (all wine types); SUM(quantity) per type for qty > 0 wines; count + percentage; types with 0 still shown; tappable to filtered list
- **F06.4 — Breakdown by Region:** Top 5 country/region groups by bottle count + "Other" aggregate; "Unknown Origin" for wines with no country/region; tappable
- **F06.5 — Breakdown by Decade:** All decades with ≥1 bottle; decade label + count + proportional bar; sorted most recent first; tappable with vintage range filter
- **F06.6 — Recently Added:** 5 most recent by created_at; wine name, producer, vintage, type badge, relative date; links to Wine Detail; "View all" → Wine List sorted Date Added newest
- **F06.7 — Recently Consumed:** 5 most recent CONSUMED events; wine name, producer, vintage, relative date; "No consumed bottles recorded yet." empty state; "View all" → Wine List filtered by consumed wines
- **F06.8 — Highest Rated:** Top 5 by latest_rating (ties broken by latest_rating_date desc); rating display per user's scale; "Rate your wines…" empty state; tappable to Wine Detail
- **F06.9 — Dashboard Navigation:** All cards and segments link to filtered Wine List or Wine Detail for one-tap drill-down; empty collection → onboarding empty state with Add Wine CTA

**User Stories Covered:** US-6.1 (Stats), US-6.2 (Drink Now Shelf), US-6.3 (Breakdowns), US-6.4 (Recently Added/Consumed), US-6.5 (Highest Rated)

---

## 5. Test Case Coverage Matrix

### 5.1 Coverage Overview

Each user story's acceptance criteria serves as the basis for test cases. The following matrix maps each story to its estimated test case count, coverage category, and verification method. Test IDs follow the pattern `TEST-{story_id}-{n}` (e.g., TEST-0.1-01).

| Story ID | Story Title | Priority | AC Count | Test Cases | Coverage | Verification Method |
|----------|------------|----------|----------|------------|----------|---------------------|
| US-0.1 | Add a New Wine Record | P0 | 7 | TEST-0.1-01 to 07 | 100% | E2E + Unit (validation) |
| US-0.2 | Browse the Wine Collection List | P0 | 8 | TEST-0.2-01 to 08 | 100% | E2E + Integration |
| US-0.3 | View Full Wine Record Detail | P0 | 6 | TEST-0.3-01 to 06 | 100% | E2E + Integration |
| US-0.4 | Edit an Existing Wine Record | P0 | 6 | TEST-0.4-01 to 06 | 100% | E2E + Unit (validation) |
| US-0.5 | Delete a Wine Record | P0 | 6 | TEST-0.5-01 to 06 | 100% | E2E + Integration |
| US-0.6 | Form Validation on Add and Edit | P0 | 6 | TEST-0.6-01 to 06 | 100% | Unit (Zod) + E2E |
| US-1.1 | Track and Adjust Bottle Quantity | P0 | 5 | TEST-1.1-01 to 05 | 100% | E2E + Unit |
| US-1.2 | Log a Consumed Bottle Event | P0 | 7 | TEST-1.2-01 to 07 | 100% | E2E + Integration |
| US-1.3 | Log a Gifted or Opened Bottle Event | P0 | 8 | TEST-1.3-01 to 08 | 100% | E2E + Integration |
| US-1.4 | View Bottle Event History | P0 | 5 | TEST-1.4-01 to 05 | 100% | E2E + Integration |
| US-2.1 | Create and Manage Storage Locations | P0 | 7 | TEST-2.1-01 to 07 | 100% | E2E + Unit (validation) |
| US-2.2 | Delete a Storage Location | P0 | 5 | TEST-2.2-01 to 05 | 100% | E2E + Integration |
| US-2.3 | View All Storage Locations with Bottle Counts | P0 | 5 | TEST-2.3-01 to 05 | 100% | E2E + Integration |
| US-2.4 | Assign a Storage Location to a Wine | P0 | 7 | TEST-2.4-01 to 07 | 100% | E2E |
| US-3.1 | Search the Collection with Real-Time Text Search | P0 | 6 | TEST-3.1-01 to 06 | 100% | E2E + Unit (FilterEngine) |
| US-3.2 | Filter the Collection by Multiple Attributes | P0 | 7 | TEST-3.2-01 to 07 | 100% | E2E + Unit (FilterEngine) |
| US-3.3 | Manage Active Filters and Sort Results | P0 | 7 | TEST-3.3-01 to 07 | 100% | E2E + Unit (sort functions) |
| US-4.1 | Add a Standalone Tasting Note | P1 | 7 | TEST-4.1-01 to 07 | 100% | E2E + Unit (validation) |
| US-4.2 | Capture a Linked Tasting Note After Consuming | P1 | 4 | TEST-4.2-01 to 04 | 100% | E2E + Integration |
| US-4.3 | View Tasting Note History for a Wine | P1 | 5 | TEST-4.3-01 to 05 | 100% | E2E + Integration |
| US-4.4 | Edit or Delete a Tasting Note | P1 | 6 | TEST-4.4-01 to 06 | 100% | E2E + Unit (latest_rating) |
| US-4.5 | Choose a Personal Rating Scale | P1 | 4 | TEST-4.5-01 to 04 | 100% | E2E + Integration |
| US-4.6 | See Most Recent Rating on the Wine List | P1 | 4 | TEST-4.6-01 to 04 | 100% | E2E + Unit (denorm) |
| US-5.1 | Set Drinking Window on a Wine Record | P1 | 5 | TEST-5.1-01 to 05 | 100% | E2E + Unit (validation) |
| US-5.2 | See Readiness Status Automatically Calculated | P1 | 6 | TEST-5.2-01 to 06 | 100% | Unit (readiness.ts) + E2E |
| US-5.3 | Filter and Surface Wines by Readiness Status | P1 | 4 | TEST-5.3-01 to 04 | 100% | E2E + Unit (FilterEngine) |
| US-6.1 | View Collection Summary Stats on the Dashboard | P1 | 5 | TEST-6.1-01 to 05 | 100% | E2E + Integration |
| US-6.2 | Browse the Drink Now Shelf | P1 | 5 | TEST-6.2-01 to 05 | 100% | E2E + Integration |
| US-6.3 | View Collection Breakdowns by Type, Region, Vintage | P1 | 5 | TEST-6.3-01 to 05 | 100% | E2E + Integration |
| US-6.4 | Review Recently Added and Recently Consumed Wines | P1 | 5 | TEST-6.4-01 to 05 | 100% | E2E + Integration |
| US-6.5 | Discover Highest Rated Wines on the Dashboard | P1 | 6 | TEST-6.5-01 to 06 | 100% | E2E + Integration |

### 5.2 Coverage Summary by Feature

| PRD Feature | User Stories | Total Test Cases (Est.) | P0 Stories | P1 Stories | Coverage % |
|-------------|-------------|------------------------|-----------|-----------|------------|
| F0: Wine Inventory CRUD | 6 (US-0.1–0.6) | 39 | 6 | 0 | 100% |
| F1: Quantity & Bottle Status | 4 (US-1.1–1.4) | 25 | 4 | 0 | 100% |
| F2: Storage Location Management | 4 (US-2.1–2.4) | 24 | 4 | 0 | 100% |
| F3: Search & Filter | 3 (US-3.1–3.3) | 20 | 3 | 0 | 100% |
| F4: Tasting Notes & Ratings | 6 (US-4.1–4.6) | 30 | 0 | 6 | 100% |
| F5: Drinking Window Management | 3 (US-5.1–5.3) | 15 | 0 | 3 | 100% |
| F6: Collection Dashboard | 5 (US-6.1–6.5) | 26 | 0 | 5 | 100% |
| **Totals** | **31** | **~179** | **17** | **14** | **100%** |

### 5.3 Key Business Logic Unit Test Areas

The following pure functions and business logic modules require dedicated unit test suites independent of E2E coverage:

| Module | File | Test Focus | Story Refs |
|--------|------|-----------|-----------|
| Readiness Status Calculation | `lib/business/readiness.ts` | All 5 status branches; edge cases (only start set, only end set, start=end, qty=0 wine) | US-5.2 |
| Client-Side Filter Engine | `lib/filter/filterWines.ts` | Each filter type independently; AND logic across filters; empty result state; readiness + qty=0 exclusion rule | US-3.1, US-3.2, US-5.3 |
| Sort Functions | `lib/filter/sortWines.ts` | All 12 sort keys; unrated wines sorted last; null drink_window_end sorted last | US-3.3 |
| Latest Rating Refresh | `lib/business/rating.ts` | Insert note with rating; delete note; delete all notes (→ NULL); scale mixed correctly | US-4.4, US-4.6 |
| Location Unknown Flag | `lib/business/location.ts` | Delete location → wines flagged; reassign clears flag | US-2.2 |
| Zod Validation Schemas | `lib/validation/wines.ts` | Required fields; vintage range; window start ≤ end; purchase_date not future | US-0.6, US-5.1 |

### 5.4 API Integration Test Coverage

| Endpoint Group | Endpoints | Test Scenarios |
|---------------|----------|---------------|
| Wine CRUD | GET, POST, GET/:id, PUT, PATCH, DELETE /wines | 200/201/204 success; 404 not found; 422 validation failures; cascade delete verification |
| Bottle Events | POST, GET /wines/:id/events; PATCH /wines/:id/quantity | CONSUMED/GIFTED/OPENED; qty=0 rejection; future date rejection; qty floor enforcement |
| Storage Locations | GET, POST, PUT, DELETE /locations | Create; duplicate name 409; rename; delete with wine flagging |
| Tasting Notes | GET, POST, GET/:id, PUT, DELETE /wines/:id/tasting-notes | Save with rating triggers latest_rating update; delete recalculates; linked event validation |
| Dashboard | GET /dashboard; GET /dashboard/stats | Empty collection; partial data (no consumed events, no rated wines); correct aggregate calculations |
| Settings | GET, PUT /settings/rating-scale | Get default; update; invalid value rejection |

---

## 6. Bidirectional Traceability Index

### 6.1 Story → FRD Sub-Feature Mapping

| User Story | FRD Sub-Feature(s) | PRD Feature |
|-----------|-------------------|-------------|
| US-0.1 — Add a New Wine Record | F00.1 (Add Wine) | F0 |
| US-0.2 — Browse the Wine Collection List | F00.2 (Wine List View) | F0 |
| US-0.3 — View Full Wine Record Detail | F00.3 (Wine Detail View) | F0 |
| US-0.4 — Edit an Existing Wine Record | F00.4 (Edit Wine) | F0 |
| US-0.5 — Delete a Wine Record | F00.5 (Delete Wine) | F0 |
| US-0.6 — Form Validation on Add and Edit | F00.6 (Form Validation) | F0 |
| US-1.1 — Track and Adjust Bottle Quantity | F01.1 (Display Quantity), F01.2 (Increment/Decrement), F01.6 (Cellar Empty) | F1 |
| US-1.2 — Log a Consumed Bottle Event | F01.3 (Log Consume Event), F01.6 (Cellar Empty) | F1 |
| US-1.3 — Log a Gifted or Opened Bottle Event | F01.4 (Log Gift), F01.5 (Log Open), F01.6 (Cellar Empty) | F1 |
| US-1.4 — View Bottle Event History | F01.7 (Bottle Event Log) | F1 |
| US-2.1 — Create and Manage Storage Locations | F02.1 (Create), F02.2 (Rename), F02.6 (Location List) | F2 |
| US-2.2 — Delete a Storage Location | F02.3 (Delete Location) | F2 |
| US-2.3 — View All Storage Locations with Bottle Counts | F02.6 (Location List View) | F2 |
| US-2.4 — Assign a Storage Location to a Wine | F02.4 (Assign Location) | F2 |
| US-3.1 — Search the Collection with Real-Time Text Search | F03.1 (Full-Text Search) | F3 |
| US-3.2 — Filter the Collection by Multiple Attributes | F03.2–F03.9 (All Filter Types) | F3 |
| US-3.3 — Manage Active Filters and Sort Results | F03.10 (Filter Chips), F03.11 (Clear All), F03.12 (Sort Controls) | F3 |
| US-4.1 — Add a Standalone Tasting Note | F04.1 (Add Tasting Note) | F4 |
| US-4.2 — Capture a Linked Tasting Note After Consuming | F04.2 (Linked Note) | F4 |
| US-4.3 — View Tasting Note History for a Wine | F04.3 (View History) | F4 |
| US-4.4 — Edit or Delete a Tasting Note | F04.4 (Edit), F04.5 (Delete) | F4 |
| US-4.5 — Choose a Personal Rating Scale | F04.6 (Rating Scale Preference) | F4 |
| US-4.6 — See Most Recent Rating on the Wine List | F04.7 (Rating Display on List) | F4 |
| US-5.1 — Set Drinking Window on a Wine Record | F05.1 (Window Entry) | F5 |
| US-5.2 — See Readiness Status Automatically Calculated | F05.2 (Status Calculation), F05.3 (Badge Display) | F5 |
| US-5.3 — Filter and Surface Wines by Readiness Status | F05.5 (Filter Integration), F03.8 (Readiness Filter) | F5, F3 |
| US-6.1 — View Collection Summary Stats on the Dashboard | F06.1 (Summary Stats Bar) | F6 |
| US-6.2 — Browse the Drink Now Shelf | F06.2 (Drink Now Shelf), F05.4 (Drink Now Integration) | F6, F5 |
| US-6.3 — View Collection Breakdowns | F06.3 (By Type), F06.4 (By Region), F06.5 (By Decade) | F6 |
| US-6.4 — Review Recently Added and Recently Consumed | F06.6 (Recently Added), F06.7 (Recently Consumed) | F6 |
| US-6.5 — Discover Highest Rated Wines on Dashboard | F06.8 (Highest Rated) | F6 |

### 6.2 API Endpoint → PRD Feature Mapping

| # | Endpoint | Method | PRD Feature | FRD Section | User Stories |
|---|----------|--------|-------------|-------------|-------------|
| 1 | `/api/v1/wines` | GET | F0, F3 | F00.2, F03 | US-0.2, US-3.1, US-3.2, US-3.3 |
| 2 | `/api/v1/wines` | POST | F0 | F00.1 | US-0.1 |
| 3 | `/api/v1/wines/:wine_id` | GET | F0 | F00.3 | US-0.3 |
| 4 | `/api/v1/wines/:wine_id` | PUT | F0 | F00.4 | US-0.4 |
| 5 | `/api/v1/wines/:wine_id` | PATCH | F0 | F00.4 | US-0.4 |
| 6 | `/api/v1/wines/:wine_id` | DELETE | F0 | F00.5 | US-0.5 |
| 7 | `/api/v1/wines/:wine_id/events` | POST | F1 | F01.3, F01.4, F01.5 | US-1.2, US-1.3 |
| 8 | `/api/v1/wines/:wine_id/events` | GET | F1 | F01.7 | US-1.4 |
| 9 | `/api/v1/wines/:wine_id/quantity` | PATCH | F1 | F01.2 | US-1.1 |
| 10 | `/api/v1/locations` | GET | F2 | F02.6 | US-2.3 |
| 11 | `/api/v1/locations` | POST | F2 | F02.1 | US-2.1 |
| 12 | `/api/v1/locations/:location_id` | PUT | F2 | F02.2 | US-2.1 |
| 13 | `/api/v1/locations/:location_id` | DELETE | F2 | F02.3 | US-2.2 |
| 14 | `/api/v1/wines/:wine_id/tasting-notes` | GET | F4 | F04.3 | US-4.3 |
| 15 | `/api/v1/wines/:wine_id/tasting-notes` | POST | F4 | F04.1, F04.2 | US-4.1, US-4.2 |
| 16 | `/api/v1/wines/:wine_id/tasting-notes/:note_id` | GET | F4 | F04.3 | US-4.3 |
| 17 | `/api/v1/wines/:wine_id/tasting-notes/:note_id` | PUT | F4 | F04.4 | US-4.4 |
| 18 | `/api/v1/wines/:wine_id/tasting-notes/:note_id` | DELETE | F4 | F04.5 | US-4.4 |
| 19 | `/api/v1/settings/rating-scale` | GET | F4 | F04.6 | US-4.5 |
| 20 | `/api/v1/settings/rating-scale` | PUT | F4 | F04.6 | US-4.5 |
| 21 | `/api/v1/dashboard` | GET | F6 | F06.1–F06.8 | US-6.1–6.5 |
| 22 | `/api/v1/dashboard/stats` | GET | F6 | F06.1 | US-6.1 |

### 6.3 TechArch ADR → PRD Feature Mapping

| ADR | Decision | PRD Features Impacted | FRD Sections |
|-----|----------|-----------------------|-------------|
| ADR-001 | Next.js 14 App Router | F0–F6 (all) | All FRD sections |
| ADR-002 | PostgreSQL as primary database | F0–F6 (all) | Y0-schema.md |
| ADR-003 | Raw SQL via node-postgres (no ORM) | F0–F6 (all) | Y1-api.md |
| ADR-004 | Client-side filtering with Fuse.js | F3 (Search & Filter) | F03 |
| ADR-005 | Self-hosted fonts (WOFF2) | F0–F6 (UI layer) | Design Token Reference |
| ADR-006 | No authentication in v1 | F0–F6 (all, no auth) | Y2-errors.md |
| ADR-007 | Readiness status calculated at response time | F5, F6 | F05.2, F06.2 |
| ADR-008 | latest_rating denormalized on wines table | F4, F6 | F04.7, F06.8 |

---

## 7. Change Management

### 7.1 Change Log

| Change # | Date | Version | Author | Description | Impact |
|----------|------|---------|--------|-------------|--------|
| CHG-001 | 2026-06-03 | 1.0 | Pivota Spec | Initial RTM generated from PRD v1.0, FRD v1.0, TechArch v1.0, UserStories v1.0 | — Baseline document |

### 7.2 Change Impact Analysis Protocol

When a change to any source document is proposed, the following impact analysis process applies:

1. **Identify the change origin layer:** PRD (feature scope), FRD (behavior/validation), TechArch (implementation choice), or UserStories (acceptance criteria)
2. **Propagate downward:** A PRD change always requires FRD, TechArch, and UserStories review. An FRD change requires TechArch and UserStories review.
3. **Update this RTM:** All affected rows in Section 3.1 and Section 6 must be updated to reflect the change.
4. **Update test cases:** Any changed or new acceptance criteria require corresponding test case updates in Section 5.
5. **Version and log the change** in Section 7.1 before releasing the updated RTM.

### 7.3 Out-of-Scope Registry (Deferred Features)

The following capabilities are explicitly excluded from MVP v1 and must not be implemented without a PRD revision and RTM update:

| Deferred Feature | Phase | PRD Section |
|-----------------|-------|-------------|
| Label scanning / OCR bottle entry | Phase 3 | PRD §10 |
| AI-assisted bottle entry | Phase 3 | PRD §10 |
| Food pairing suggestions | Phase 2 | PRD §10 |
| Occasion-based recommendations | Phase 2 | PRD §10 |
| Drinking window push notifications | Phase 2 | PRD §10 |
| CSV / Excel import | Phase 2 | PRD §10 |
| Spreadsheet / PDF export | Phase 2 | PRD §10 |
| Shared household accounts | Phase 4 | PRD §10 |
| Wine valuation tracking | Phase 2 | PRD §10 |
| Cellar map / storage visualization | Phase 2 | PRD §10 |
| External wine database integration | Phase 3 | PRD §10 |
| Authentication / user accounts | Phase 2 | TechArch ADR-006 |

---

## 8. Approval

### 8.1 Document Approval Sign-Off

| Role | Name | Signature | Date | Status |
|------|------|-----------|------|--------|
| Product Owner | — | | | Pending |
| Engineering Lead | — | | | Pending |
| QA Lead | — | | | Pending |
| Design Lead | — | | | Pending |

### 8.2 Spec Document Status at RTM Generation

| Document | Version | Status | Date |
|----------|---------|--------|------|
| PROJECT.md | — | Complete | 2026-06-03 |
| PRD-SimpleWineApp.md | 1.0 | Draft | 2026-06-03 |
| FRD-SimpleWineApp.md | 1.0 | Draft | 2026-06-03 |
| TechArch-SimpleWineApp.md | 1.0 | Draft | 2026-06-03 |
| UserStories-SimpleWineApp.md | 1.0 | Draft | 2026-06-03 |
| RTM-SimpleWineApp.md | 1.0 | Draft | 2026-06-03 |

### 8.3 Traceability Completeness Checklist

- [x] All 7 PRD features (F0–F6) have traceability entries in Section 3.1
- [x] All 7 PRD features map to FRD sub-features in Sections 3.1 and 4
- [x] All FRD feature chunks (F00–F06) map back to PRD features
- [x] All 22 TechArch API endpoints map to PRD features and FRD sections (Section 6.2)
- [x] All 8 TechArch ADRs map to PRD features (Section 6.3)
- [x] All 31 user stories (US-0.1–US-6.5) map to FRD sub-features (Section 6.1)
- [x] All 31 user stories have estimated test case ranges (Section 5.1)
- [x] All 5 database tables map to PRD features in Section 3.1
- [x] All React component groups map to PRD features in Section 3.1
- [x] Non-functional requirements catalogued in Section 2.5
- [x] Out-of-scope features registered in Section 7.3
- [x] Change management protocol defined in Section 7.2

---

*RTM generated by Pivota Spec RTM Generator · SimpleWineApp v1.0 MVP · 2026-06-03*
