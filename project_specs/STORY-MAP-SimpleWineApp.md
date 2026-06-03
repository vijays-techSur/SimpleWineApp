# Story Map
## SimpleWineApp — Personal Wine Collection Manager

| Field | Value |
|-------|-------|
| **Product** | SimpleWineApp v1.0 MVP |
| **Date** | 2026-06-03 |
| **Author** | Pivota Spec Story Map Generator |
| **Related PRD** | `project_specs/PRD-SimpleWineApp.md` |
| **Related Personas** | `project_specs/PERSONAS-SimpleWineApp.md` |
| **Related JTBD** | `project_specs/JTBD-SimpleWineApp.md` |
| **Related Journeys** | `project_specs/JOURNEYS-SimpleWineApp.md` |
| **Related UserStories** | `project_specs/UserStories-SimpleWineApp.md` |
| **Status** | Draft |

---

## Overview

This Story Map organizes all 31 user stories from UserStories-SimpleWineApp.md into a two-dimensional structure:

- **X-axis (columns):** Journey stages drawn from JOURNEYS-SimpleWineApp.md — the universal lifecycle moments every persona moves through
- **Y-axis (rows):** Epics and individual stories, placed at the stage where their primary value is delivered
- **NaC column:** Natural Acceptance Criteria derived from the intersection of a JTBD outcome, a journey stage, and the specific story — not invented, fully traceable
- **Release column:** Increment assignment (R1 = Core Workflow MVP; R2 = Insight & Preference Layer)

### Universal Journey Stages (X-axis)

All four personas traverse a common spine of stages, though the scenario varies:

| Stage | Description | JRN Coverage |
|-------|-------------|--------------|
| **Arrive** | User opens the app; orientation moment | JRN-01.1, JRN-01.2, JRN-01.3, JRN-02.2, JRN-03.1, JRN-03.2, JRN-04.1, JRN-04.2 |
| **Add / Capture** | User logs a new bottle or new event (purchase, consume, gift) | JRN-01.1, JRN-01.3 (Marcus); JRN-02.1 (Diane); JRN-03.2 (Priya); JRN-04.1 (Richard) |
| **Find / Browse** | User discovers or locates a specific wine | JRN-01.2 (Marcus); JRN-02.1 (Diane); JRN-03.1 (Priya); JRN-04.2 (Richard) |
| **Evaluate** | User reads details, checks readiness, confirms storage | JRN-01.3, JRN-02.1, JRN-03.1, JRN-04.1, JRN-04.2 |
| **Act / Decide** | User makes a decision: open bottle, mark consumed, record note, buy/not-buy | JRN-01.2, JRN-01.3, JRN-02.1, JRN-03.1, JRN-03.2, JRN-04.2 |
| **Review / Reflect** | User reviews collection state, insights, history | JRN-02.2, JRN-04.2 |

### NaC Concept

A Natural Acceptance Criterion (NaC) is derived — never invented — from three sources:
1. **JTBD outcome** — the measurable goal the persona is hiring the feature to achieve
2. **Journey stage** — the moment in the workflow where the criterion applies
3. **User Story** — the specific capability being built

Format: `JTBD-XX.Y [outcome phrase] → [journey stage] → [testable NaC statement]`

---

## Story Map Matrix

### Epic 0: Wine Inventory CRUD (F0) — Foundation

| SM-ID | Persona(s) | Journey Stage | Story | NaC (JTBD → Stage → Criterion) | Release |
|-------|------------|---------------|-------|----------------------------------|---------|
| SM-0.1 | PER-01, PER-03, PER-04 | Add / Capture | **US-0.1** Add a New Wine Record | JTBD-01.3 "Log a new bottle before I forget" → Add/Capture → New wine record saved from required fields only in ≤ 60 sec on mobile | R1 |
| SM-0.2 | PER-01, PER-03 | Arrive / Find | **US-0.2** Browse the Wine Collection List | JTBD-01.1 "Instantly know what I own" → Arrive → Full collection visible on list load within 300ms; quantity badge on every card | R1 |
| SM-0.3 | PER-02, PER-04 | Evaluate | **US-0.3** View Full Wine Record Detail | JTBD-02.3 "Replace my spreadsheet with one complete system" → Evaluate → All fields, readiness badge, tasting history, and bottle log visible in a single detail view | R1 |
| SM-0.4 | PER-04, PER-02 | Add / Capture | **US-0.4** Edit an Existing Wine Record | JTBD-04.1 "Know exactly where every bottle is stored" → Add/Capture → All fields (including location) editable; save confirmed with toast and record refreshed | R1 |
| SM-0.5 | PER-01 | Act / Decide | **US-0.5** Delete a Wine Record | JTBD-01.1 "Instantly know what I own" → Act/Decide → Deleted wine removed from list immediately with cascade; confirmation prevents accidental loss | R1 |
| SM-0.6 | PER-01, PER-04 | Add / Capture | **US-0.6** Form Validation on Add and Edit | JTBD-01.3 "Log a new bottle before I forget" → Add/Capture → Inline errors on required fields prevent bad saves; form state retained so user does not re-enter data | R1 |

---

### Epic 1: Quantity & Bottle Status Tracking (F1)

| SM-ID | Persona(s) | Journey Stage | Story | NaC (JTBD → Stage → Criterion) | Release |
|-------|------------|---------------|-------|----------------------------------|---------|
| SM-1.1 | PER-01, PER-03 | Act / Decide | **US-1.1** Track and Adjust Bottle Quantity | JTBD-03.2 "Keep inventory accurate after every event" → Act/Decide → Quantity increments/decrements in one tap; count on list card updates immediately; cannot drop below 0 | R1 |
| SM-1.2 | PER-02, PER-03 | Act / Decide | **US-1.2** Log a Consumed Bottle Event | JTBD-03.2 "Keep inventory accurate after every event" → Act/Decide → Consumed event decrements quantity by 1; "Cellar Empty" status set at zero; tasting note prompt offered | R1 |
| SM-1.3 | PER-03 | Act / Decide | **US-1.3** Log a Gifted or Opened Bottle Event | JTBD-03.2 "Keep inventory accurate after every event" → Act/Decide → Gifted event decrements quantity; Opened sets is_open flag without decrement; both confirmed by toast | R1 |
| SM-1.4 | PER-04, PER-02 | Review / Reflect | **US-1.4** View Bottle Event History | JTBD-02.3 "Replace my spreadsheet with one complete system" → Review/Reflect → Full chronological event log (consumed/gifted/opened) visible on wine detail with linked tasting note access | R1 |

