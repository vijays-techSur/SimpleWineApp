# Product Requirements Document
## SimpleWineApp — Personal Wine Collection Manager

**Project:** SimpleWineApp  
**Version:** 1.0 — MVP  
**Date:** 2026-06-03  
**Status:** Draft  
**Author:** Pivota Spec PRD Generator

---

## 1. Executive Summary

SimpleWineApp is a personal wine collection management web application that gives wine enthusiasts a clean, mobile-first digital cellar. Users can track bottles, manage storage locations, record tasting notes, monitor drinking windows, and view simple insights into their collection — all through an interface built on USWDS standards and styled with the TechSur brand design system (gold/black palette, Montserrat/Open Sans/JetBrains Mono typography). The MVP establishes the personal workflow foundation — a structured, searchable, decision-ready alternative to spreadsheets and informal tracking methods — before any commercial or multi-tenant capabilities are introduced.

---

## 2. Problem Statement

Personal wine collectors accumulate bottles across locations, vintages, and occasions — and most rely on informal methods that break down as the collection grows. Memory, paper notes, phone photos, and spreadsheets do not provide enough structure, search capability, or decision support to make a growing collection manageable or enjoyable.

Without a dedicated tool, collectors routinely face:

- **Forgotten inventory** — not knowing what bottles they actually own
- **Lost location context** — storing bottles in multiple places with no reliable map
- **Missed drinking windows** — opening bottles too early, too late, or past their peak
- **Accidental duplicates** — purchasing wines already in the cellar
- **Lost tasting impressions** — forgetting what they thought of a wine after opening it
- **Poor occasion matching** — struggling to choose the right bottle for a meal or guest
- **No collection view** — having no sense of the size, value, or composition of the collection

This application addresses these problems by giving the user a centralized, structured, and searchable view of their personal wine cellar — fast enough to use daily and clear enough to answer the three core questions in seconds: *What wine do I have? Where is it stored? What should I drink next?*

---

## 3. Product Vision

**Vision Statement:** To help wine enthusiasts manage and enjoy their personal wine collections with clarity, confidence, and ease through a modern, intuitive digital cellar experience.

**Strategic Goals:**

- Replace spreadsheets and informal tracking with a structured, searchable personal cellar
- Make adding wine fast enough that users do it immediately after a purchase
- Surface drinking-ready bottles prominently so users make better opening decisions
- Build a tasting and preference record that grows in value the longer the user stays
- Prove the personal workflow before expanding into intelligence, AI, or multi-user features
- Apply the TechSur brand design system over USWDS foundations to deliver a refined, accessible, and visually distinctive experience

**Guiding Principles:**

1. Keep the experience simple — every screen should have one clear purpose
2. Make adding wine fast — minimize required fields, maximize usability
3. Make finding wine effortless — search and filter are first-class features
4. Help the user make better decisions — drinking window status is always visible
5. Focus on personal preference, not expert complexity — no wine expertise required
6. Support enjoyment, not just inventory management — this is a cellar companion, not a ledger
7. Build intelligence gradually after the core workflow is proven

---

## 4. Target Users

| Persona | Description | Primary Need |
|---------|-------------|--------------|
| Casual Collector | Owns a small but growing collection, informal tracker today | Simple bottle tracking and easy wine selection |
| Enthusiast | Regularly buys and drinks wine, wants to track preferences over time | Tasting notes, drinking windows, collection insights |
| Home Entertainer | Hosts dinners and gatherings, selects wine for guests | Quick search to find the right bottle for the occasion |
| Serious Collector | Owns higher-value bottles across vintages and multiple storage locations | Storage precision, readiness tracking, collection overview |

> **Out of scope for MVP:** Family Household User (shared accounts) — deferred to Phase 4.

---

## 5. Technical Architecture

| Layer | Technology / Constraint |
|-------|------------------------|
| UI Framework | USWDS (U.S. Web Design System) — all components use or extend USWDS design tokens and patterns |
| Brand Overlay | TechSur Design System applied over USWDS baseline |
| Primary Accent | Gold `#FBCA5C` (Gold 400) |
| Canvas — Dark | Black `#0A0A0A` |
| Canvas — Light | Bone `#FAFAF7`, Paper `#F5F5F2` |
| Body Text | Ink `#1A1A1A` |
| Muted / Labels | Gray 400 `#A8A59B` |
| Display / Headlines | Montserrat 900 — tight tracking |
| Serif Accent | Fraunces italic — accent words and emphasis |
| Body Copy | Open Sans 400 / 600 / 700 |
| Labels / Eyebrows | JetBrains Mono 400–500 — UPPERCASE |
| Button Style | 2px radius, Montserrat 700, UPPERCASE, +1px tracking |
| Responsive Target | Mobile-first; fully functional at 375px viewport width and up |
| Deployment Target | Web application (single-user, personal-use, no multi-tenant in v1) |
| Data Storage | Local or cloud-backed persistent store (architecture TBD in TechArch) |
| Accessibility | USWDS WCAG 2.1 AA compliance baseline required |