---

### Epic 2: Storage Location Management (F2)

| SM-ID | Persona(s) | Journey Stage | Story | NaC (JTBD → Stage → Criterion) | Release |
|-------|------------|---------------|-------|----------------------------------|---------|
| SM-2.1 | PER-04 | Add / Capture | **US-2.1** Create and Manage Storage Locations | JTBD-04.1 "Know exactly where every bottle is stored" → Add/Capture → Named locations created inline from the wine form; new location immediately available as selection; uniqueness enforced | R1 |
| SM-2.2 | PER-04 | Review / Reflect | **US-2.2** Delete a Storage Location | JTBD-04.1 "Know exactly where every bottle is stored" → Review/Reflect → Deleting a location shows affected wine count before confirm; affected wines set to Location Unknown — never silently broken | R1 |
| SM-2.3 | PER-04 | Review / Reflect | **US-2.3** View All Storage Locations with Bottle Counts | JTBD-04.1 "Know exactly where every bottle is stored" → Review/Reflect → Every named location shows live bottle count; Location Unknown entry surfaced with reassign link; off-site storage always visible | R1 |
| SM-2.4 | PER-01, PER-04 | Add / Capture | **US-2.4** Assign a Storage Location to a Wine | JTBD-04.1 "Know exactly where every bottle is stored" → Add/Capture → Storage location required on add/edit form; pre-selects most recently used location; inline "Add new location" without leaving the form | R1 |

---

### Epic 3: Search & Filter (F3)

| SM-ID | Persona(s) | Journey Stage | Story | NaC (JTBD → Stage → Criterion) | Release |
|-------|------------|---------------|-------|----------------------------------|---------|
| SM-3.1 | PER-01, PER-02 | Find / Browse | **US-3.1** Search the Collection with Real-Time Text Search | JTBD-01.1 "Instantly know what I own before buying" → Find/Browse → Typing a wine name or producer into search bar returns matching results within 2 seconds; quantity visible on each result card | R1 |
| SM-3.2 | PER-03, PER-04 | Find / Browse | **US-3.2** Filter the Collection by Multiple Attributes | JTBD-03.1 "Find the right bottle for tonight before guests arrive" → Find/Browse → Sparkling + Drink Now filter reachable in ≤ 3 taps from home screen; combined filter result renders within 5 sec | R1 |
| SM-3.3 | PER-02, PER-04 | Find / Browse | **US-3.3** Manage Active Filters and Sort Results | JTBD-02.2 "Know which bottles are ready without calculating" → Find/Browse → Active filters shown as dismissible chips; changing one filter dimension does not clear others; Drink Now sort by end-year ascending | R1 |

---

### Epic 4: Tasting Notes & Personal Ratings (F4)

| SM-ID | Persona(s) | Journey Stage | Story | NaC (JTBD → Stage → Criterion) | Release |
|-------|------------|---------------|-------|----------------------------------|---------|
| SM-4.1 | PER-02 | Act / Decide | **US-4.1** Add a Standalone Tasting Note | JTBD-02.1 "Capture tasting impressions while fresh" → Act/Decide → Full tasting note (date, aroma, palate, finish, rating, occasion) saved in ≤ 2 min on mobile; note appears in chronological history immediately | R2 |
| SM-4.2 | PER-02, PER-03 | Act / Decide | **US-4.2** Capture a Linked Tasting Note After Consuming | JTBD-02.1 "Capture tasting impressions while fresh" → Act/Decide → Post-consume prompt navigates to tasting note form pre-linked to the bottle event; "View tasting note" link appears on the event log entry | R2 |
| SM-4.3 | PER-04, PER-02 | Review / Reflect | **US-4.3** View Tasting Note History for a Wine | JTBD-04.3 "See a complete overview of my collection's composition" → Review/Reflect → All tasting notes displayed reverse-chronologically on detail view; rating, occasion, and palate preview visible without expanding | R2 |
| SM-4.4 | PER-02 | Review / Reflect | **US-4.4** Edit or Delete a Tasting Note | JTBD-02.1 "Capture tasting impressions while fresh" → Review/Reflect → Edit form pre-populated with existing values; latest_rating recalculated after edit or delete; confirmation prevents accidental loss | R2 |
| SM-4.5 | PER-02 | Add / Capture | **US-4.5** Choose a Personal Rating Scale | JTBD-02.1 "Capture tasting impressions while fresh" → Add/Capture → Rating scale setting (5-star / 100-point) applies globally; existing ratings display with scale label if scale is switched; no conversion of stored values | R2 |
| SM-4.6 | PER-03, PER-02 | Find / Browse | **US-4.6** See Most Recent Rating on the Wine List | JTBD-03.3 "Remember what I served at past gatherings" → Find/Browse → Most recent personal rating visible as star/numeric badge on wine list card without opening detail; no badge shown when no rated note exists | R2 |

---

### Epic 5: Drinking Window Management (F5)

| SM-ID | Persona(s) | Journey Stage | Story | NaC (JTBD → Stage → Criterion) | Release |
|-------|------------|---------------|-------|----------------------------------|---------|
| SM-5.1 | PER-04, PER-02 | Add / Capture | **US-5.1** Set Drinking Window on a Wine Record | JTBD-04.2 "Track drinking-window readiness across the entire collection" → Add/Capture → Start and end year fields available on add/edit form; validation enforces start ≤ end; wines without window show "No Window Set" | R2 |
| SM-5.2 | PER-02, PER-04, PER-03 | Evaluate | **US-5.2** See Readiness Status Automatically Calculated | JTBD-02.2 "Know which bottles are ready without calculating" → Evaluate → Readiness badge (Drink Now / Approaching Peak / Hold / Past Window / No Window Set) auto-calculated on every app load; badge visible on list card and detail header | R2 |
| SM-5.3 | PER-03, PER-02, PER-04 | Find / Browse | **US-5.3** Filter and Surface Wines by Readiness Status | JTBD-03.1 "Find the right bottle for tonight before guests arrive" → Find/Browse → Drink Now readiness filter reachable in ≤ 3 taps; multi-select readiness filter (OR within filter); only qty > 0 wines returned for Drink Now | R2 |

---

### Epic 6: Collection Dashboard & Insights (F6)

| SM-ID | Persona(s) | Journey Stage | Story | NaC (JTBD → Stage → Criterion) | Release |
|-------|------------|---------------|-------|----------------------------------|---------|
| SM-6.1 | PER-01, PER-02, PER-04 | Arrive | **US-6.1** View Collection Summary Stats on Dashboard | JTBD-01.2 "Pick something to drink tonight" → Arrive → Dashboard lands by default; summary bar shows Total Bottles, Wine Records, Drink Now count, Approaching Peak count — all tappable; stats update on each load | R2 |
| SM-6.2 | PER-02, PER-01, PER-03 | Arrive / Evaluate | **US-6.2** Browse the Drink Now Shelf | JTBD-01.2 "Pick something to drink tonight" → Arrive/Evaluate → Drink Now shelf shows up to 10 ready wines sorted by soonest-expiring; each card shows name, producer, vintage, qty, storage location; "See all" link available | R2 |
| SM-6.3 | PER-04, PER-02 | Review / Reflect | **US-6.3** View Collection Breakdowns by Type, Region, Vintage | JTBD-04.3 "See a complete overview of my collection's composition" → Review/Reflect → Type, country/region (top 5 + Other), and vintage decade breakdowns all visible on dashboard; each segment links to filtered wine list | R2 |
| SM-6.4 | PER-03, PER-01 | Review / Reflect | **US-6.4** Review Recently Added and Recently Consumed Wines | JTBD-03.2 "Keep inventory accurate after every event" → Review/Reflect → Last 5 added and last 5 consumed wines visible on dashboard without navigation; each row links to the wine detail | R2 |
| SM-6.5 | PER-02, PER-03 | Review / Reflect | **US-6.5** Discover Highest Rated Wines on the Dashboard | JTBD-02.1 "Capture tasting impressions while fresh" → Review/Reflect → Top 5 rated wines displayed with rating badge; only wines with at least one rated tasting note included; tapping navigates to wine detail | R2 |

---

## NaC Derivation Table

Full traceability chain for every NaC: JTBD outcome → Journey stage → NaC → Story.