---

## 6. Feature Requirements

### F0: Wine Inventory CRUD

**Description:** The core data management feature allows users to create, view, edit, and delete wine records in their collection. This is the foundational capability from which all other features are built. Every wine in the cellar is represented as a record with structured fields covering identity, provenance, storage, and acquisition context.

**Capabilities:**

- Add a new wine record with the following fields:
  - Wine name (required)
  - Producer / Winery (required)
  - Vintage year (required)
  - Wine type — Red, White, Rosé, Sparkling, Dessert, Fortified (required)
  - Grape variety or blend
  - Country and Region / Appellation
  - Bottle size (standard 750ml default; supports 375ml, 1.5L, 3L)
  - Quantity owned (required; integer ≥ 1)
  - Storage location (required; see F2)
  - Purchase date, purchase source, purchase price
  - Drinking window — start year and end year
  - Free-text notes field
- View the complete wine list with key attributes displayed per entry
- Edit any field on any existing wine record
- Delete a wine record with confirmation prompt
- View individual wine detail page showing all fields
- Form validation: required fields enforced, vintage year must be numeric and plausible (1900–current+1)

**Priority:** P0 (Critical — MVP foundation)

---

### F1: Quantity & Bottle Status Tracking

**Description:** Users need to track how many physical bottles they hold for each wine and update that count as bottles are consumed, gifted, or opened. This feature manages the lifecycle of individual bottle units — from purchase through consumption — and maintains an accurate live count of what is in the cellar.

**Capabilities:**

- Display current quantity on every wine list row and detail view
- Increment / decrement quantity with single-tap controls on the detail view
- Mark a bottle event via a dedicated action:
  - **Consumed** — user drank the bottle (decrements quantity, links to tasting note)
  - **Gifted** — bottle was given away (decrements quantity, optional recipient note)
  - **Opened** — bottle was opened but not yet fully consumed (status flag)
- Quantity reaching zero changes the wine's status to "Cellar Empty" and visually distinguishes the record
- Bottle event log stored per wine record (date, event type, note)
- Consumed and gifted events optionally prompt user to add a tasting note (see F4)

**Priority:** P0 (Critical — MVP requirement)

---

### F2: Storage Location Management

**Description:** Users store bottles across different physical locations — a wine fridge, a dedicated cellar, a kitchen rack, a basement, or a storage unit. This feature allows users to define named storage locations and assign each wine to a location so they can always answer "Where is it?"

**Capabilities:**

- User-defined storage locations: create, rename, and delete named locations (e.g., "Wine Fridge — Top Shelf," "Basement Cellar," "Kitchen Rack")
- Assign one storage location per wine record (required field on wine entry form)
- Filter the wine list by storage location (see F3)
- Storage location displayed prominently on wine detail and wine list card
- When a location is deleted, wines assigned to it are flagged as "Location Unknown" rather than silently broken
- No maximum limit on number of defined locations in v1

**Priority:** P0 (Critical — MVP requirement)

---

### F3: Search & Filter

**Description:** As a collection grows, browsing a flat list becomes impractical. This feature gives users fast, flexible ways to find the right bottle — whether they know exactly what they want or are exploring what is available and ready to drink.

**Capabilities:**