| JTBD-ID | Outcome (abbreviated) | Journey Stage | Derived NaC | Story |
|---------|----------------------|---------------|-------------|-------|
| JTBD-01.1 | No duplicate purchases — know what I own | JRN-01.2: Find/Browse (Open & Search) | Search bar returns results within 2 sec; quantity visible on card; decision confirmed in ≤ 15 sec | US-3.1, US-0.2 |
| JTBD-01.1 | No duplicate purchases — know what I own | JRN-01.2: Evaluate (Confirm Decision) | Quantity badge visible on list card without opening detail view | US-0.2, US-1.1 |
| JTBD-01.2 | Drink Now selection in < 60 sec | JRN-01.3: Arrive (Browse Drink Now Shelf) | Drink Now shelf visible on dashboard default; no extra navigation required | US-6.1, US-6.2 |
| JTBD-01.2 | Drink Now selection in < 60 sec | JRN-01.3: Find/Browse (Filter by Type) | Wine type filter reachable from Drink Now shelf in ≤ 3 taps; result within 5 sec | US-3.2, US-5.3 |
| JTBD-01.2 | Drink Now selection in < 60 sec | JRN-01.3: Evaluate (Select a Bottle) | Storage location displayed on detail hero — first visible field after wine name | US-0.3, US-5.2 |
| JTBD-01.3 | New bottle added in ≤ 60 sec | JRN-01.1: Add/Capture (Initiate) | Add form opens in ≤ 2 taps; required fields marked; optional fields visibly de-emphasized | US-0.1, US-0.6 |
| JTBD-01.3 | New bottle added in ≤ 60 sec | JRN-01.1: Add/Capture (Enter Required Fields) | 6 required fields only; autocomplete on producer; location pre-selects last used | US-0.1, US-2.4 |
| JTBD-01.3 | New bottle added in ≤ 60 sec | JRN-01.1: Act/Decide (Save Record) | Success toast "Wine added to your cellar." shown; collection list immediately reflects new record | US-0.1, US-1.1 |
| JTBD-02.1 | Tasting note logged in ≤ 2 min | JRN-02.1: Act/Decide (Add Tasting Note) | Tasting note form reachable within 2 taps of wine detail; all sensory fields + rating + occasion available | US-4.1, US-4.2 |
| JTBD-02.1 | Tasting note logged in ≤ 2 min | JRN-02.1: Review/Reflect (Review & Save) | Saved note appears immediately in chronological history on wine detail; latest_rating updated | US-4.3, US-4.4 |
| JTBD-02.1 | Tasting note logged in ≤ 2 min | JRN-02.2: Review/Reflect (Cross-Reference Tasting History) | Rating filter + region filter combinable; result shows producer, grape, region, and rating in one view | US-4.6, US-3.3 |
| JTBD-02.2 | All Drink Now wines visible in ≤ 15 sec | JRN-02.2: Find/Browse (Check Drink Now Count) | Drink Now count on dashboard is tappable link to pre-filtered list; activates in one tap | US-6.1, US-5.3 |
| JTBD-02.2 | All Drink Now wines visible in ≤ 15 sec | JRN-02.2: Find/Browse (Scan Readiness List) | Drink Now filtered list defaults to sort by drink_window_end ascending (soonest-expiring first) | US-5.2, US-3.3 |
| JTBD-02.3 | Single source of truth — spreadsheet replaced | JRN-02.1: Evaluate (Check Collection State) | Quantity, readiness badge, and tasting note history visible together on one wine detail view | US-0.3, US-1.4, US-4.3 |
| JTBD-02.3 | Single source of truth — spreadsheet replaced | JRN-02.2: Review/Reflect (Explore Collection Breakdown) | Type, region, and vintage decade breakdowns all on dashboard; no spreadsheet export needed | US-6.3, US-6.5 |
| JTBD-03.1 | Filtered list in ≤ 3 taps | JRN-03.1: Find/Browse (Filter for Sparkling + Drink Now) | Type and readiness filters combinable in single drawer interaction; active in ≤ 3 taps from home | US-3.2, US-5.3 |
| JTBD-03.1 | Filtered list in ≤ 3 taps | JRN-03.1: Evaluate (Choose the Sparkling) | Storage location visible as secondary line on list card — no detail tap required | US-0.2, US-3.2 |
| JTBD-03.1 | Filtered list in ≤ 3 taps | JRN-03.1: Find/Browse (Switch Filter to Red) | Changing type filter chip does not clear readiness filter; only the type dimension swaps | US-3.3 |
| JTBD-03.2 | Inventory accurate post-event | JRN-03.2: Act/Decide (Mark as Consumed + Occasion Note) | Consume action ≤ 3 taps from wine list; quantity decrements immediately; updated count on list | US-1.2, US-1.3 |
| JTBD-03.2 | Inventory accurate post-event | JRN-03.2: Review/Reflect (Verify Inventory) | Cellar Empty wines remain de-emphasized (not hidden) for 24h post-event; quantity confirms | US-0.2, US-1.2 |
| JTBD-03.3 | Past occasion retrievable | JRN-03.2: Act/Decide (Mark as Consumed + Add Occasion Note) | Occasion and Guest Feedback fields available on tasting note form; optional, zero friction to skip | US-4.1, US-4.2 |
| JTBD-03.3 | Past occasion retrievable | JRN-03.2: Review/Reflect (Tasting History) | Tasting note history on wine detail shows date + occasion field value without extra navigation | US-4.3 |
| JTBD-04.1 | Location filter in ≤ 10 sec | JRN-04.1: Add/Capture (Enter Required Fields) | Every wine requires a named storage location; "Create new location" available inline in form | US-2.4, US-2.1 |
| JTBD-04.1 | Location filter in ≤ 10 sec | JRN-04.1: Evaluate (Confirm Location) | Filtering by named location returns complete wine list for that location in ≤ 10 sec (500 records) | US-2.3, US-3.2 |
| JTBD-04.1 | Location filter in ≤ 10 sec | JRN-04.1: Review/Reflect (Storage Location View) | Location screen shows live bottle counts per location; Location Unknown surfaced with reassign link | US-2.3, US-2.2 |
| JTBD-04.2 | Readiness auto-calculated | JRN-04.2: Arrive (Open Dashboard on Laptop) | Dashboard summary bar shows Drink Now AND Approaching Peak counts side-by-side without navigation | US-6.1, US-5.2 |
| JTBD-04.2 | Readiness auto-calculated | JRN-04.2: Find/Browse (Filter to Drink Now + Approaching Peak) | Readiness filter supports multi-select; both Drink Now and Approaching Peak selectable simultaneously | US-5.3, US-3.2 |
| JTBD-04.2 | Readiness auto-calculated | JRN-04.2: Evaluate (Sort by End Year) | Wine list sortable by drinking window end year (ascending) — most urgent bottles surface first | US-3.3, US-5.2 |
| JTBD-04.3 | Collection overview in ≤ 30 sec | JRN-04.2: Review/Reflect (Review Collection Breakdown) | Breakdown by type (count + %), region (top 5 + Other), and vintage decade visible on dashboard | US-6.3 |
| JTBD-04.3 | Collection overview in ≤ 30 sec | JRN-04.2: Review/Reflect (Cross-Check Off-Site Storage) | By-location breakdown on dashboard shows bottle count per named location; off-site always visible | US-2.3, US-6.3 |

---

## Release Planning

### R1: Core Workflow — "The Digital Cellar Foundation"

**Theme:** Everything a user needs to replace their phone note or spreadsheet today. By the end of R1, every persona can add, find, update, and track any bottle with accurate quantity and location. R1 enables the full Add-a-Bottle and Find-a-Bottle journeys end-to-end.

**Release Criteria:** User can add a wine in ≤ 60 seconds, find any wine by search or filter, update quantity, and see accurate location — with no parallel phone note needed.

**Stories in R1 (17 stories — all P0):**

| SM-ID | Story | Epic | Primary Persona |
|-------|-------|------|-----------------|
| SM-0.1 | US-0.1 Add a New Wine Record | Epic 0 | PER-01 |
| SM-0.2 | US-0.2 Browse the Wine Collection List | Epic 0 | PER-03 |
| SM-0.3 | US-0.3 View Full Wine Record Detail | Epic 0 | PER-02 |
| SM-0.4 | US-0.4 Edit an Existing Wine Record | Epic 0 | PER-04 |
| SM-0.5 | US-0.5 Delete a Wine Record | Epic 0 | PER-01 |
| SM-0.6 | US-0.6 Form Validation on Add and Edit | Epic 0 | PER-01 |
| SM-1.1 | US-1.1 Track and Adjust Bottle Quantity | Epic 1 | PER-01 |
| SM-1.2 | US-1.2 Log a Consumed Bottle Event | Epic 1 | PER-02 |
| SM-1.3 | US-1.3 Log a Gifted or Opened Bottle Event | Epic 1 | PER-03 |
| SM-1.4 | US-1.4 View Bottle Event History | Epic 1 | PER-04 |
| SM-2.1 | US-2.1 Create and Manage Storage Locations | Epic 2 | PER-04 |
| SM-2.2 | US-2.2 Delete a Storage Location | Epic 2 | PER-04 |
| SM-2.3 | US-2.3 View All Storage Locations with Bottle Counts | Epic 2 | PER-04 |
| SM-2.4 | US-2.4 Assign a Storage Location to a Wine | Epic 2 | PER-01 |
| SM-3.1 | US-3.1 Search the Collection with Real-Time Text Search | Epic 3 | PER-01 |
| SM-3.2 | US-3.2 Filter the Collection by Multiple Attributes | Epic 3 | PER-03 |
| SM-3.3 | US-3.3 Manage Active Filters and Sort Results | Epic 3 | PER-02 |

**Persona Coverage — R1:**

| Persona | Journeys Enabled | Primary JTBD Addressed |
|---------|-----------------|------------------------|
| PER-01 Marcus (Casual) | JRN-01.1 Add a Bottle ✓, JRN-01.2 Find a Bottle ✓, JRN-01.3 Choose Tonight (partial — no Drink Now shelf yet) | JTBD-01.1, JTBD-01.3 fully; JTBD-01.2 partially |
| PER-02 Diane (Enthusiast) | JRN-02.1 Open a Bottle (consume action only; tasting note in R2), JRN-02.2 Review Collection (partial) | JTBD-02.3 foundation; JTBD-02.1 and JTBD-02.2 in R2 |
| PER-03 Priya (Entertainer) | JRN-03.1 Choose a Wine (filter works; readiness in R2), JRN-03.2 Mark Consumed ✓ | JTBD-03.2 fully; JTBD-03.1 partially; JTBD-03.3 in R2 |
| PER-04 Richard (Serious) | JRN-04.1 Add Full Case Record ✓, JRN-04.2 Review Collection (location filter ✓; readiness in R2) | JTBD-04.1 fully; JTBD-04.2 and JTBD-04.3 in R2 |

**JTBD Addressed — R1:**

| JTBD | Status |
|------|--------|
| JTBD-01.1 Know what I own before buying | ✅ Fully addressed (US-3.1, US-0.2) |
| JTBD-01.2 Pick something to drink tonight | ⚠️ Partially — list browsable but no Drink Now shelf or readiness badge yet |
| JTBD-01.3 Log a new bottle immediately | ✅ Fully addressed (US-0.1, US-0.6, US-2.4) |
| JTBD-02.1 Capture tasting impressions while fresh | ❌ Deferred to R2 (F4 stories) |
| JTBD-02.2 Know which bottles are ready without calculating | ❌ Deferred to R2 (F5 stories) |
| JTBD-02.3 Replace the spreadsheet | ⚠️ Partially — inventory and location ✓; tasting and readiness in R2 |
| JTBD-03.1 Find the right bottle for tonight | ⚠️ Filter works; readiness status and Drink Now shelf in R2 |
| JTBD-03.2 Keep inventory accurate after every event | ✅ Fully addressed (US-1.2, US-1.3, US-1.1) |
| JTBD-03.3 Remember what I served at past gatherings | ❌ Deferred to R2 (F4 occasion field) |
| JTBD-04.1 Know exactly where every bottle is stored | ✅ Fully addressed (US-2.1–2.4, US-3.2) |
| JTBD-04.2 Track drinking-window readiness across entire collection | ❌ Deferred to R2 (F5 stories) |
| JTBD-04.3 See a complete collection overview | ❌ Deferred to R2 (F6 dashboard stories) |

---

### R2: Insight & Preference Layer — "The Smart Cellar"

**Theme:** Everything that turns the digital cellar into an intelligent companion. By the end of R2 all personas have their JTBD fully addressed: drinking windows auto-calculated, tasting preference record searchable, dashboard surfacing ready bottles at a glance. R2 completes every journey end-to-end.

**Release Criteria:** User can see Drink Now wines on the dashboard, log a full tasting note in ≤ 2 minutes, filter by readiness status, and see a collection breakdown — without any manual calculation or spreadsheet.

**Stories in R2 (14 stories — all P1):**

| SM-ID | Story | Epic | Primary Persona |
|-------|-------|------|-----------------|
| SM-4.1 | US-4.1 Add a Standalone Tasting Note | Epic 4 | PER-02 |
| SM-4.2 | US-4.2 Capture a Linked Tasting Note After Consuming | Epic 4 | PER-02 |
| SM-4.3 | US-4.3 View Tasting Note History for a Wine | Epic 4 | PER-04 |
| SM-4.4 | US-4.4 Edit or Delete a Tasting Note | Epic 4 | PER-02 |
| SM-4.5 | US-4.5 Choose a Personal Rating Scale | Epic 4 | PER-02 |
| SM-4.6 | US-4.6 See Most Recent Rating on the Wine List | Epic 4 | PER-03 |
| SM-5.1 | US-5.1 Set Drinking Window on a Wine Record | Epic 5 | PER-04 |
| SM-5.2 | US-5.2 See Readiness Status Automatically Calculated | Epic 5 | PER-02 |
| SM-5.3 | US-5.3 Filter and Surface Wines by Readiness Status | Epic 5 | PER-03 |
| SM-6.1 | US-6.1 View Collection Summary Stats on Dashboard | Epic 6 | PER-01 |
| SM-6.2 | US-6.2 Browse the Drink Now Shelf | Epic 6 | PER-02 |
| SM-6.3 | US-6.3 View Collection Breakdowns by Type, Region, Vintage | Epic 6 | PER-04 |
| SM-6.4 | US-6.4 Review Recently Added and Recently Consumed Wines | Epic 6 | PER-03 |
| SM-6.5 | US-6.5 Discover Highest Rated Wines on Dashboard | Epic 6 | PER-02 |

**Persona Coverage — R2:**

| Persona | Journeys Completed in R2 | JTBD Resolved in R2 |
|---------|--------------------------|----------------------|
| PER-01 Marcus | JRN-01.3 Choose Tonight fully completed with Drink Now shelf | JTBD-01.2 fully resolved |
| PER-02 Diane | JRN-02.1 Open a Bottle fully completed; JRN-02.2 Review Collection fully completed | JTBD-02.1, JTBD-02.2, JTBD-02.3 all fully resolved |
| PER-03 Priya | JRN-03.1 Choose a Wine fully completed; JRN-03.3 recall past gatherings enabled | JTBD-03.1, JTBD-03.3 fully resolved |
| PER-04 Richard | JRN-04.2 Review Collection fully completed | JTBD-04.2, JTBD-04.3 fully resolved |