- **Full-text search bar** — searches across wine name, producer, region, grape fields, and occasion (from the wine's most recent tasting note); results update as user types (client-side filter, no server round-trip required)
- **Filter panel / drawer** (collapsible on mobile) supporting filter by:
  - Wine type (Red, White, Rosé, Sparkling, Dessert, Fortified)
  - Producer
  - Country and/or Region
  - Vintage year (exact or range)
  - Grape variety
  - Storage location
  - Drinking readiness status (Drink Now, Hold, Approaching Peak, Past Window — derived from drinking window field and current date)
  - Personal rating range (once rated; see F4)
- Active filters displayed as dismissible chips above the wine list
- "Clear all filters" control
- Sort options: Wine Name (A–Z), Vintage (newest / oldest), Quantity (high / low), Date Added (newest / oldest), Rating (highest / lowest), Drinking Window End (soonest / latest first)
- When the Drink Now readiness filter is active and no explicit sort has been selected, the default sort is Drinking Window End: Soonest first
- Filter state persists during the session; resets on app close

**Priority:** P0 (Critical — MVP requirement)

---

### F4: Tasting Notes & Personal Ratings

**Description:** After opening a bottle, users can record their personal tasting experience — what they tasted, how they would rate it, and whether they would buy it again. Over time this builds a personal preference record that makes the collection more intelligent and more enjoyable.

**Capabilities:**

- Add a tasting note to any wine record (can be added without a consume/open event, for pre-purchase notes or notes taken at a restaurant)
- Tasting note fields:
  - Date tasted
  - Appearance (free text, optional)
  - Aroma (free text, optional)
  - Flavor / palate (free text, optional)
  - Finish (free text, optional)
  - Personal rating — 1–5 stars or 1–100 point scale (user-selectable preference in settings; default 5-star)
  - Would buy again — Yes / No / Maybe toggle
  - Occasion (free text, optional — e.g., "Anniversary dinner," "Friday night")
  - Guest feedback (free text, optional)
- Multiple tasting notes allowed per wine (separate dated entries)
- Most recent rating displayed on wine list card and detail view
- Tasting note history listed chronologically on wine detail view
- Wines with tasting notes are searchable / filterable by rating range (see F3)

**Priority:** P1 (High — MVP requirement)

---

### F5: Drinking Window Management

**Description:** The drinking window is the date range during which a wine is expected to be at or near its peak quality. This feature calculates and displays a readiness status for every wine in the collection — giving users an immediate, at-a-glance answer to "What should I drink now?" without requiring them to remember every bottle's ideal timing.

**Capabilities:**

- Drinking window captured as start year and end year on the wine entry form (both optional; wines without a window show "No Window Set")
- Readiness status calculated automatically from the current date and the drinking window:
  - **Drink Now** — current year is within the start–end range
  - **Hold** — current year is before the start year
  - **Approaching Peak** — current year is within 1–2 years before the start year
  - **Past Window** — current year exceeds the end year
  - **No Window Set** — no drinking window data entered
- Readiness status displayed as a color-coded badge on the wine list card and detail view:
  - Drink Now → Gold accent `#FBCA5C`
  - Approaching Peak → Amber / warm tones
  - Hold → Neutral gray
  - Past Window → Muted / de-emphasized
- Dashboard highlights "Drink Now" wines prominently (see F6)
- Wines can be filtered by readiness status (see F3)
- Readiness recalculates on each app load — no manual refresh needed

**Priority:** P1 (High — MVP requirement)

---

### F6: Collection Dashboard & Insights

**Description:** The dashboard is the home screen of the application — a lightweight summary view that gives the user an immediate picture of their collection without having to browse the full list. It answers "What do I have?" and "What should I drink next?" at a glance, and surfaces simple collection-level insights to help the user understand the shape of their cellar.

**Capabilities:**

- **Summary stats bar** (always visible on dashboard):
  - Total bottles in cellar (sum of quantity across all wines with quantity > 0)
  - Total unique wine records
  - Wines ready to drink now (count of wines with "Drink Now" status)
  - Wines approaching peak (count of wines with "Approaching Peak" status)
- **Drink Now shelf** — horizontal scrollable card row (or compact list on mobile) showing the top wines with "Drink Now" status, sorted by end year ascending (drink soonest first)
- **Collection breakdown** — simple visual breakdowns:
  - By wine type (Red / White / Rosé / Sparkling / Dessert / Fortified) — count and percentage
  - By country/region — top 5 regions by bottle count
  - By vintage decade — bottle count grouped by decade
- **Recently added** — last 5 wines added to the collection
- **Recently consumed** — last 5 bottle-consumed events logged
- **Highest rated** — top 5 wines by personal rating (if tasting notes exist)
- Dashboard is the default landing view after app open
- All dashboard cards link to the full filtered wine list for that segment

**Priority:** P1 (High — MVP requirement)

---

## 7. Design & UX Requirements

### 7.1 USWDS Foundation

All UI components must use or extend USWDS design tokens and component patterns. This includes:

- USWDS form components for all input fields (text inputs, selects, checkboxes, radio buttons)
- USWDS button patterns as the base for all interactive controls
- USWDS grid system for responsive layout
- USWDS accessibility patterns — all components must meet WCAG 2.1 AA at minimum
- USWDS typography scale tokens as the sizing baseline (overridden by TechSur type families)

### 7.2 TechSur Brand Overlay

The TechSur design system is applied on top of USWDS tokens as a brand layer. All brand rules from the TechSur Brand Guide v1.0 apply:

**Colors:**

- Primary canvas (dark mode / hero areas): Black `#0A0A0A`
- Light canvas: Bone `#FAFAF7`; Alt card surface: Paper `#F5F5F2`
- Primary accent (CTAs, badges, key UI emphasis): Gold 400 `#FBCA5C`
- Serif accent on light backgrounds: Gold 500 `#E6B040`
- Eyebrows / links on paper: Gold 600 `#B0832A`
- Body text on light: Ink `#1A1A1A`
- Muted labels: Gray 400 `#A8A59B`
- Gold must remain ≤10% of any given view — accent only, never fill
- Gold 400 text must not appear on Bone backgrounds (contrast failure) — use Gold 600 for text on light

**Typography:**

- Display / Section headings: Montserrat 900, tight tracking (−2 to −5px), sentence case
- Serif accent word (italic emphasis): Fraunces 400–600 italic
- Body / lead paragraphs: Open Sans 400 / 600 / 700
- Eyebrows, labels, badges, fact strips: JetBrains Mono 400–500, UPPERCASE, +1–2px tracking
- Buttons: Montserrat 700, UPPERCASE, +1px tracking

**Buttons:**

- Sharp corners (2px radius)
- Primary CTA: Gold 400 fill, Black text
- Inverse CTA (on gold band): Black fill, Gold 400 text
- Ghost / secondary: Transparent fill, Ink/Black text

### 7.3 Mobile-First Layout

- All views must be fully functional and visually correct at 375px viewport width
- Touch targets minimum 44×44px
- Navigation collapses to hamburger / bottom nav pattern on mobile
- Wine list uses card layout on mobile; can expand to table view on desktop
- Filter panel opens as a drawer on mobile, sidebar on desktop
- Dashboard cards stack vertically on mobile, grid on desktop

### 7.4 Key User Journeys

| Journey | Entry Point | Goal |
|---------|-------------|------|
| Add a Bottle | "+" FAB or nav action | Complete wine record in under 60 seconds |
| Find a Bottle | Search bar or filter panel | Locate a specific wine by name, producer, or attribute |
| Choose a Wine Tonight | Dashboard → Drink Now shelf | Pick from ready-to-drink options |
| Open a Bottle | Wine detail → "Open / Consume" action | Log the event, optionally add tasting note |
| Review the Collection | Dashboard → collection breakdown | Understand what I own and how it is composed |

---

## 8. Non-Functional Requirements

| Category | Requirement |
|----------|-------------|
| Performance | Wine list renders within 300ms for collections up to 500 records on a mid-range mobile device |
| Performance | Search / filter results update within 100ms (client-side) |
| Accessibility | WCAG 2.1 AA compliance for all components via USWDS baseline |
| Accessibility | All form fields have visible labels; no placeholder-only labeling |
| Accessibility | Color is never the sole differentiator for status — all readiness badges include text label |
| Responsiveness | Fully functional at 375px, 768px, 1024px, and 1280px viewport widths |
| Data Integrity | Quantity can never drop below zero; decrement disabled at zero |
| Data Integrity | Required fields enforced before record save; clear inline validation messages |
| Usability | New user can add their first wine in under 60 seconds without instructions |
| Usability | All destructive actions (delete wine, delete location) require confirmation |
| Browser Support | Latest 2 versions of Chrome, Firefox, Safari, Edge on mobile and desktop |
| Offline | Core wine list read and search functional offline (progressive enhancement; no offline write required in v1) |
| Privacy | No user data sent to third-party analytics or external services in v1 |

---

## 9. Success Metrics

The MVP is considered successful when the primary user can consistently accomplish each of the following without friction or instruction:

| Metric | Target |
|--------|--------|
| Add a new wine record | Completed in ≤ 60 seconds on mobile |
| Find a specific wine | Located via search or filter in ≤ 15 seconds |
| Track quantity accurately | Quantity reflects actual cellar count with no manual reconciliation needed |
| Identify wines ready to drink | "Drink Now" wines visible on dashboard without any additional navigation |
| Record a tasting note | Logged within 2 minutes of opening a bottle |
| Replace spreadsheet as primary tracker | User stops using any parallel tracking method within 30 days of adoption |

**Engagement signals to monitor post-launch:**

- Number of wine records added (collection adoption depth)
- Return visit frequency (daily / weekly / monthly active use)
- Tasting notes logged per consumed bottle (end-to-end usage completion)
- Searches and filter sessions per month (discovery feature utilization)
- Drink Now views from dashboard (decision-support feature value)

---

## 10. Out of Scope — MVP v1

The following capabilities are explicitly excluded from this release and deferred to future phases per the business vision:

| Feature | Phase |
|---------|-------|
| Label scanning via phone camera | Phase 3 |
| AI-assisted bottle entry | Phase 3 |
| Food pairing suggestions | Phase 2 |
| Occasion-based recommendations | Phase 2 |
| Drinking window alerts / push notifications | Phase 2 |
| Import from spreadsheet (CSV/Excel) | Phase 2 |
| Export to spreadsheet or PDF | Phase 2 (low priority) |
| Shared household accounts | Phase 4 |
| Wine valuation and estimated value tracking | Phase 2 |
| Cellar map or storage visualization | Phase 2 |
| Integration with external wine databases | Phase 3 |
| Commercial / restaurant / retail features | Permanently excluded |
| Point-of-sale or distributor workflows | Permanently excluded |

---

## 11. Risks & Mitigations

| Risk | Description | Likelihood | Impact | Mitigation |
|------|-------------|------------|--------|------------|
| Data entry burden | Users resist manually entering every bottle | High | High | Minimize required fields to 4 (name, producer, vintage, type + quantity + location); make remaining fields optional; speed is the primary UX goal |
| Feature complexity | Too many fields or views makes the app feel like work | Medium | High | Enforce a focused MVP; review all proposed fields against the "would a casual user understand this?" test |
| Low repeat usage | Users add wine once and rarely return | Medium | High | Dashboard and Drink Now shelf give a reason to open the app before every meal; tasting note prompt after consume event drives return |
| Overbuilding | Scope creep pulls in Phase 2+ features before MVP is proven | Medium | Medium | This PRD is the explicit scope boundary; any Phase 2+ feature requires a new PRD revision and explicit approval |
| Brand/USWDS tension | TechSur gold-on-black aesthetic conflicts with USWDS default token assumptions | Low | Medium | Define TechSur tokens as a CSS override layer on top of USWDS; document mapping in design tokens file |
| Wine data accuracy | User enters incorrect drinking windows or vintage data | Low | Low | All data is user-controlled; no auto-populated third-party data in v1; validation limited to format, not content |

---

## 12. Feature Index

| ID | Feature | Priority | Phase | Description |
|----|---------|----------|-------|-------------|
| F0 | Wine Inventory CRUD | P0 — Critical | MVP | Add, view, edit, delete wine records with full field set |
| F1 | Quantity & Bottle Status Tracking | P0 — Critical | MVP | Track bottle count; log consumed, gifted, opened events |
| F2 | Storage Location Management | P0 — Critical | MVP | User-defined named locations; assign per wine record |
| F3 | Search & Filter | P0 — Critical | MVP | Full-text search + multi-attribute filter panel; sort options |
| F4 | Tasting Notes & Personal Ratings | P1 — High | MVP | Record tasting experience; 1–5 star or 100-point rating; preference history |
| F5 | Drinking Window Management | P1 — High | MVP | Auto-calculated readiness status (Drink Now / Hold / Approaching Peak / Past Window) |
| F6 | Collection Dashboard & Insights | P1 — High | MVP | Home screen with summary stats, Drink Now shelf, collection breakdowns |

**Priority key:**
- P0 = Critical — MVP cannot ship without this feature
- P1 = High — Strong MVP requirement; included in v1 release
- P2 = Medium — Valuable addition; Phase 2 candidate
- P3 = Low — Future enhancement; Phase 3+ candidate

---

## 13. Related Documents

| Document | Location | Status |
|----------|----------|--------|
| PROJECT.md | `.planning/PROJECT.md` | Complete |
| Business Vision | `project_specs/ref_docs/Wine Collection Software Business Vision.pdf` | Source document |
| TechSur Brand Guide | `project_specs/ref_docs/TechSur-Brand-Guide 1.pdf` | Source document |
| FRD | `project_specs/FRD-SimpleWineApp.md` | Pending |
| TechArch | `project_specs/TechArch-SimpleWineApp.md` | Pending |
| User Stories | `project_specs/UserStories-SimpleWineApp.md` | Pending |

---

*PRD generated by Pivota Spec PRD Generator · SimpleWineApp v1.0 MVP · 2026-06-03*