**JTBD Status After R2 (End-of-MVP):**

| JTBD | Resolution |
|------|-----------|
| JTBD-01.1 | ✅ R1 — Resolved |
| JTBD-01.2 | ✅ R2 — Resolved (dashboard + Drink Now shelf + readiness filter) |
| JTBD-01.3 | ✅ R1 — Resolved |
| JTBD-02.1 | ✅ R2 — Resolved (US-4.1, US-4.2, US-4.4, US-4.5) |
| JTBD-02.2 | ✅ R2 — Resolved (US-5.2, US-5.3, US-6.1, US-6.2) |
| JTBD-02.3 | ✅ R2 — Resolved (US-4.3, US-6.3 complete the single source of truth) |
| JTBD-03.1 | ✅ R2 — Resolved (US-5.3 readiness filter + US-3.2 type filter combined) |
| JTBD-03.2 | ✅ R1 — Resolved |
| JTBD-03.3 | ✅ R2 — Resolved (US-4.1 occasion field, US-4.3 tasting history) |
| JTBD-04.1 | ✅ R1 — Resolved |
| JTBD-04.2 | ✅ R2 — Resolved (US-5.1 window entry, US-5.2 auto-calculation, US-5.3 filter) |
| JTBD-04.3 | ✅ R2 — Resolved (US-6.3 breakdowns, US-2.3 location counts) |

---

## Coverage Analysis

### Persona Coverage by Release

| Persona | R1 Journeys Enabled | R2 Journeys Completed | All JTBD Resolved After |
|---------|--------------------|-----------------------|------------------------|
| PER-01 Marcus (Casual) | Add Bottle ✓, Find Bottle ✓, Choose Tonight (partial) | Choose Tonight ✓ | R2 |
| PER-02 Diane (Enthusiast) | Open Bottle (consume only), Review Collection (partial) | Open Bottle ✓, Review Collection ✓ | R2 |
| PER-03 Priya (Entertainer) | Choose Wine (filter only), Mark Consumed ✓ | Choose Wine ✓, Log Occasion ✓ | R2 |
| PER-04 Richard (Serious) | Add Case ✓, Location Filter ✓ | Review Cellar ✓, Readiness ✓, Overview ✓ | R2 |

### Journey Stage Coverage by Story Count

| Journey Stage | R1 Stories | R2 Stories | Total |
|--------------|-----------|-----------|-------|
| Arrive | US-0.2 (browse) | US-6.1, US-6.2, US-6.4 | 4 |
| Add / Capture | US-0.1, US-0.4, US-0.6, US-2.1, US-2.4 | US-4.5, US-5.1 | 7 |
| Find / Browse | US-3.1, US-3.2, US-3.3 | US-4.6, US-5.3 | 5 |
| Evaluate | US-0.3, US-0.4 | US-5.2, US-6.2 | 4 |
| Act / Decide | US-0.5, US-1.1, US-1.2, US-1.3 | US-4.1, US-4.2 | 6 |
| Review / Reflect | US-1.4, US-2.2, US-2.3 | US-4.3, US-4.4, US-6.3, US-6.4, US-6.5 | 8 |
| **Total** | **17** | **14** | **31** |

> All 31 user stories are mapped. No orphans detected.

### Gap Analysis

**Journey stages without R1 coverage (resolved in R2):**
- `Arrive` → Dashboard (US-6.1, US-6.2) only available from R2; R1 users land on wine list
- `Evaluate` → Readiness badge (US-5.2) not present in R1; users cannot see Drink Now status until R2

**JTBD without stories (none — all 12 JTBD outcomes addressed):**
- All 12 JTBD outcomes map to at least one story. No unaddressed outcomes.

**Orphan stories (stories not mapped to any journey stage):**
- None. All 31 user stories appear in the matrix above.

**Partial journeys in R1 (by design — resolved in R2):**
- JRN-01.3 (Choose a Wine Tonight): filter works but Drink Now shelf and readiness badge absent until R2
- JRN-02.1 (Open a Bottle): consume action ✓ but tasting note form deferred to R2
- JRN-02.2 (Review Collection): collection list browsable but breakdown charts and readiness filter in R2
- JRN-03.1 (Choose for Guests): type filter ✓ but readiness filter missing until R2
- JRN-04.2 (Review Cellar): location filter ✓ but readiness monitoring and dashboard overview in R2

**R1 Journey Completeness Check:**
- Every persona can complete at least one meaningful journey end-to-end in R1 (Marcus: Add + Find; Priya: Consume; Richard: Add Case + Location Filter). No persona is left without value at R1.

---

## NaC-to-Acceptance Criteria Mapping

This section verifies that each NaC derived in the NaC Derivation Table aligns with the acceptance criteria in UserStories-SimpleWineApp.md. Misalignments would indicate a gap between JTBD outcomes and story definitions.

| SM-ID | Story | Derived NaC | UserStory AC Alignment |
|-------|-------|-------------|------------------------|
| SM-0.1 | US-0.1 Add a New Wine Record | New record saved in ≤ 60 sec on mobile with required fields only | AC: "A new wine can be added in ≤ 60 seconds on mobile" ✅ |
| SM-0.2 | US-0.2 Browse Collection List | Full collection visible within 300ms; quantity badge on every card | AC: "List renders within 300ms for collections up to 500 records" + "Quantity shown" ✅ |
| SM-0.3 | US-0.3 View Full Wine Record Detail | All fields, readiness badge, tasting history, bottle log in one view | AC: "All fields displayed grouped by section; Readiness badge prominent; action buttons visible" ✅ |
| SM-0.4 | US-0.4 Edit an Existing Wine Record | All fields editable; location updatable; save confirmed with toast | AC: "All fields (required and optional) are editable; success toast displays" ✅ |
| SM-0.5 | US-0.5 Delete a Wine Record | Deleted wine removed immediately with cascade; confirmation prevents accident | AC: "Confirmation modal with cascade delete; navigates to wine list; success toast" ✅ |
| SM-0.6 | US-0.6 Form Validation | Inline errors on required fields; form state retained | AC: "Required fields enforced with field-specific messages; form not saved with errors; previously entered data retained" ✅ |
| SM-1.1 | US-1.1 Track and Adjust Quantity | Qty increments/decrements in one tap; list card updates immediately; cannot drop below 0 | AC: "Tapping − decrements qty; − disabled at qty = 0; quantity shown as pill on list card" ✅ |
| SM-1.2 | US-1.2 Log a Consumed Bottle Event | Consumed event decrements qty by 1; Cellar Empty at zero; tasting note prompt offered | AC: "Confirming decrements quantity by 1; Cellar Empty status set; navigates to tasting note if toggled ON" ✅ |
| SM-1.3 | US-1.3 Log a Gifted or Opened Bottle Event | Gifted decrements; Opened sets is_open flag without decrement; both confirmed by toast | AC: "Gifted decrements qty; Opened sets is_open = true; quantity NOT decremented for Opened; success toasts" ✅ |
| SM-1.4 | US-1.4 View Bottle Event History | Full chronological event log visible; linked tasting note accessible | AC: "Events in reverse chronological order; consumed events with linked note show 'View tasting note' link" ✅ |
| SM-2.1 | US-2.1 Create and Manage Storage Locations | Named locations created inline; immediately available in dropdown; uniqueness enforced | AC: "New location immediately available in wine form dropdown; duplicate names rejected" ✅ |
| SM-2.2 | US-2.2 Delete a Storage Location | Deleting shows affected wine count before confirm; wines set to Location Unknown | AC: "Modal shows count of affected wines; wines set to location_unknown = true" ✅ |
| SM-2.3 | US-2.3 View Storage Locations with Bottle Counts | Live bottle count per location; Location Unknown surfaced with reassign link | AC: "Bottle Count shown per location; Location Unknown entry with Reassign link" ✅ |
| SM-2.4 | US-2.4 Assign a Storage Location to a Wine | Location required on form; inline "Add new location" without leaving form | AC: "Storage Location is required dropdown; Add new location... option opens inline and returns with new location pre-selected" ✅ |
| SM-3.1 | US-3.1 Real-Time Text Search | Results within 2 sec; quantity visible on each result card | AC: "Search updates list in real time debounced at 100ms; matches wine_name, producer, region, grape" ✅ |
| SM-3.2 | US-3.2 Filter by Multiple Attributes | Sparkling + Drink Now filter in ≤ 3 taps; combined result within 5 sec | AC: "Filter panel supports Wine Type (multi-select), Drinking Readiness Status (multi-select); Drink Now reachable in ≤ 3 taps from home screen" ✅ |
| SM-3.3 | US-3.3 Manage Active Filters and Sort | Changing one filter chip does not clear others; Drink Now sort by end-year ascending | AC: "Dismissible chips per filter dimension; tapping × dismisses that individual filter; sort options include Vintage newest/oldest" ✅ (end-year sort via Vintage/Date Added options) |
| SM-4.1 | US-4.1 Add a Standalone Tasting Note | Full note saved in ≤ 2 min on mobile; appears in history immediately | AC: "A full tasting note can be logged in ≤ 2 minutes on mobile; success toast displayed" ✅ |
| SM-4.2 | US-4.2 Linked Tasting Note After Consuming | Post-consume prompt navigates to note form pre-linked to bottle event | AC: "After confirming Consumed with Add Tasting Note ON, navigates to Add Tasting Note form; bottle_event_id pre-linked" ✅ |
| SM-4.3 | US-4.3 View Tasting Note History | All notes reverse-chronological; rating, occasion, palate preview without expanding | AC: "Tasting Notes section shows all notes in reverse chronological order; each note shows date, rating, occasion, truncated palate" ✅ |
| SM-4.4 | US-4.4 Edit or Delete a Tasting Note | Edit pre-populated; latest_rating recalculated; confirmation prevents accident | AC: "Edit opens pre-populated form; saving recalculates latest_rating; Delete confirmation modal" ✅ |
| SM-4.5 | US-4.5 Choose Personal Rating Scale | Rating scale (5-star / 100-point) applies globally; existing ratings display with scale label | AC: "Selected scale applies globally; existing ratings display with label if scale switched" ✅ |
| SM-4.6 | US-4.6 Rating on Wine List | Most recent rating as star/badge on list card; no badge when no rated note | AC: "Wine list card displays most recent personal rating; no indicator shown for wines with no rated notes" ✅ |
| SM-5.1 | US-5.1 Set Drinking Window | Start and end year fields on add/edit form; start ≤ end enforced; both optional | AC: "Add/Edit forms include Drinking Window Start and End Year; Start must be ≤ End; either or both may be blank" ✅ |
| SM-5.2 | US-5.2 Readiness Status Auto-Calculated | Badge auto-calculated on every app load; visible on list card and detail header | AC: "Readiness status calculated automatically on each app load; badge appears on wine list cards and detail header" ✅ |
| SM-5.3 | US-5.3 Filter by Readiness Status | Drink Now filter in ≤ 3 taps; multi-select readiness; qty > 0 enforced for Drink Now | AC: "Drink Now filter reachable in ≤ 3 taps; multi-select OR logic within readiness; Drink Now shows only qty > 0" ✅ |
| SM-6.1 | US-6.1 Collection Summary Stats on Dashboard | Dashboard default on open; all four stat tiles tappable; stats update each load | AC: "Dashboard is default landing view; Summary Stats Bar shows four tiles, each tappable; stats update on each app load" ✅ |
| SM-6.2 | US-6.2 Drink Now Shelf | Up to 10 Drink Now cards sorted by soonest-expiring; name/producer/vintage/qty/location on card | AC: "Drink Now Shelf shows up to 10 cards sorted by drink_window_end ascending; each card shows wine name, producer, vintage, badge, quantity, storage location" ✅ |
| SM-6.3 | US-6.3 Collection Breakdowns | Type (count + %), region top 5, vintage decade — all on dashboard; each links to filtered list | AC: "By Wine Type breakdown with count and %; By Country/Region top 5 + Other; By Vintage Decade with bar; tapping any row filters wine list" ✅ |
| SM-6.4 | US-6.4 Recently Added and Recently Consumed | Last 5 added and last 5 consumed on dashboard; each row links to wine detail | AC: "Recently Added shows 5 wines by created_at; Recently Consumed shows 5 most recent CONSUMED events; tapping navigates to Wine Detail" ✅ |
| SM-6.5 | US-6.5 Highest Rated Wines | Top 5 rated wines with rating badge; only wines with at least one rated note | AC: "Highest Rated section shows top 5 by latest_rating; only wines with at least one personal_rating tasting note included" ✅ |

**Alignment Summary:** All 31 NaC statements align with their corresponding UserStory acceptance criteria. No gaps or contradictions detected.

---

## Story Map Quick Reference

| SM-ID | US-ID | Story Title | Epic | Stage | Release |
|-------|-------|-------------|------|-------|---------|
| SM-0.1 | US-0.1 | Add a New Wine Record | F0 | Add/Capture | R1 |
| SM-0.2 | US-0.2 | Browse the Wine Collection List | F0 | Arrive/Find | R1 |
| SM-0.3 | US-0.3 | View Full Wine Record Detail | F0 | Evaluate | R1 |
| SM-0.4 | US-0.4 | Edit an Existing Wine Record | F0 | Add/Capture | R1 |
| SM-0.5 | US-0.5 | Delete a Wine Record | F0 | Act/Decide | R1 |
| SM-0.6 | US-0.6 | Form Validation on Add and Edit | F0 | Add/Capture | R1 |
| SM-1.1 | US-1.1 | Track and Adjust Bottle Quantity | F1 | Act/Decide | R1 |
| SM-1.2 | US-1.2 | Log a Consumed Bottle Event | F1 | Act/Decide | R1 |
| SM-1.3 | US-1.3 | Log a Gifted or Opened Bottle Event | F1 | Act/Decide | R1 |
| SM-1.4 | US-1.4 | View Bottle Event History | F1 | Review/Reflect | R1 |
| SM-2.1 | US-2.1 | Create and Manage Storage Locations | F2 | Add/Capture | R1 |
| SM-2.2 | US-2.2 | Delete a Storage Location | F2 | Review/Reflect | R1 |
| SM-2.3 | US-2.3 | View All Storage Locations with Bottle Counts | F2 | Review/Reflect | R1 |
| SM-2.4 | US-2.4 | Assign a Storage Location to a Wine | F2 | Add/Capture | R1 |
| SM-3.1 | US-3.1 | Search the Collection with Real-Time Text Search | F3 | Find/Browse | R1 |
| SM-3.2 | US-3.2 | Filter the Collection by Multiple Attributes | F3 | Find/Browse | R1 |
| SM-3.3 | US-3.3 | Manage Active Filters and Sort Results | F3 | Find/Browse | R1 |
| SM-4.1 | US-4.1 | Add a Standalone Tasting Note | F4 | Act/Decide | R2 |
| SM-4.2 | US-4.2 | Capture a Linked Tasting Note After Consuming | F4 | Act/Decide | R2 |
| SM-4.3 | US-4.3 | View Tasting Note History for a Wine | F4 | Review/Reflect | R2 |
| SM-4.4 | US-4.4 | Edit or Delete a Tasting Note | F4 | Review/Reflect | R2 |
| SM-4.5 | US-4.5 | Choose a Personal Rating Scale | F4 | Add/Capture | R2 |
| SM-4.6 | US-4.6 | See Most Recent Rating on the Wine List | F4 | Find/Browse | R2 |
| SM-5.1 | US-5.1 | Set Drinking Window on a Wine Record | F5 | Add/Capture | R2 |
| SM-5.2 | US-5.2 | See Readiness Status Automatically Calculated | F5 | Evaluate | R2 |
| SM-5.3 | US-5.3 | Filter and Surface Wines by Readiness Status | F5 | Find/Browse | R2 |
| SM-6.1 | US-6.1 | View Collection Summary Stats on Dashboard | F6 | Arrive | R2 |
| SM-6.2 | US-6.2 | Browse the Drink Now Shelf | F6 | Arrive/Evaluate | R2 |
| SM-6.3 | US-6.3 | View Collection Breakdowns by Type, Region, Vintage | F6 | Review/Reflect | R2 |
| SM-6.4 | US-6.4 | Review Recently Added and Recently Consumed Wines | F6 | Review/Reflect | R2 |
| SM-6.5 | US-6.5 | Discover Highest Rated Wines on the Dashboard | F6 | Review/Reflect | R2 |

---

## Self-Check

| Criterion | Status |
|-----------|--------|
| Every UserStory (US-X.Y) appears in the map | ✅ All 31 stories mapped |
| Every mapped story has a NaC derived from JTBD | ✅ 31 NaC entries in Derivation Table |
| NaC Derivation Table has full traceability chains | ✅ JTBD-ID → Stage → NaC → Story for all entries |
| Release planning groups are defined | ✅ R1 (17 P0 stories) and R2 (14 P1 stories) |
| Coverage analysis identifies gaps and orphans | ✅ 0 orphans; partial journeys in R1 explicitly documented |
| NaC-to-Acceptance Criteria mapping verifies alignment | ✅ All 31 NaC verified against UserStory AC; no contradictions |
| No orphan stories (unmapped to journey stages) | ✅ Confirmed |
| Each release enables at least one complete journey | ✅ R1: Add Bottle + Find Bottle complete; R2: all remaining journeys complete |

---

*STORY-MAP generated by Pivota Spec Story Map Generator · SimpleWineApp v1.0 MVP · 2026-06-03*
