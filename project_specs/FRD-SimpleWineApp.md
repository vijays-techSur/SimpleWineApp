# Functional Requirements Document
## SimpleWineApp — Personal Wine Collection Manager

**Project:** SimpleWineApp
**FRD Version:** 1.0
**PRD Reference:** PRD-SimpleWineApp.md v1.0
**Date:** 2026-06-03
**Status:** Draft
**Author:** Pivota Spec FRD Generator

---

## Scope

This document specifies the detailed functional behavior of all MVP features (F0–F6) for SimpleWineApp. It covers inputs, outputs, validation rules, error states, API surface, and database schema for each feature. This FRD is the authoritative reference for implementation — developers should be able to build any feature from this document without requiring additional clarification on functional behavior.

Out of scope for this FRD: Phase 2+ features (food pairing, CSV import/export, notifications, valuation tracking, cellar map), Phase 3+ features (label scanning, AI entry, external wine database integration), and Phase 4 features (shared household accounts). All UI must implement USWDS component patterns with the TechSur brand overlay.

---

## How to Read This Document

- **Feature chunks** (`F00`–`F06`) each cover one PRD feature end-to-end.
- **Cross-feature chunks** (`Y0`–`Y3`) consolidate schema, API, errors, and integrations.
- Per-feature API and schema sections reference the canonical `Y1-api.md` and `Y0-schema.md` for full specs.
- Feature IDs in cross-references use format `F{nn} §{Section}` (e.g., `F00 §Process step 3`).
- All field names in code format (e.g., `wine_name`) match the API request/response bodies and database column names.
- HTTP status codes follow RFC 9110.
- All timestamps are ISO 8601 UTC.

---

## Conventions

| Convention | Meaning |
|-----------|---------|
| **Required** | Field must be present and non-empty to save a record |
| **Optional** | Field may be omitted; stored as NULL or empty string |
| `snake_case` | API field names and database column names |
| `PascalCase` | Entity/model names |
| `UPPER_CASE` | Error codes and enum values |
| `[A–Z, a–z]` | Validation character class notation |
| ≥, ≤, <, > | Numeric boundary (inclusive unless noted) |

---

## Shared Terminology

| Term | Definition |
|------|-----------|
| **Wine Record** | A single entry in the cellar representing one wine (producer + label + vintage). A wine record may have many bottles (quantity). |
| **Bottle Event** | A logged action against one bottle unit: Consumed, Gifted, or Opened. Decrements quantity (Consumed, Gifted) or sets a status flag (Opened). |
| **Drinking Window** | The date range (start year – end year) during which a wine is expected to be at or near peak quality. |
| **Readiness Status** | Calculated label derived from the drinking window and current year: Drink Now, Hold, Approaching Peak, Past Window, or No Window Set. |
| **Storage Location** | A user-defined named physical location where bottles are stored (e.g., "Wine Fridge – Top Shelf"). |
| **Tasting Note** | A dated personal record of a wine tasting event, including sensory descriptors and a personal rating. |
| **Collection** | The full set of wine records owned by the user with quantity > 0. |
| **Cellar Empty** | Status applied to a wine record whose quantity has reached zero. |
| **Personal Rating** | User's numeric quality assessment of a wine. Default scale: 1–5 stars. Alternate: 1–100 points (user-selectable in settings). |
| **USWDS** | U.S. Web Design System — the UI component and accessibility foundation. |
| **TechSur Brand** | Design overlay applied on top of USWDS: Gold/Black/Bone palette, Montserrat/Fraunces/Open Sans/JetBrains Mono typography. |

---

## Brand & Design Token Reference

| Token | Value | Usage |
|-------|-------|-------|
| `--color-gold-400` | `#FBCA5C` | Primary accent, CTAs, Drink Now badge, primary buttons |
| `--color-gold-500` | `#E6B040` | Serif accent on light backgrounds |
| `--color-gold-600` | `#B0832A` | Gold text on light backgrounds (contrast-safe) |
| `--color-canvas-dark` | `#0A0A0A` | Hero areas, nav background (dark variant) |
| `--color-bone` | `#FAFAF7` | Light canvas, page background |
| `--color-paper` | `#F5F5F2` | Alt card surface |
| `--color-ink` | `#1A1A1A` | Body text on light |
| `--color-gray-400` | `#A8A59B` | Muted labels, secondary text |
| `--font-display` | Montserrat 900 | Section headings, tight tracking |
| `--font-accent` | Fraunces 400–600 italic | Accent words, emphasis |
| `--font-body` | Open Sans 400/600/700 | Body copy, lead paragraphs |
| `--font-mono` | JetBrains Mono 400–500 | Labels, badges, eyebrows — UPPERCASE |
| `--font-button` | Montserrat 700 | Buttons — UPPERCASE, +1px tracking |
| `--radius-button` | 2px | Button border radius |

> **Accessibility rules:** Gold 400 (`#FBCA5C`) text must NOT appear on Bone (`#FAFAF7`) backgrounds — use Gold 600 instead. Gold must remain ≤10% of any given view. All readiness status badges must include a text label (color alone is never the sole differentiator).

---

## Table of Contents

| Section | File | Feature |
|---------|------|---------|
| F00 | `F00-wine-inventory-crud.md` | Wine Inventory CRUD |
| F01 | `F01-quantity-bottle-status.md` | Quantity & Bottle Status Tracking |
| F02 | `F02-storage-locations.md` | Storage Location Management |
| F03 | `F03-search-filter.md` | Search & Filter |
| F04 | `F04-tasting-notes-ratings.md` | Tasting Notes & Personal Ratings |
| F05 | `F05-drinking-window.md` | Drinking Window Management |
| F06 | `F06-collection-dashboard.md` | Collection Dashboard & Insights |
| Y0 | `Y0-schema.md` | Database Schema (full DDL) |
| Y1 | `Y1-api.md` | REST API Endpoints |
| Y2 | `Y2-errors.md` | Cross-Feature Error Catalog |
| Y3 | `Y3-integrations.md` | External Integration Points |

---
---

## F00: Wine Inventory CRUD

**PRD Reference:** F0 — Priority P0 (Critical)

**Description:** The core data management feature that allows users to create, view, edit, and delete wine records in their personal cellar. Every wine in the cellar is represented as a structured record covering identity, provenance, storage assignment, acquisition context, and drinking window. This is the foundational capability from which all other features (F1–F6) are built — no other feature functions without wine records existing.

---

### Terminology

| Term | Definition |
|------|-----------|
| **Wine Record** | The primary entity: a single wine entry identified by producer + label + vintage. One record may represent multiple physical bottles (quantity ≥ 1). |
| **Required Fields** | The minimum set of fields that must be populated to create or save a wine record. |
| **Optional Fields** | Fields that enrich the record but may be omitted. Stored as NULL in the database. |
| **Estimated Value** | User-entered current market value estimate per bottle. Not calculated automatically in v1. |
| **Appellation** | A legally defined wine-producing geographic designation (e.g., Napa Valley AVA, Bordeaux AOC). Sub-division of Region. |
| **Bottle Size** | Physical volume of the wine bottle. Supported sizes: 375ml (half-bottle), 750ml (standard), 1.5L (Magnum), 3L (Double Magnum). |

---

### Sub-Features

- **F00.1 — Add Wine:** Create a new wine record via form with all fields
- **F00.2 — Wine List View:** Browse all wines in a card/table list with key attributes
- **F00.3 — Wine Detail View:** View all fields for a single wine record
- **F00.4 — Edit Wine:** Modify any field on an existing wine record
- **F00.5 — Delete Wine:** Remove a wine record with confirmation prompt
- **F00.6 — Form Validation:** Enforce required fields and field-level format rules before save

---

### Process

#### F00.1 — Add Wine

1. User taps the "+" floating action button (FAB) or the "Add Wine" navigation action.
2. System displays the Add Wine form with all fields (required fields marked with asterisk).
3. User fills in required fields: Wine Name, Producer, Vintage Year, Wine Type, Quantity, Storage Location.
4. User optionally fills in: Country, Region, Appellation, Grape Variety, Bottle Size, Purchase Date, Purchase Source, Purchase Price, Estimated Value, Drinking Window Start, Drinking Window End, Notes.
5. User submits the form.
6. System validates all required fields are present and all format rules pass (see Validation).
7. If validation fails, system highlights failed fields with inline error messages; form is NOT saved.
8. If validation passes, system saves the wine record to the data store.
9. System assigns a unique `wine_id` (UUID), sets `created_at` and `updated_at` timestamps.
10. System navigates the user to the Wine Detail view for the newly created record.
11. System displays a success toast: "Wine added to your cellar."

#### F00.2 — Wine List View

1. User navigates to the Wine List (main collection view).
2. System fetches all wine records, defaulting to sort by `date_added` descending (newest first).
3. System renders each wine as a card (mobile) or table row (desktop) showing: Wine Name, Producer, Vintage, Wine Type badge, Readiness Status badge (from F05), Quantity, Storage Location.
4. "Cellar Empty" wines (quantity = 0) are visually de-emphasized (muted opacity) but still shown by default.
5. **Empty collection state:** If the user has no wine records at all (brand-new user or all records deleted), the Wine List displays an onboarding empty state: "Your cellar is empty. Tap '+' to add your first wine." with a prominent "Add Wine" CTA button. This applies in both R1 (before the dashboard is available) and R2.
6. User may apply search or filters (see F03) to narrow the list.
7. Active filter state is displayed as dismissible chips above the list.
8. **Data load failure:** If the API fails to return wine data, the Wine List displays an inline error banner at the top of the view: "Unable to load wines. Pull to refresh or try again." The list area below the banner is empty; the "+" FAB remains accessible.

#### F00.3 — Wine Detail View

1. User taps a wine card or row in the list.
2. System fetches the full wine record by `wine_id`.
3. System renders all fields, grouped by section: Identity, Provenance & Purchase, Storage, Drinking Window, Tasting Notes (from F04), Bottle Event Log (from F01).
4. Readiness Status badge is displayed prominently (derived from F05).
5. Action buttons displayed: "Edit," "Open / Consume Bottle," "Add Tasting Note," "Delete."
6. **Data load failure:** If the API fails to return the wine record, the detail view displays an inline error banner: "Unable to load wine details. Pull to refresh or try again." Action buttons are hidden until data loads successfully.

#### F00.4 — Edit Wine

1. User taps "Edit" on the Wine Detail view.
2. System displays the Edit Wine form pre-populated with all current field values.
3. User modifies any field(s).
4. User submits the form.
5. System validates all required fields and format rules (same rules as Add Wine).
6. If validation fails, inline errors are shown; record is NOT saved.
7. If validation passes, system updates the record and sets `updated_at` to current timestamp.
8. System navigates back to the Wine Detail view and displays a success toast: "Wine record updated."

#### F00.5 — Delete Wine

1. User taps "Delete" on the Wine Detail view.
2. System displays a confirmation modal: "Delete [Wine Name]? This will permanently remove this wine and all associated tasting notes. This cannot be undone." with "Cancel" and "Delete" buttons.
3. If user confirms, system deletes the wine record and all associated tasting notes and bottle events (cascade delete).
4. System navigates to the Wine List view.
5. System displays a success toast: "Wine record deleted."
6. If user cancels, modal closes with no changes made.

---

### Inputs

**Required Fields:**

| Field | Type | Constraints |
|-------|------|------------|
| `wine_name` | string | Required; 1–200 characters |
| `producer` | string | Required; 1–200 characters |
| `vintage_year` | integer | Required; 1900 ≤ value ≤ (current year + 1) |
| `wine_type` | enum | Required; one of: RED, WHITE, ROSE, SPARKLING, DESSERT, FORTIFIED |
| `quantity` | integer | Required; 1 ≤ value ≤ 9999 |
| `storage_location_id` | UUID (FK) | Required; must reference an existing storage location |

**Optional Fields:**

| Field | Type | Constraints |
|-------|------|------------|
| `country` | string | Optional; 1–100 characters |
| `region` | string | Optional; 1–100 characters |
| `appellation` | string | Optional; 1–100 characters |
| `grape_variety` | string | Optional; 1–200 characters; free text (may contain multiple grapes, e.g., "Cabernet Sauvignon, Merlot") |
| `bottle_size` | enum | Optional; one of: 375ML, 750ML, 1500ML, 3000ML; default 750ML if omitted |
| `purchase_date` | date | Optional; ISO 8601 date (YYYY-MM-DD); must not be in the future |
| `purchase_source` | string | Optional; 1–200 characters (e.g., "Wine.com," "Local shop") |
| `purchase_price` | decimal | Optional; ≥ 0.00; up to 2 decimal places; currency assumed USD in v1. **UI label: "Purchase Price (per bottle)"** — displayed with helper text "Enter the price per individual bottle, not per case." to eliminate per-bottle vs. per-case ambiguity. |
| `estimated_value` | decimal | Optional; ≥ 0.00; up to 2 decimal places; user-entered estimate per bottle |
| `drink_window_start` | integer | Optional; 1900 ≤ value ≤ 2200; must be ≤ `drink_window_end` if both provided |
| `drink_window_end` | integer | Optional; 1900 ≤ value ≤ 2200; must be ≥ `drink_window_start` if both provided |
| `notes` | string | Optional; up to 5000 characters; free text |

---

### Outputs

- **Wine Detail View:** All fields rendered, grouped by section (Identity, Provenance, Storage, Drinking Window, Tasting Notes, Bottle Events)
- **Wine List Card (mobile):** `wine_name`, `producer`, `vintage_year`, `wine_type` badge, readiness status badge, `quantity`, `storage_location` display name
- **Wine List Row (desktop):** Same fields plus `country`, `region`, `purchase_price` columns
- **API Response (POST /wines):** Full wine record JSON (see `Y1-api.md §F00`)
- **API Response (GET /wines/:id):** Full wine record JSON
- **API Response (PUT /wines/:id):** Updated wine record JSON
- **API Response (DELETE /wines/:id):** `204 No Content`

---

### Validation Rules

- `wine_name`: Required; must not be blank or whitespace-only; max 200 chars.
- `producer`: Required; must not be blank or whitespace-only; max 200 chars.
- `vintage_year`: Required; must be an integer; must satisfy 1900 ≤ value ≤ (current year + 1). Non-numeric input rejected with message "Vintage must be a year (e.g., 2019)."
- `wine_type`: Required; must be one of the six valid enum values. UI enforces via select/radio; API validates and rejects unknown values with `400`.
- `quantity`: Required; must be a positive integer ≥ 1. Decimal or negative values rejected.
- `storage_location_id`: Required; the referenced location ID must exist in the `storage_locations` table. Orphan reference rejected with `422`.
- `bottle_size`: If provided, must be one of the four valid enum values. Defaults to `750ML` if omitted.
- `purchase_date`: If provided, must be a valid ISO 8601 date; must not be in the future (> today's date).
- `purchase_price`: If provided, must be a non-negative number with ≤ 2 decimal places.
- `estimated_value`: If provided, must be a non-negative number with ≤ 2 decimal places.
- `drink_window_start`: If provided, must be integer 1900–2200. If `drink_window_end` is also provided, `drink_window_start` must be ≤ `drink_window_end`.
- `drink_window_end`: If provided, must be integer 1900–2200. If `drink_window_start` is also provided, `drink_window_end` must be ≥ `drink_window_start`.
- `notes`: If provided, must not exceed 5000 characters.
- `grape_variety`, `country`, `region`, `appellation`, `purchase_source`: Optional string fields; if provided, must not exceed their respective max lengths.

---

### Error States

| Scenario | HTTP Status | Error Code | User Message |
|----------|-------------|------------|-------------|
| Missing required field | 422 | VALIDATION_ERROR | "Wine name is required." (field-specific) |
| Vintage year out of range | 422 | VALIDATION_ERROR | "Vintage must be between 1900 and [current+1]." |
| Invalid wine type value | 422 | VALIDATION_ERROR | "Wine type must be one of: Red, White, Rosé, Sparkling, Dessert, Fortified." |
| Quantity < 1 | 422 | VALIDATION_ERROR | "Quantity must be at least 1." |
| Storage location not found | 422 | INVALID_REFERENCE | "The selected storage location no longer exists. Please choose another." |
| Drinking window start > end | 422 | VALIDATION_ERROR | "Drink by start year must be before or equal to end year." |
| Purchase date in future | 422 | VALIDATION_ERROR | "Purchase date cannot be in the future." |
| Wine record not found | 404 | WINE_NOT_FOUND | "Wine record not found." |
| Delete with confirm cancelled | — | — | Modal closed; no action taken |
| Duplicate wine name + producer + vintage | — | — | No uniqueness constraint in v1; user may create identical records |

---

### API Surface (this feature)

See `Y1-api.md §F00 — Wine Inventory` for full request/response schemas.

| Method | Endpoint | Purpose |
|--------|----------|---------|
| GET | `/api/v1/wines` | List all wine records (with filter/sort query params) |
| POST | `/api/v1/wines` | Create a new wine record |
| GET | `/api/v1/wines/:wine_id` | Get single wine record by ID |
| PUT | `/api/v1/wines/:wine_id` | Update a wine record (full replace) |
| PATCH | `/api/v1/wines/:wine_id` | Partial update of a wine record |
| DELETE | `/api/v1/wines/:wine_id` | Delete a wine record (cascade) |

---

### Schema Surface (this feature)

Uses tables: `wines`, `storage_locations` (FK reference) — see `Y0-schema.md §Wines` for full DDL.

**Key columns on `wines`:** `wine_id` (PK), `wine_name`, `producer`, `vintage_year`, `wine_type`, `grape_variety`, `country`, `region`, `appellation`, `bottle_size`, `quantity`, `storage_location_id` (FK), `purchase_date`, `purchase_source`, `purchase_price`, `estimated_value`, `drink_window_start`, `drink_window_end`, `notes`, `created_at`, `updated_at`.

---
---

## F01: Quantity & Bottle Status Tracking

**PRD Reference:** F1 — Priority P0 (Critical)

**Description:** This feature manages the lifecycle of individual bottle units within a wine record — from initial purchase quantity through consumption, gifting, or opening. It maintains an accurate live count of bottles in the cellar, provides single-tap controls for quantity adjustments, and logs every bottle event with date and type. When quantity reaches zero, the wine record enters "Cellar Empty" status and is visually distinguished in the list. Bottle events optionally prompt the user to record a tasting note (see F04).

---

### Terminology

| Term | Definition |
|------|-----------|
| **Quantity** | The integer count of physical bottles of a given wine currently in the cellar. Never drops below 0. |
| **Bottle Event** | A logged action applied to one bottle unit: Consumed, Gifted, or Opened. Consumed and Gifted decrement quantity by 1. Opened sets a status flag without decrementing. |
| **Cellar Empty** | State of a wine record where quantity = 0. Record is retained; visually de-emphasized. |
| **Consume Event** | Bottle was opened and fully consumed by the user. Decrements quantity; optionally links to a tasting note. |
| **Gift Event** | Bottle was given to another person. Decrements quantity; optional recipient note. |
| **Open Event** | Bottle was opened but may not yet be fully consumed (e.g., poured one glass, bottle still open). Does NOT decrement quantity. Sets an `is_open` flag on the wine record. |
| **Event Log** | Chronological list of all bottle events on a wine record (date, event type, optional note). |

---

### Sub-Features

- **F01.1 — Display Quantity:** Show current quantity on wine list card, detail view, and dashboard
- **F01.2 — Increment / Decrement Controls:** Single-tap +/− controls on the detail view
- **F01.3 — Log Consume Event:** Decrement quantity, log event, optionally link tasting note
- **F01.4 — Log Gift Event:** Decrement quantity, log event with optional recipient note
- **F01.5 — Log Open Event:** Set open flag, log event (no quantity change)
- **F01.6 — Cellar Empty State:** Visual distinction and status label when quantity = 0
- **F01.7 — Bottle Event Log:** Display chronological history of all events on wine detail view

---

### Process

#### F01.2 — Increment / Decrement Controls

1. User is on the Wine Detail view.
2. System displays current quantity with a "−" button and a "+" button flanking the count.
3. **Increment:** User taps "+". System increments `quantity` by 1, saves, and updates displayed count. No upper limit enforced in v1 beyond the field max (9999).
4. **Decrement:** If `quantity` > 0, user taps "−". System decrements `quantity` by 1 and saves. No bottle event is logged for bare decrement (use Consume/Gift actions for logged events).
5. **Decrement at Zero:** If `quantity` = 0, the "−" button is disabled (greyed out, `aria-disabled="true"`). The quantity cannot go below 0.

#### F01.3 — Log Consume Event

1. User taps "Open / Consume Bottle" action button on Wine Detail view.
2. System presents an action sheet with three options: "Consumed," "Gifted," "Opened."
3. User selects "Consumed."
4. System presents Consume Event dialog:
   - Date consumed (date picker; defaults to today)
   - Notes (optional free text; 500 char max)
   - "Add Tasting Note?" toggle (defaults ON)
5. User confirms.
6. System decrements `quantity` by 1.
7. System saves a `bottle_event` record: `event_type = CONSUMED`, `event_date`, `notes`.
8. If `quantity` is now 0, system sets wine record status to `Cellar Empty`.
9. If "Add Tasting Note?" was ON, system navigates to the Add Tasting Note form (see F04), pre-populated with today's date, and linked to this `bottle_event_id`.
10. If "Add Tasting Note?" was OFF, system returns to Wine Detail view with success toast: "Bottle marked as consumed."

#### F01.4 — Log Gift Event

1. User selects "Gifted" from the action sheet.
2. System presents Gift Event dialog:
   - Date gifted (date picker; defaults to today)
   - Recipient (optional free text; 200 char max)
   - Notes (optional free text; 500 char max)
3. User confirms.
4. System decrements `quantity` by 1.
5. System saves a `bottle_event` record: `event_type = GIFTED`, `event_date`, `recipient`, `notes`.
6. If `quantity` is now 0, system sets wine record status to `Cellar Empty`.
7. System returns to Wine Detail view with success toast: "Bottle marked as gifted."

#### F01.5 — Log Open Event

1. User selects "Opened" from the action sheet.
2. System presents Open Event dialog:
   - Date opened (date picker; defaults to today)
   - Notes (optional free text; 500 char max)
3. User confirms.
4. System sets `is_open = true` on the wine record.
5. System saves a `bottle_event` record: `event_type = OPENED`, `event_date`, `notes`.
6. Quantity is NOT decremented.
7. System returns to Wine Detail view. An "Open" badge is displayed next to the wine name.
8. "Opened" status persists until the user logs a subsequent Consumed or Gifted event, which clears the `is_open` flag.

#### F01.7 — Bottle Event Log

1. On the Wine Detail view, below the main fields, system renders a "Bottle History" section.
2. Events are listed in reverse chronological order (most recent first).
3. Each event row shows: event date, event type icon + label, optional notes/recipient.
4. If no events exist, section displays: "No bottle events recorded yet."

---

### Inputs

| Field | Type | Required | Constraints |
|-------|------|----------|------------|
| `wine_id` | UUID | Yes | Must reference existing wine record |
| `event_type` | enum | Yes | One of: CONSUMED, GIFTED, OPENED |
| `event_date` | date | Yes | ISO 8601 date; must not be in the future; defaults to today |
| `notes` | string | No | Max 500 characters |
| `recipient` | string | No | GIFTED events only; max 200 characters |
| `tasting_note_link` | boolean | No | CONSUMED events only; if true, user is directed to add tasting note |

**Quantity Controls:**

| Action | Input | Constraint |
|--------|-------|-----------|
| Increment | Tap "+" | Max quantity: 9999 |
| Decrement | Tap "−" | Disabled when quantity = 0 |

---

### Outputs

- **Wine List Card:** Current `quantity` displayed as a pill/badge; "Cellar Empty" label shown when quantity = 0
- **Wine Detail View:** Quantity with +/− controls; "Open" badge when `is_open = true`; Bottle History section
- **Bottle Event Record:** Persisted `bottle_event` with `event_id`, `wine_id`, `event_type`, `event_date`, `notes`, `recipient`, `created_at`
- **Toast Notification:** Confirmation message after each event ("Bottle marked as consumed." / "Bottle marked as gifted.")
- **API Response (POST /wines/:id/events):** Created `bottle_event` JSON (see `Y1-api.md §F01`)

---

### Validation Rules

- `event_type`: Required; must be one of CONSUMED, GIFTED, OPENED.
- `event_date`: Required; must be a valid ISO 8601 date; must not be after today's date.
- `notes`: If provided, must not exceed 500 characters.
- `recipient`: If provided (GIFTED only), must not exceed 200 characters.
- **Quantity floor:** `quantity` cannot go below 0 via any path (decrement button disabled at 0; Consume/Gift events blocked when quantity = 0).
- **Consume/Gift at zero:** If user attempts to log CONSUMED or GIFTED when quantity = 0, system shows inline error: "No bottles remain in the cellar for this wine."
- **Open at zero:** OPENED event is allowed when quantity = 0 (represents an already-pulled bottle being noted as open).

---

### Error States

| Scenario | HTTP Status | Error Code | User Message |
|----------|-------------|------------|-------------|
| Consume/Gift when quantity = 0 | 422 | QUANTITY_EMPTY | "No bottles remain in the cellar for this wine." |
| Invalid event type | 422 | VALIDATION_ERROR | "Event type must be Consumed, Gifted, or Opened." |
| Event date in future | 422 | VALIDATION_ERROR | "Event date cannot be in the future." |
| Wine record not found | 404 | WINE_NOT_FOUND | "Wine record not found." |
| Notes exceed 500 chars | 422 | VALIDATION_ERROR | "Notes must be 500 characters or fewer." |

---

### API Surface (this feature)

See `Y1-api.md §F01 — Bottle Events` for full request/response schemas.

| Method | Endpoint | Purpose |
|--------|----------|---------|
| POST | `/api/v1/wines/:wine_id/events` | Log a bottle event (Consumed / Gifted / Opened) |
| GET | `/api/v1/wines/:wine_id/events` | Get all bottle events for a wine |
| PATCH | `/api/v1/wines/:wine_id/quantity` | Directly adjust quantity (+/−) without logging an event |

---

### Schema Surface (this feature)

Uses tables: `wines` (quantity, is_open columns), `bottle_events` — see `Y0-schema.md §BottleEvents` for full DDL.

**Key columns on `bottle_events`:** `event_id` (PK), `wine_id` (FK), `event_type` (enum), `event_date`, `notes`, `recipient`, `tasting_note_id` (FK, nullable), `created_at`.
**Key columns on `wines` (updated by this feature):** `quantity`, `is_open`.

---
---

## F02: Storage Location Management

**PRD Reference:** F2 — Priority P0 (Critical)

**Description:** Users store bottles in multiple physical spaces — wine fridges, basement cellars, kitchen racks, storage units. This feature lets users define named storage locations, assign each wine record to one location, and maintain an accurate "where is it?" answer for every bottle. Locations are user-defined and free-form, with no structural hierarchy imposed. When a location is deleted, all wines assigned to it are flagged as "Location Unknown" rather than being silently left with a broken reference, preserving data integrity and surfacing the issue to the user.

---

### Terminology

| Term | Definition |
|------|-----------|
| **Storage Location** | A user-defined named physical place where wine bottles are kept (e.g., "Wine Fridge – Top Shelf," "Basement Cellar," "Kitchen Rack"). |
| **Location Unknown** | Flag state applied to wines whose assigned storage location has been deleted. Displayed as a warning on the wine record. |
| **Location Assignment** | The foreign-key link from a wine record to a storage location (`storage_location_id` on the `wines` table). |

---

### Sub-Features

- **F02.1 — Create Location:** Define a new named storage location
- **F02.2 — Rename Location:** Change the display name of an existing location
- **F02.3 — Delete Location:** Remove a location; flag affected wine records
- **F02.4 — Assign Location to Wine:** Select a location when adding or editing a wine record
- **F02.5 — Filter by Location:** Filter the wine list to show only wines in a given location (see F03)
- **F02.6 — Location List View:** View all defined locations with bottle count per location

---

### Process

#### F02.1 — Create Location

1. User navigates to Settings → Storage Locations (or taps "Manage Locations" from the wine add/edit form).
2. User taps "Add Location."
3. System presents a text input: "Location name" (max 100 characters).
4. User enters a name and confirms.
5. System validates the name is not blank and is unique among existing locations (case-insensitive check).
6. System saves the new `storage_location` record with a generated `location_id` (UUID) and `created_at`.
7. System displays success message: "Location added." The new location is immediately available in the wine add/edit form's location dropdown.

#### F02.2 — Rename Location

1. User navigates to Settings → Storage Locations.
2. User taps "Edit" on an existing location row.
3. System presents an editable text field pre-populated with the current name.
4. User changes the name and confirms.
5. System validates: not blank, unique (case-insensitive), max 100 chars.
6. System updates the `storage_location` record's `location_name` and `updated_at`.
7. All wine records referencing this location immediately display the new name (no migration needed — name is stored on the location record, not denormalized on wines).
8. Success message: "Location renamed."

#### F02.3 — Delete Location

1. User navigates to Settings → Storage Locations.
2. User taps "Delete" on a location row.
3. System displays confirmation modal: "Delete '[Location Name]'? [N] wine(s) assigned to this location will be marked as 'Location Unknown.' This cannot be undone." with "Cancel" and "Delete" buttons.
4. If user confirms:
   a. System sets `storage_location_id = NULL` on all `wines` records that referenced this location.
   b. System sets `location_unknown = true` on those wine records.
   c. System deletes the `storage_location` record.
   d. System displays success message: "Location deleted. [N] wine(s) marked as Location Unknown."
5. If user cancels, modal closes; no changes made.

#### F02.4 — Assign Location to Wine

1. During Add Wine (F00.1) or Edit Wine (F00.4), the "Storage Location" field is a required dropdown select.
2. System populates the dropdown with all existing location names, sorted alphabetically.
3. **Pre-selection on Add Wine form:** The dropdown automatically pre-selects the most recently used storage location (the location last saved on any wine record in the current session). If no prior location exists, no default is pre-selected and the user must choose manually. This supports fast repeat-entry workflows (e.g., logging multiple bottles from the same purchase).
4. On the Edit Wine form, the dropdown pre-selects the wine's current assigned location.
5. A "Add new location..." option at the bottom of the dropdown opens the Create Location inline flow (F02.1) and returns the user to the wine form with the new location pre-selected.
6. User must select a location before the form can be saved.

#### F02.6 — Location List View

1. User navigates to Settings → Storage Locations.
2. System displays all locations as a list, each row showing: Location Name, Bottle Count (sum of `quantity` across all wines at this location with quantity > 0).
3. Rows with bottle count = 0 are still shown (empty location).
4. Row actions: "Edit" (rename), "Delete."
5. "Location Unknown" is shown as a synthetic entry at the top if any wines have `location_unknown = true`, with the count of affected wines and a "Reassign" link that filters the wine list to Location Unknown wines.

---

### Inputs

| Field | Type | Required | Constraints |
|-------|------|----------|------------|
| `location_name` | string | Yes | 1–100 characters; must be unique (case-insensitive) among existing locations |
| `location_id` | UUID | Yes (for update/delete) | Must reference existing location |

**Wine Assignment Input:**

| Field | Type | Required | Constraints |
|-------|------|----------|------------|
| `storage_location_id` | UUID (FK) | Yes (on wine form) | Must reference existing location |

---

### Outputs

- **Location List:** All user-defined locations with bottle counts
- **Location Dropdown (wine form):** Alphabetically sorted list of location names
- **Wine List Card / Detail:** `storage_location` display name shown prominently
- **"Location Unknown" Warning:** Displayed on wine card and detail view when `location_unknown = true`
- **API Response (POST /locations):** Created location JSON
- **API Response (GET /locations):** Array of all locations with bottle counts

---

### Validation Rules

- `location_name`: Required; must not be blank or whitespace-only; max 100 characters.
- `location_name` uniqueness: New names and renamed names must be unique among all existing location names, case-insensitive comparison (e.g., "wine fridge" and "Wine Fridge" are treated as the same).
- **No maximum limit on location count** in v1.
- Storage location assigned to wine (`storage_location_id`): Must reference an existing, non-deleted location. Validated at wine save time (see F00 validation).
- Delete confirmation: Always required; system must show wine count affected before user can confirm.

---

### Error States

| Scenario | HTTP Status | Error Code | User Message |
|----------|-------------|------------|-------------|
| Blank location name | 422 | VALIDATION_ERROR | "Location name is required." |
| Duplicate location name | 422 | DUPLICATE_LOCATION | "A location with that name already exists." |
| Location name too long | 422 | VALIDATION_ERROR | "Location name must be 100 characters or fewer." |
| Location not found | 404 | LOCATION_NOT_FOUND | "Storage location not found." |
| Delete without confirmation | — | — | Action blocked; confirmation modal required |
| Wine references deleted location | — | — | Wine `location_unknown` flag set; warning displayed on wine record |

---

### API Surface (this feature)

See `Y1-api.md §F02 — Storage Locations` for full request/response schemas.

| Method | Endpoint | Purpose |
|--------|----------|---------|
| GET | `/api/v1/locations` | List all storage locations with bottle counts |
| POST | `/api/v1/locations` | Create a new storage location |
| PUT | `/api/v1/locations/:location_id` | Rename a storage location |
| DELETE | `/api/v1/locations/:location_id` | Delete a location; flag affected wines |

---

### Schema Surface (this feature)

Uses tables: `storage_locations`, `wines` (FK `storage_location_id`, flag `location_unknown`) — see `Y0-schema.md §StorageLocations` for full DDL.

**Key columns on `storage_locations`:** `location_id` (PK), `location_name`, `created_at`, `updated_at`.
**Key columns on `wines` (updated by this feature):** `storage_location_id` (FK, nullable after delete), `location_unknown` (boolean).

---
---

## F03: Search & Filter

**PRD Reference:** F3 — Priority P0 (Critical)

**Description:** As a wine collection grows, browsing a flat list becomes impractical. This feature provides two complementary discovery mechanisms: a full-text search bar that matches across multiple wine attributes as the user types (client-side, no server round-trip), and a multi-attribute filter panel that lets users narrow the collection by wine type, producer, region, vintage, grape, storage location, drinking readiness status, and personal rating range. Sort options allow users to re-order results by any key dimension. Active filters are displayed as dismissible chips and persist for the session.

---

### Terminology

| Term | Definition |
|------|-----------|
| **Search Query** | A free-text string entered in the search bar, matched against `wine_name`, `producer`, `region`, and `grape_variety` fields. |
| **Filter** | A specific attribute criterion applied to narrow the wine list (e.g., wine type = RED, vintage = 2018). |
| **Filter Panel** | A collapsible sidebar (desktop) or bottom drawer (mobile) containing all filter controls. |
| **Filter Chip** | A small dismissible UI element displayed above the wine list representing one active filter. |
| **Sort Order** | The ordering applied to the wine list after search and filter have been applied. |
| **Readiness Status** | Calculated status (Drink Now, Hold, Approaching Peak, Past Window, No Window Set) derived by F05; used as a filter dimension here. |
| **Session Persistence** | Filter and sort state retained in memory for the duration of the browser session; reset on app close or hard refresh. |

---

### Sub-Features

- **F03.1 — Full-Text Search Bar:** Real-time text matching across wine name, producer, region, grape
- **F03.2 — Wine Type Filter:** Single or multi-select by wine type
- **F03.3 — Producer Filter:** Filter to wines from a specific producer
- **F03.4 — Country & Region Filter:** Filter by country and/or region
- **F03.5 — Vintage Filter:** Filter by exact year or year range
- **F03.6 — Grape Variety Filter:** Filter by grape variety (partial match)
- **F03.7 — Storage Location Filter:** Filter to wines in a specific storage location
- **F03.8 — Readiness Status Filter:** Filter by drinking readiness status (from F05)
- **F03.9 — Rating Range Filter:** Filter by personal rating minimum/maximum
- **F03.10 — Active Filter Chips:** Display and dismiss individual active filters
- **F03.11 — Clear All Filters:** Reset all active filters and search query at once
- **F03.12 — Sort Controls:** Sort the wine list by multiple dimensions

---

### Process

#### F03.1 — Full-Text Search

1. Search bar is permanently visible at the top of the Wine List view.
2. User types into the search bar.
3. System applies the search client-side with no server request, filtering in real time (debounce: 100ms after last keystroke).
4. Matching fields: `wine_name`, `producer`, `region`, `grape_variety`, and `occasion` (from the most recent tasting note for each wine). Match is case-insensitive, substring match (e.g., "cab" matches "Cabernet Sauvignon"; "anniversary" matches wines whose most recent tasting note occasion field contains "anniversary").
5. Wine list updates immediately to show only matching records.
6. If no wines match, system displays: "No wines match your search. Try a different term or clear filters."
7. Search query is treated as an additive filter alongside any active panel filters (AND logic: results must satisfy both search AND all active filters).
8. A "×" clear button appears in the search bar when text is present; tapping it clears the query.

#### F03.2–F03.9 — Filter Panel Filters

1. User taps the "Filter" button (funnel icon) to open the filter panel.
   - Mobile: panel slides up as a bottom sheet drawer.
   - Desktop: panel appears as a sidebar alongside the wine list.
2. Filter panel sections:

   **Wine Type (F03.2):** Multi-select checkboxes: Red, White, Rosé, Sparkling, Dessert, Fortified. Selecting multiple types returns wines matching ANY selected type (OR logic within this filter).

   **Producer (F03.3):** Text input with autocomplete dropdown listing all unique producers in the collection. Selecting a producer filters to that producer exactly (exact match, case-insensitive).

   **Country / Region (F03.4):** Two cascading selects: Country (dropdown of all unique countries in collection), Region (dropdown populated based on selected country; if no country selected, shows all unique regions). Either or both may be selected.

   **Vintage (F03.5):** Two numeric inputs: "From year" and "To year." If only "From" is provided, shows wines with vintage ≥ From. If only "To" is provided, shows wines with vintage ≤ To. If both provided, shows wines with vintage in range [From, To] inclusive.

   **Grape Variety (F03.6):** Text input; substring match against `grape_variety` field (case-insensitive). E.g., entering "Cab" matches "Cabernet Sauvignon," "Cabernet Franc."

   **Storage Location (F03.7):** Dropdown of all defined locations plus "Location Unknown" option. Single-select.

   **Drinking Readiness (F03.8):** Multi-select checkboxes: Drink Now, Approaching Peak, Hold, Past Window, No Window Set. OR logic within this filter. **All readiness status filter options (Drink Now, Approaching Peak, Hold, Past Window) return only wines with quantity > 0** — the user is looking for bottles they can actually open. The "No Window Set" filter also excludes quantity = 0 wines. This rule is consistent across all readiness filter options.

   **Rating Range (F03.9):** Two inputs: "Min rating" and "Max rating." On 5-star scale: 1–5 (integers). On 100-point scale: 1–100. Only active if at least one tasting note with a rating exists in the collection. Filters wines by their most recent tasting note rating.

3. Each filter is applied as the user interacts (live results update if data is client-side). No "Apply" button required.
4. All active filters are combined with AND logic (wine must satisfy ALL active filters and search query simultaneously).

#### F03.10 — Active Filter Chips

1. Above the wine list, system displays one chip per active filter.
2. Chip format: "[Filter Type]: [Value]" (e.g., "Type: Red, White", "Vintage: 2015–2020", "Location: Wine Fridge").
3. Each chip has an "×" dismiss button. Tapping dismisses that individual filter.
4. The search query is NOT shown as a chip (it has its own clear button in the search bar).

#### F03.11 — Clear All Filters

1. A "Clear all" link/button appears next to the filter chips when any filter is active.
2. Tapping clears all active panel filters. Does not clear the search bar query.
3. The filter panel, if open, resets all controls to their default (unselected) state.

#### F03.12 — Sort Controls

1. A sort control is displayed at the top-right of the wine list.
2. Sort options:
   - **Date Added: Newest first** (default)
   - **Date Added: Oldest first**
   - **Wine Name: A → Z**
   - **Wine Name: Z → A**
   - **Vintage: Newest first** (highest year first)
   - **Vintage: Oldest first** (lowest year first)
   - **Quantity: High → Low**
   - **Quantity: Low → High**
   - **Rating: Highest first** (sorts by most recent tasting note rating; unrated wines sorted last)
   - **Rating: Lowest first** (unrated wines sorted last)
   - **Drinking Window End: Soonest first** (lowest `drink_window_end` year first — most urgently expiring bottles surface first; wines with no end year sorted last)
   - **Drinking Window End: Latest first** (highest `drink_window_end` year first; wines with no end year sorted last)
3. **Default sort when Drink Now filter is active:** When the Drinking Readiness filter is set to "Drink Now" (and no other sort has been explicitly selected by the user), the sort automatically defaults to "Drinking Window End: Soonest first." This ensures the most urgently expiring bottles always surface at the top of the Drink Now list. Explicitly selecting a different sort overrides this default.
4. Sort applies to the filtered result set (sort happens after filter/search).
5. Selected sort option persists for the session.

---

### Inputs

| Input | Type | Constraints |
|-------|------|------------|
| `search_query` | string | Optional; 0–200 characters; applied client-side; matched against `wine_name`, `producer`, `region`, `grape_variety`, and `occasion` (most recent tasting note) |
| `filter.wine_type` | enum[] | Optional; subset of [RED, WHITE, ROSE, SPARKLING, DESSERT, FORTIFIED] |
| `filter.producer` | string | Optional; exact match (case-insensitive) |
| `filter.country` | string | Optional; exact match (case-insensitive) |
| `filter.region` | string | Optional; exact match (case-insensitive) |
| `filter.vintage_from` | integer | Optional; 1900–2200; must be ≤ vintage_to if both provided |
| `filter.vintage_to` | integer | Optional; 1900–2200; must be ≥ vintage_from if both provided |
| `filter.grape_variety` | string | Optional; substring match |
| `filter.storage_location_id` | UUID or "UNKNOWN" | Optional |
| `filter.readiness_status` | enum[] | Optional; subset of [DRINK_NOW, APPROACHING_PEAK, HOLD, PAST_WINDOW, NO_WINDOW_SET] |
| `filter.rating_min` | number | Optional; 1–5 (star) or 1–100 (points) |
| `filter.rating_max` | number | Optional; ≥ rating_min |
| `sort` | enum | Optional; one of the defined sort keys; defaults to DATE_ADDED_DESC |

---

### Outputs

- **Filtered Wine List:** Subset of wine records matching all active criteria, in the selected sort order
- **Active Filter Chips:** One chip per active filter dimension (not per value within a multi-select)
- **Result Count:** "Showing [N] of [Total] wines" label above the list
- **Empty State:** "No wines match your search. Try a different term or clear filters." when result set is empty
- **URL Query Params (optional, progressive enhancement):** Filter state may be reflected in URL query params to allow sharing/bookmarking filtered views (not required in v1, but supported if feasible)

---

### Validation Rules

- `search_query`: Max 200 characters. Client-side only; no server-side validation required.
- `filter.vintage_from` and `filter.vintage_to`: If both provided, `vintage_from` must be ≤ `vintage_to`. If violated, show inline error: "Start year must be before or equal to end year."
- `filter.rating_min` and `filter.rating_max`: If both provided, `rating_min` must be ≤ `rating_max`. If violated, show inline error: "Min rating must be less than or equal to max rating."
- Rating filter values must be within the user's selected scale range (1–5 or 1–100). Out-of-range values clamped to min/max of scale.
- All filtering is performed client-side for collections ≤ 500 records (per NFR performance target). Server-side filtering may be used for larger collections in a future phase.

---

### Error States

| Scenario | Display | User Message |
|----------|---------|-------------|
| No wines match combined filters | Empty state in wine list | "No wines match your search. Try a different term or clear filters." |
| Vintage range invalid (from > to) | Inline on filter panel | "Start year must be before or equal to end year." |
| Rating range invalid (min > max) | Inline on filter panel | "Min rating must be less than or equal to max rating." |
| Collection is empty (no wines at all) | Empty state with CTA | "Your cellar is empty. Tap '+' to add your first wine." with prominent Add Wine CTA button (see F00.2 §5) |

---

### API Surface (this feature)

Search and filter are primarily client-side in v1. The wine list API supports query parameters for server-side filtering as a fallback for large collections.

See `Y1-api.md §F03 — Search & Filter` for query parameter spec on `GET /api/v1/wines`.

| Parameter | Type | Purpose |
|-----------|------|---------|
| `q` | string | Full-text search query; matched against name, producer, region, grape, and occasion (most recent tasting note) |
| `wine_type` | string | Comma-separated enum values |
| `producer` | string | Exact match filter |
| `country` | string | Exact match filter |
| `region` | string | Exact match filter |
| `vintage_from` | integer | Vintage range start |
| `vintage_to` | integer | Vintage range end |
| `grape_variety` | string | Substring match filter |
| `location_id` | UUID or "unknown" | Location filter |
| `readiness` | string | Comma-separated readiness status values |
| `rating_min` | number | Minimum rating filter |
| `rating_max` | number | Maximum rating filter |
| `sort` | string | Sort key (see sort options above) |

---

### Schema Surface (this feature)

Search and filter operate against the `wines` table (with JOINs to `storage_locations` and `tasting_notes` for rating filter and occasion search). Full-text search on `occasion` requires a JOIN to the most recent `tasting_note` per wine (by `date_tasted` descending). No additional schema tables introduced by this feature. Readiness status is calculated at query time from `drink_window_start`, `drink_window_end`, and `CURRENT_DATE` — see `Y0-schema.md §Wines` and `F05 §Process`.

---
---

## F04: Tasting Notes & Personal Ratings

**PRD Reference:** F4 — Priority P1 (High)

**Description:** After opening or tasting a wine, users can record a personal tasting note capturing their sensory experience, a numeric personal rating, and context about the occasion. Over time this builds a preference history that makes the collection more intelligent — the rating attached to each wine surfaces in search, filter, sort, and the dashboard's "Highest Rated" card. Multiple tasting notes per wine are supported, with the most recent rating displayed on the wine list card and detail view. Tasting notes can be added standalone (e.g., tasting at a restaurant before purchasing) or linked to a bottle consume event (F01).

---

### Terminology

| Term | Definition |
|------|-----------|
| **Tasting Note** | A dated personal record of experiencing a wine, with optional sensory descriptors, a personal rating, and context fields. |
| **Personal Rating** | A numeric quality score assigned to a wine during a tasting note. Default scale: 1–5 stars (integers). Alternate: 1–100 points (decimal allowed). User selects their preferred scale in app settings. |
| **Rating Scale** | The scoring system the user chooses: "5-star" (integers 1–5) or "100-point" (integers 1–100). Applied globally to all tasting notes; cannot be changed per note. |
| **Would-Buy-Again** | A three-state preference toggle on the tasting note: YES / NO / MAYBE. |
| **Linked Event** | A tasting note linked to a specific bottle consume event (`bottle_event_id`). Created automatically when user selects "Add Tasting Note" after logging a Consumed bottle event. |
| **Standalone Note** | A tasting note added directly to a wine record without linking to a bottle event. |
| **Most Recent Rating** | The `personal_rating` from the most recent tasting note (by `date_tasted`) for a wine. Displayed on wine list card and wine detail view. |

---

### Sub-Features

- **F04.1 — Add Tasting Note:** Create a new tasting note for any wine record
- **F04.2 — Linked Tasting Note (post-consume):** Auto-prompted tasting note after logging a Consumed bottle event
- **F04.3 — View Tasting Note History:** See all notes for a wine, chronologically, on the detail view
- **F04.4 — Edit Tasting Note:** Modify an existing tasting note
- **F04.5 — Delete Tasting Note:** Remove a tasting note with confirmation
- **F04.6 — Rating Scale Preference:** User selects 5-star or 100-point scale in settings
- **F04.7 — Rating Display on Wine List:** Most recent rating shown on wine list card

---

### Process

#### F04.1 — Add Tasting Note (Standalone)

1. User taps "Add Tasting Note" button on the Wine Detail view.
2. System presents the Add Tasting Note form with the following fields.
3. User fills in desired fields (only `date_tasted` is required).
4. User submits.
5. System validates (see Validation).
6. If validation fails, inline errors are shown; note is not saved.
7. If validation passes, system saves the tasting note record linked to the `wine_id`.
8. System updates the wine's `latest_rating` (denormalized) if a `personal_rating` was entered.
9. System returns to the Wine Detail view, with the new note appearing at the top of the Tasting Notes section.
10. Success toast: "Tasting note saved."

#### F04.2 — Linked Tasting Note (Post-Consume)

1. After logging a CONSUMED bottle event (F01.3), if user had "Add Tasting Note?" toggled ON:
2. System navigates to the Add Tasting Note form.
3. Form is pre-populated with: `date_tasted = today`, `linked_event_id = [bottle_event_id]`.
4. User completes the form and submits (same process as F04.1 steps 4–10).
5. The saved tasting note is linked to the bottle event via `bottle_event_id`.
6. On the Bottle Event Log (F01.7), the CONSUMED event row shows a link: "View tasting note."

#### F04.3 — View Tasting Note History

1. On the Wine Detail view, the "Tasting Notes" section lists all notes for this wine.
2. Notes are sorted by `date_tasted` descending (most recent first).
3. Each note entry displays: date tasted, personal rating (rendered as stars or number per user's scale preference), would-buy-again toggle state, occasion, and a truncated preview of the flavor/palate text (expanding to full on tap).
4. Full note details (appearance, aroma, flavor, finish, guest feedback) are visible on tap/expand.
5. Each note entry has "Edit" and "Delete" action buttons.
6. If no tasting notes exist: "No tasting notes yet. Add one after your next bottle."

#### F04.4 — Edit Tasting Note

1. User taps "Edit" on a tasting note entry.
2. System presents the form pre-populated with all current note values.
3. User modifies fields and submits.
4. System validates and saves; updates `updated_at`.
5. System recalculates the wine's `latest_rating` based on the updated note set (most recent by date).
6. Success toast: "Tasting note updated."

#### F04.5 — Delete Tasting Note

1. User taps "Delete" on a tasting note entry.
2. System displays confirmation: "Delete this tasting note? This cannot be undone." with "Cancel" and "Delete."
3. If confirmed:
   a. System deletes the tasting note record.
   b. System recalculates `latest_rating` on the wine (set to next most recent note's rating, or NULL if no notes remain).
   c. Success toast: "Tasting note deleted."
4. If cancelled: modal closes; no changes.

#### F04.6 — Rating Scale Preference

1. User navigates to Settings → Rating Scale.
2. User selects "5-star (1–5)" or "100-point (1–100)."
3. System saves the preference globally.
4. All rating inputs and displays throughout the app render in the selected scale.
5. **Scale conversion:** Existing ratings stored as entered; no automatic conversion when scale is changed. If user switches from 5-star to 100-point, existing 5-star ratings (e.g., "4") are displayed as-is with a label indicating the scale when the entry was made. (Conversion display is a future enhancement.)

---

### Inputs

| Field | Type | Required | Constraints |
|-------|------|----------|------------|
| `wine_id` | UUID | Yes | Must reference existing wine record |
| `date_tasted` | date | Yes | ISO 8601 date; must not be in the future |
| `appearance` | string | No | Max 500 characters; free text |
| `aroma` | string | No | Max 500 characters; free text |
| `flavor` | string | No | Max 1000 characters; free text |
| `finish` | string | No | Max 500 characters; free text |
| `personal_rating` | number | No | If 5-star scale: integer 1–5; if 100-point scale: integer 1–100 |
| `would_buy_again` | enum | No | One of: YES, NO, MAYBE |
| `occasion` | string | No | Max 200 characters; free text (e.g., "Anniversary dinner") |
| `guest_feedback` | string | No | Max 500 characters; free text |
| `bottle_event_id` | UUID | No | FK to `bottle_events`; set automatically for linked notes |

---

### Outputs

- **Tasting Note Record:** Persisted with `note_id`, `wine_id`, `date_tasted`, all sensory fields, `personal_rating`, `would_buy_again`, `occasion`, `guest_feedback`, `bottle_event_id`, `rating_scale`, `created_at`, `updated_at`
- **Wine Detail — Tasting Notes Section:** Chronological list of all notes with full details on expand
- **Wine List Card:** Most recent rating displayed as star icons (5-star) or numeric badge (100-point); only shown if at least one rated note exists
- **Wine Detail — Rating Summary:** Most recent rating + date displayed near the top of the detail view
- **Bottle Event Log:** Linked consume event shows "View tasting note" link
- **API Response (POST /wines/:id/tasting-notes):** Full tasting note JSON (see `Y1-api.md §F04`)

---

### Validation Rules

- `date_tasted`: Required; must be a valid ISO 8601 date; must not be after today's date.
- `personal_rating` (5-star): If provided, must be an integer 1–5. Decimal values rejected.
- `personal_rating` (100-point): If provided, must be an integer 1–100. Values outside range rejected.
- `would_buy_again`: If provided, must be one of YES, NO, MAYBE.
- `appearance`, `aroma`, `finish`, `guest_feedback`: If provided, max 500 characters each.
- `flavor`: If provided, max 1000 characters.
- `occasion`: If provided, max 200 characters.
- `bottle_event_id`: If provided, must reference an existing `bottle_event` of type CONSUMED; cannot link to a GIFTED or OPENED event.
- All text fields: HTML/script tags stripped server-side (stored as plain text).
- Multiple notes per wine: Allowed without restriction. No uniqueness constraint on date (user may add multiple notes on the same date).

---

### Error States

| Scenario | HTTP Status | Error Code | User Message |
|----------|-------------|------------|-------------|
| Missing date_tasted | 422 | VALIDATION_ERROR | "Tasting date is required." |
| Date in future | 422 | VALIDATION_ERROR | "Tasting date cannot be in the future." |
| Rating out of range (5-star) | 422 | VALIDATION_ERROR | "Rating must be between 1 and 5." |
| Rating out of range (100-pt) | 422 | VALIDATION_ERROR | "Rating must be between 1 and 100." |
| Invalid would_buy_again value | 422 | VALIDATION_ERROR | "Would-buy-again must be Yes, No, or Maybe." |
| Wine not found | 404 | WINE_NOT_FOUND | "Wine record not found." |
| Tasting note not found | 404 | NOTE_NOT_FOUND | "Tasting note not found." |
| Bottle event not found / wrong type | 422 | INVALID_REFERENCE | "Linked bottle event not found or is not a Consumed event." |
| Text field exceeds max length | 422 | VALIDATION_ERROR | "[Field] must be [N] characters or fewer." |

---

### API Surface (this feature)

See `Y1-api.md §F04 — Tasting Notes` for full request/response schemas.

| Method | Endpoint | Purpose |
|--------|----------|---------|
| GET | `/api/v1/wines/:wine_id/tasting-notes` | List all tasting notes for a wine |
| POST | `/api/v1/wines/:wine_id/tasting-notes` | Add a new tasting note |
| GET | `/api/v1/wines/:wine_id/tasting-notes/:note_id` | Get single tasting note |
| PUT | `/api/v1/wines/:wine_id/tasting-notes/:note_id` | Update a tasting note |
| DELETE | `/api/v1/wines/:wine_id/tasting-notes/:note_id` | Delete a tasting note |
| GET | `/api/v1/settings/rating-scale` | Get user's rating scale preference |
| PUT | `/api/v1/settings/rating-scale` | Set rating scale preference |

---

### Schema Surface (this feature)

Uses tables: `tasting_notes`, `wines` (denormalized `latest_rating`, `latest_rating_scale`, `latest_rating_date` for list display performance) — see `Y0-schema.md §TastingNotes` for full DDL.

**Key columns on `tasting_notes`:** `note_id` (PK), `wine_id` (FK), `date_tasted`, `appearance`, `aroma`, `flavor`, `finish`, `personal_rating`, `rating_scale` (enum: STARS_5 or POINTS_100), `would_buy_again` (enum: YES, NO, MAYBE), `occasion`, `guest_feedback`, `bottle_event_id` (FK, nullable), `created_at`, `updated_at`.

**Key columns on `wines` (denormalized, updated by this feature):** `latest_rating`, `latest_rating_scale`, `latest_rating_date`.

**Key table:** `user_settings` — `rating_scale` column stores the user's active scale preference.

---
---

## F05: Drinking Window Management

**PRD Reference:** F5 — Priority P1 (High)

**Description:** The drinking window is the date range during which a wine is expected to be at or near its peak quality. This feature automatically calculates a readiness status for every wine in the collection by comparing the wine's stored start and end year against the current year — giving users an immediate, color-coded "What should I drink now?" answer without any manual refresh. Readiness status drives the dashboard's Drink Now shelf (F06), filter options (F03), and a prominent badge on every wine card and detail view. Wines with no drinking window entered display a neutral "No Window Set" label.

---

### Terminology

| Term | Definition |
|------|-----------|
| **Drinking Window** | The inclusive date range [start_year, end_year] during which a wine is considered to be at or near its peak. Entered by the user on the wine form; not sourced from any external database in v1. |
| **Readiness Status** | Calculated label assigned to each wine based on the current year and its drinking window. Five possible values: Drink Now, Approaching Peak, Hold, Past Window, No Window Set. |
| **Drink Now** | Readiness status indicating the current year falls within the drinking window (start_year ≤ current_year ≤ end_year). |
| **Approaching Peak** | Readiness status indicating the current year is 1–2 years before the window start (start_year − 2 ≤ current_year < start_year). |
| **Hold** | Readiness status indicating the current year is more than 2 years before the window start (current_year < start_year − 2). |
| **Past Window** | Readiness status indicating the current year exceeds the window end (current_year > end_year). |
| **No Window Set** | Readiness status for wines where neither drink_window_start nor drink_window_end has been entered. |
| **Readiness Badge** | A color-coded UI element displaying the readiness status label, shown on wine list cards and detail views. |

---

### Sub-Features

- **F05.1 — Drinking Window Entry:** Capture start and end year on the wine add/edit form (part of F00)
- **F05.2 — Readiness Status Calculation:** Compute status on each app load/render
- **F05.3 — Readiness Badge Display:** Show color-coded badge on wine list cards and detail view
- **F05.4 — Drink Now Shelf Integration:** Surface Drink Now wines on the dashboard (F06)
- **F05.5 — Filter Integration:** Enable readiness status as a filter dimension (F03)

---

### Process

#### F05.2 — Readiness Status Calculation

The readiness status is a pure calculation from stored data and the current date. It is computed on every render — no separate calculation job, no stored status field (status is derived, not persisted).

**Algorithm (evaluated in order):**

```
current_year = current calendar year (UTC)

IF drink_window_start IS NULL AND drink_window_end IS NULL:
  → status = NO_WINDOW_SET

ELSE IF drink_window_start IS NOT NULL AND current_year >= drink_window_start AND (drink_window_end IS NULL OR current_year <= drink_window_end):
  → status = DRINK_NOW

ELSE IF drink_window_start IS NOT NULL AND current_year >= (drink_window_start - 2) AND current_year < drink_window_start:
  → status = APPROACHING_PEAK

ELSE IF drink_window_start IS NOT NULL AND current_year < (drink_window_start - 2):
  → status = HOLD

ELSE IF drink_window_end IS NOT NULL AND current_year > drink_window_end:
  → status = PAST_WINDOW

ELSE:
  → status = NO_WINDOW_SET
```

**Edge Cases:**

| Scenario | Behavior |
|----------|---------|
| Only `drink_window_start` set (no end) | DRINK_NOW if current ≥ start; APPROACHING_PEAK / HOLD if before start; no PAST_WINDOW can be reached (no end defined) |
| Only `drink_window_end` set (no start) | DRINK_NOW if current ≤ end; PAST_WINDOW if current > end; cannot be HOLD or APPROACHING_PEAK (no start defined) |
| Both set, start = end (single-year window) | DRINK_NOW when current_year = that year; HOLD/APPROACHING_PEAK before; PAST_WINDOW after |
| Cellar Empty wine (quantity = 0) | Readiness status still calculated and displayed; badge is shown in muted style alongside Cellar Empty label |

**Calculation timing:**
- Status is recalculated client-side on each app load (page refresh or navigation to the wine list / detail view).
- No server-side calculation job or cron required in v1.
- If serving pre-rendered pages, status must be recalculated at request time using `CURRENT_DATE`, not cached from a prior render.

#### F05.3 — Readiness Badge Display

**Badge specifications:**

| Status | Badge Label | Background | Text Color | Icon |
|--------|------------|-----------|-----------|------|
| DRINK_NOW | "Drink Now" | Gold 400 `#FBCA5C` | Black `#0A0A0A` | Glass icon |
| APPROACHING_PEAK | "Approaching Peak" | Amber `#F5A623` | Black `#0A0A0A` | Clock icon |
| HOLD | "Hold" | Gray 300 `#D4D1C9` | Ink `#1A1A1A` | Hourglass icon |
| PAST_WINDOW | "Past Window" | Gray 200 `#E8E6E1` | Gray 400 `#A8A59B` | Warning icon |
| NO_WINDOW_SET | "No Window Set" | Transparent | Gray 400 `#A8A59B` | — |

**Badge rendering rules:**
- Font: JetBrains Mono 400–500, UPPERCASE, +1px tracking (label eyebrow style).
- Badge displayed on: wine list card (below producer name), wine detail view header area, dashboard Drink Now shelf cards.
- Badge must include both the color and the text label — color alone must never be the sole differentiator (WCAG 2.1 AA compliance).
- Badge touch target: minimum 44×44px if interactive; badges are non-interactive (display only).
- "Past Window" and "No Window Set" badges are muted to not compete visually with actionable statuses.

---

### Inputs

| Field | Type | Source | Constraints |
|-------|------|--------|------------|
| `drink_window_start` | integer | User (wine add/edit form) | Optional; 1900–2200; ≤ drink_window_end if both set |
| `drink_window_end` | integer | User (wine add/edit form) | Optional; 1900–2200; ≥ drink_window_start if both set |
| `current_year` | integer | System (derived from current date at render time) | Not a user input; UTC calendar year |

**Note:** There is no separate "set drinking window" form — drinking window fields live on the standard wine add/edit form (F00). This feature specifies the calculation and display behavior only.

---

### Outputs

- **`readiness_status`** (calculated, not stored): One of DRINK_NOW, APPROACHING_PEAK, HOLD, PAST_WINDOW, NO_WINDOW_SET
- **Readiness Badge:** Color-coded pill on wine list card and wine detail view header
- **Dashboard Drink Now Shelf:** Subset of wines with DRINK_NOW status, sorted by `drink_window_end` ascending (see F06)
- **Filter Dimension:** `readiness_status` available as a filter option in F03
- **API Response:** `readiness_status` field included in all wine record responses (calculated server-side at response time)

---

### Validation Rules

- `drink_window_start`: If provided, must be integer 1900–2200.
- `drink_window_end`: If provided, must be integer 1900–2200.
- Cross-field: If both `drink_window_start` and `drink_window_end` are provided, `drink_window_start` ≤ `drink_window_end`. Violation returns `422 VALIDATION_ERROR`.
- Neither field is required. Both may be null simultaneously (→ NO_WINDOW_SET).
- `current_year` used in calculation is always derived from server/client clock at render time — never a cached value.

---

### Error States

| Scenario | HTTP Status | Error Code | User Message |
|----------|-------------|------------|-------------|
| Drinking window start > end | 422 | VALIDATION_ERROR | "Drink by start year must be before or equal to end year." |
| Drinking window start out of range | 422 | VALIDATION_ERROR | "Drinking window year must be between 1900 and 2200." |
| Drinking window end out of range | 422 | VALIDATION_ERROR | "Drinking window year must be between 1900 and 2200." |

> No additional error states specific to status calculation — the algorithm is deterministic and always produces one of the five valid statuses.

---

### API Surface (this feature)

Drinking window fields are part of the wine record (`Y1-api.md §F00`). The API includes `readiness_status` as a calculated field in all wine response objects. No dedicated drinking window endpoints.

**Calculated field in wine response:**

```json
{
  "drink_window_start": 2025,
  "drink_window_end": 2032,
  "readiness_status": "DRINK_NOW"
}
```

The `readiness_status` value is computed by the server at response time using `CURRENT_DATE`. Clients must not cache or persist this value.

---

### Schema Surface (this feature)

Drinking window is stored on the `wines` table. Readiness status is NOT stored — it is calculated at query/render time.

**Relevant columns on `wines`:** `drink_window_start` (integer, nullable), `drink_window_end` (integer, nullable).
**No additional tables** introduced by this feature.

See `Y0-schema.md §Wines` for full DDL.

---
---

## F06: Collection Dashboard & Insights

**PRD Reference:** F6 — Priority P1 (High)

**Description:** The dashboard is the home screen of the application. It gives the user an immediate picture of their collection — total bottles, wines ready to drink, and simple breakdowns by type, region, and vintage decade — without requiring any navigation. The "Drink Now" shelf surfaces the most actionable bottles prominently, answering the core question "What should I open tonight?" The dashboard is data-driven: all cards and stats pull from the live wine collection and update on every app load. All dashboard cards link to the full filtered wine list for the corresponding segment, enabling the user to drill down from summary to detail in one tap.

---

### Terminology

| Term | Definition |
|------|-----------|
| **Summary Stats Bar** | The persistent row of aggregate metrics at the top of the dashboard (total bottles, total wine records, Drink Now count, Approaching Peak count). |
| **Drink Now Shelf** | A horizontally scrollable row (or vertical compact list on mobile) of wine cards with DRINK_NOW readiness status, sorted by urgency (soonest end year first). |
| **Collection Breakdown** | Visual segmentation of the collection by wine type, by country/region, and by vintage decade, shown as simple count + percentage lists or bar indicators. |
| **Recently Added** | The 5 wine records most recently created, sorted by `created_at` descending. |
| **Recently Consumed** | The 5 most recent CONSUMED bottle events, sorted by `event_date` descending. |
| **Highest Rated** | The top 5 wine records by `latest_rating` (descending), only wines with at least one tasting note with a rating. |
| **Dashboard Card** | An individual panel on the dashboard containing one data segment (e.g., the Drink Now shelf, Recently Added list). Each card links to a filtered wine list view. |

---

### Sub-Features

- **F06.1 — Summary Stats Bar:** Four key metrics always visible at the top of the dashboard
- **F06.2 — Drink Now Shelf:** Scrollable row of wines ready to drink now
- **F06.3 — Collection Breakdown by Type:** Wine type distribution (count + %)
- **F06.4 — Collection Breakdown by Region:** Top 5 countries/regions by bottle count
- **F06.5 — Collection Breakdown by Decade:** Bottle count grouped by vintage decade
- **F06.6 — Recently Added:** Last 5 wines added to the collection
- **F06.7 — Recently Consumed:** Last 5 consumed bottle events
- **F06.8 — Highest Rated:** Top 5 wines by personal rating
- **F06.9 — Dashboard Navigation:** All cards link to filtered wine list for that segment

---

### Process

#### Dashboard Load

1. Dashboard is the default landing view on app open.
2. On load, system fetches all wine data needed for dashboard (single optimized query or set of queries — see `Y1-api.md §F06`).
3. System calculates all derived values (readiness statuses, breakdowns, counts) using live data and `CURRENT_DATE`.
4. System renders all dashboard sections in the layout order below.
5. If the collection is empty (no wine records), system displays an onboarding empty state: "Your cellar is empty. Tap '+' to add your first wine." with a prominent "Add Wine" CTA button.

#### F06.1 — Summary Stats Bar

Displayed as a horizontal strip of four stat tiles (stack 2×2 on narrow mobile if needed):

| Stat | Calculation |
|------|------------|
| **Total Bottles** | `SUM(quantity)` across all wine records where quantity > 0 |
| **Wine Records** | `COUNT(*)` of all wine records (including Cellar Empty records) |
| **Drink Now** | `COUNT(*)` of wine records with readiness_status = DRINK_NOW AND quantity > 0 |
| **Approaching Peak** | `COUNT(*)` of wine records with readiness_status = APPROACHING_PEAK AND quantity > 0 |

- Each stat tile is tappable: taps navigate to the Wine List filtered for that segment.
- Stats update on each app load; no manual refresh button required.

#### F06.2 — Drink Now Shelf

1. System queries all wine records where readiness_status = DRINK_NOW AND quantity > 0.
2. Results sorted by `drink_window_end` ascending (soonest expiring first). If `drink_window_end` is NULL (only start was set), sorted to the end of the shelf.
3. Up to 10 wines displayed on the shelf. "See all [N]" link navigates to the filtered wine list with Drink Now filter active.
4. Each shelf card displays: wine name, producer, vintage year, Drink Now badge, quantity, storage location.
5. If zero wines have DRINK_NOW status: shelf card shows "No wines are ready to drink right now." (card still visible, showing empty state, not hidden).
6. Shelf is horizontally scrollable on mobile; may display as a 2-column grid on desktop.

#### F06.3 — Collection Breakdown by Wine Type

1. System counts the sum of `quantity` for each wine type (RED, WHITE, ROSE, SPARKLING, DESSERT, FORTIFIED) across all wine records with quantity > 0.
2. Displayed as a vertical list of rows, each showing: type label, bottle count, percentage of total (rounded to nearest integer).
3. Types with zero bottles are shown with count = 0 (not hidden).
4. Tapping a type row navigates to Wine List filtered by that wine type.

#### F06.4 — Collection Breakdown by Country / Region

1. System groups wines by `country` (or `region` if country not set), sums `quantity` per group.
2. Displays the top 5 country/region groups by bottle count, descending.
3. An "Other" row shows the aggregate count of all remaining countries/regions not in the top 5 (if any).
4. Wines with no country or region set are grouped under "Unknown Origin."
5. Displayed as a vertical list: country/region name, bottle count, percentage of total.
6. Tapping a row navigates to Wine List filtered by that country (if country is set) or region.

#### F06.5 — Collection Breakdown by Vintage Decade

1. System groups wine records by vintage decade (e.g., 2010s = vintage 2010–2019), sums `quantity` per decade.
2. Displays all decades with at least one bottle, sorted by decade descending (most recent first).
3. Displayed as a bar or list: decade label (e.g., "2020s"), bottle count, simple proportional bar.
4. Tapping a decade row navigates to Wine List filtered by vintage range for that decade.

#### F06.6 — Recently Added

1. System queries the 5 wine records with the most recent `created_at`, regardless of quantity.
2. Displayed as a compact list: wine name, producer, vintage, wine type badge, date added (relative: "2 days ago").
3. Tapping a row navigates to the Wine Detail view for that wine.
4. "View all" link navigates to Wine List sorted by Date Added: Newest first.

#### F06.7 — Recently Consumed

1. System queries the 5 most recent `bottle_events` where `event_type = CONSUMED`, sorted by `event_date` descending.
2. Displayed as a compact list: wine name, producer, vintage, date consumed (relative).
3. Tapping a row navigates to the Wine Detail view for that wine.
4. If no consumed events exist: "No consumed bottles recorded yet."
5. "View all" navigates to Wine List filtered to show wines with any CONSUMED events.

#### F06.8 — Highest Rated

1. System queries wine records with at least one tasting note containing a `personal_rating`.
2. Sorted by `latest_rating` descending (ties broken by `latest_rating_date` descending — most recent rating wins the tie).
3. Top 5 displayed: wine name, producer, vintage, rating display (stars or numeric per user's scale preference).
4. If fewer than 5 rated wines exist, all rated wines are shown.
5. If no wines have ratings: card shows "Rate your wines to see your favorites here."
6. Tapping a row navigates to Wine Detail view for that wine.

---

### Inputs

All dashboard data is derived from existing wine records, bottle events, and tasting notes. No direct user input on the dashboard itself — it is a read-only aggregation view. The only user interaction is navigation (tapping cards to drill down).

| Source | Fields Used |
|--------|------------|
| `wines` table | `quantity`, `wine_type`, `country`, `region`, `vintage_year`, `drink_window_start`, `drink_window_end`, `created_at`, `storage_location_id`, `latest_rating` |
| `bottle_events` table | `event_type`, `event_date`, `wine_id` (for Recently Consumed) |
| `tasting_notes` table | `personal_rating`, `date_tasted`, `wine_id` (for Highest Rated) |
| System clock | `CURRENT_DATE` (for readiness status calculation) |

---

### Outputs

| Section | Output |
|---------|--------|
| Summary Stats Bar | 4 numeric tiles: total bottles, wine records, Drink Now count, Approaching Peak count |
| Drink Now Shelf | Up to 10 wine cards with readiness badges, sorted by end-year urgency |
| Breakdown by Type | 6 rows (one per wine type) with count and percentage |
| Breakdown by Region | Top 5 regions + "Other" row with count and percentage |
| Breakdown by Decade | All decades with bottles, sorted descending, with proportional bar |
| Recently Added | 5 wine records with name, producer, vintage, date added |
| Recently Consumed | 5 most recent CONSUMED events with wine name, date consumed |
| Highest Rated | Top 5 wines by rating with rating display |

---

### Validation Rules

- All calculations must use quantity > 0 for "active cellar" counts (Cellar Empty wines excluded from Total Bottles count, Drink Now count, Approaching Peak count, and Drink Now Shelf).
- Readiness status calculation: same algorithm as F05 §Process — no duplication allowed; F05 is the single source of truth for the calculation logic.
- If `latest_rating` is NULL (no rated notes), wine is excluded from Highest Rated.
- If collection is completely empty (no wine records at all), dashboard displays the onboarding empty state instead of all cards.
- Percentages in breakdown sections: calculated as `(group_count / total_bottles) * 100`, rounded to nearest integer. If rounding causes percentages to not sum to 100%, display as-is (cosmetic rounding tolerance accepted).

---

### Error States

| Scenario | Display |
|----------|---------|
| Empty collection | Onboarding empty state with "Add Wine" CTA |
| No Drink Now wines | Drink Now shelf shows empty state message |
| No rated wines | Highest Rated card shows "Rate your wines..." prompt |
| No consumed events | Recently Consumed shows "No consumed bottles recorded yet." |
| Data load failure | Each card shows "Unable to load. Pull to refresh." (graceful degradation) |

---

### API Surface (this feature)

See `Y1-api.md §F06 — Dashboard` for full response schemas.

| Method | Endpoint | Purpose |
|--------|----------|---------|
| GET | `/api/v1/dashboard` | Aggregate dashboard data (all sections in one response) |
| GET | `/api/v1/dashboard/stats` | Summary stats bar only (for lightweight polling if needed) |

The `/api/v1/dashboard` endpoint returns a single JSON object with all dashboard sections, minimizing round-trips. Alternatively, the client may assemble dashboard data from the existing `/api/v1/wines` and `/api/v1/wines/:id/events` endpoints with appropriate query parameters.

---

### Schema Surface (this feature)

No new tables introduced by this feature. All data is aggregated from:
- `wines` — see `Y0-schema.md §Wines`
- `bottle_events` — see `Y0-schema.md §BottleEvents`
- `tasting_notes` — see `Y0-schema.md §TastingNotes`

Dashboard queries are read-only. Performance target: dashboard API response ≤ 300ms for collections up to 500 records (per NFR).

---
---

## Y0: Database Schema

**Scope:** Full DDL for all entities used by SimpleWineApp v1 MVP. All entity names in `PascalCase`, column names in `snake_case`. Data types are database-agnostic; implement with the target engine's equivalent (PostgreSQL preferred).

**Conventions:**
- All primary keys are UUID v4 generated by the application layer (not auto-increment integers).
- All timestamps are `TIMESTAMPTZ` (UTC). Application sets `created_at` on insert; `updated_at` updated on every write.
- Soft delete is NOT used in v1; all deletes are hard deletes with cascade rules as noted.
- Enum types are implemented as `VARCHAR` with CHECK constraints (or native ENUM if supported) and validated at the application layer before insert.

---

### §Wines — `wines` Table

The core entity. One row per wine record in the user's collection.

```sql
CREATE TABLE wines (
  -- Identity
  wine_id             UUID          PRIMARY KEY DEFAULT gen_random_uuid(),
  wine_name           VARCHAR(200)  NOT NULL,
  producer            VARCHAR(200)  NOT NULL,
  vintage_year        INTEGER       NOT NULL
                        CHECK (vintage_year BETWEEN 1900 AND 2200),
  wine_type           VARCHAR(20)   NOT NULL
                        CHECK (wine_type IN ('RED','WHITE','ROSE','SPARKLING','DESSERT','FORTIFIED')),
  grape_variety       VARCHAR(200),
  country             VARCHAR(100),
  region              VARCHAR(100),
  appellation         VARCHAR(100),
  bottle_size         VARCHAR(10)   NOT NULL DEFAULT '750ML'
                        CHECK (bottle_size IN ('375ML','750ML','1500ML','3000ML')),

  -- Quantity & status
  quantity            INTEGER       NOT NULL DEFAULT 1
                        CHECK (quantity >= 0),
  is_open             BOOLEAN       NOT NULL DEFAULT FALSE,

  -- Storage
  storage_location_id UUID          REFERENCES storage_locations(location_id) ON DELETE SET NULL,
  location_unknown    BOOLEAN       NOT NULL DEFAULT FALSE,

  -- Acquisition
  purchase_date       DATE,
  purchase_source     VARCHAR(200),
  purchase_price      NUMERIC(10,2) CHECK (purchase_price >= 0),
  estimated_value     NUMERIC(10,2) CHECK (estimated_value >= 0),

  -- Drinking window
  drink_window_start  INTEGER       CHECK (drink_window_start BETWEEN 1900 AND 2200),
  drink_window_end    INTEGER       CHECK (drink_window_end BETWEEN 1900 AND 2200),
  CONSTRAINT chk_window_order CHECK (
    drink_window_start IS NULL OR drink_window_end IS NULL
    OR drink_window_start <= drink_window_end
  ),

  -- Notes
  notes               TEXT          CHECK (char_length(notes) <= 5000),

  -- Denormalized rating cache (updated by tasting_notes triggers/application logic)
  latest_rating       NUMERIC(5,1),
  latest_rating_scale VARCHAR(10)   CHECK (latest_rating_scale IN ('STARS_5','POINTS_100')),
  latest_rating_date  DATE,

  -- Metadata
  created_at          TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
  updated_at          TIMESTAMPTZ   NOT NULL DEFAULT NOW()
);

-- Indexes for common query patterns
CREATE INDEX idx_wines_wine_type       ON wines(wine_type);
CREATE INDEX idx_wines_vintage_year    ON wines(vintage_year);
CREATE INDEX idx_wines_country         ON wines(country);
CREATE INDEX idx_wines_region          ON wines(region);
CREATE INDEX idx_wines_storage_loc     ON wines(storage_location_id);
CREATE INDEX idx_wines_quantity        ON wines(quantity);
CREATE INDEX idx_wines_created_at      ON wines(created_at DESC);
CREATE INDEX idx_wines_latest_rating   ON wines(latest_rating DESC NULLS LAST);
CREATE INDEX idx_wines_drink_window    ON wines(drink_window_start, drink_window_end);
```

**Notes:**
- `quantity` has `CHECK (quantity >= 0)` — the application layer prevents decrement below zero, but the DB constraint is the safety net.
- `storage_location_id` is set to NULL (ON DELETE SET NULL) when the referenced location is deleted; `location_unknown` is set TRUE by the application at that time.
- `latest_rating`, `latest_rating_scale`, `latest_rating_date` are denormalized for query performance on the wine list. Updated by application logic whenever a tasting note is added, edited, or deleted.

---

### §StorageLocations — `storage_locations` Table

User-defined named physical storage locations.

```sql
CREATE TABLE storage_locations (
  location_id         UUID          PRIMARY KEY DEFAULT gen_random_uuid(),
  location_name       VARCHAR(100)  NOT NULL,
  CONSTRAINT uq_location_name UNIQUE (location_name),

  created_at          TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
  updated_at          TIMESTAMPTZ   NOT NULL DEFAULT NOW()
);
```

**Notes:**
- `UNIQUE` constraint on `location_name` enforces the no-duplicate-name rule. The application performs case-insensitive uniqueness checks before insert (since most databases' default UNIQUE constraint is case-sensitive; use `LOWER(location_name)` functional index on PostgreSQL).
- No foreign key cycle: `storage_locations` does not reference `wines`.

```sql
-- Case-insensitive uniqueness enforcement (PostgreSQL)
CREATE UNIQUE INDEX uq_location_name_ci ON storage_locations (LOWER(location_name));
```

---

### §BottleEvents — `bottle_events` Table

Log of all bottle lifecycle events (Consumed, Gifted, Opened) per wine record.

```sql
CREATE TABLE bottle_events (
  event_id            UUID          PRIMARY KEY DEFAULT gen_random_uuid(),
  wine_id             UUID          NOT NULL REFERENCES wines(wine_id) ON DELETE CASCADE,
  event_type          VARCHAR(10)   NOT NULL
                        CHECK (event_type IN ('CONSUMED','GIFTED','OPENED')),
  event_date          DATE          NOT NULL
                        CHECK (event_date <= CURRENT_DATE),
  notes               VARCHAR(500),
  recipient           VARCHAR(200),  -- GIFTED events only
  tasting_note_id     UUID,          -- FK set after tasting note is created (nullable)

  created_at          TIMESTAMPTZ   NOT NULL DEFAULT NOW()
);

-- Add FK after tasting_notes table is created
ALTER TABLE bottle_events
  ADD CONSTRAINT fk_bottle_events_tasting_note
  FOREIGN KEY (tasting_note_id) REFERENCES tasting_notes(note_id) ON DELETE SET NULL;

CREATE INDEX idx_bottle_events_wine_id    ON bottle_events(wine_id);
CREATE INDEX idx_bottle_events_event_date ON bottle_events(event_date DESC);
CREATE INDEX idx_bottle_events_event_type ON bottle_events(event_type);
```

**Notes:**
- CASCADE DELETE: when a wine record is deleted, all its bottle events are deleted.
- `tasting_note_id` is a nullable FK — set after the associated tasting note is created (to handle the create-then-link flow). `ON DELETE SET NULL` means deleting a tasting note does not delete the bottle event.
- `event_date CHECK (event_date <= CURRENT_DATE)` enforces no future-dated events at DB level.

---

### §TastingNotes — `tasting_notes` Table

Personal tasting records linked to a wine. Multiple notes per wine allowed.

```sql
CREATE TABLE tasting_notes (
  note_id             UUID          PRIMARY KEY DEFAULT gen_random_uuid(),
  wine_id             UUID          NOT NULL REFERENCES wines(wine_id) ON DELETE CASCADE,
  bottle_event_id     UUID          REFERENCES bottle_events(event_id) ON DELETE SET NULL,

  date_tasted         DATE          NOT NULL
                        CHECK (date_tasted <= CURRENT_DATE),
  appearance          VARCHAR(500),
  aroma               VARCHAR(500),
  flavor              TEXT          CHECK (char_length(flavor) <= 1000),
  finish              VARCHAR(500),
  personal_rating     NUMERIC(5,1),
  rating_scale        VARCHAR(10)   CHECK (rating_scale IN ('STARS_5','POINTS_100')),
  would_buy_again     VARCHAR(5)    CHECK (would_buy_again IN ('YES','NO','MAYBE')),
  occasion            VARCHAR(200),
  guest_feedback      VARCHAR(500),

  created_at          TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
  updated_at          TIMESTAMPTZ   NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_tasting_notes_wine_id    ON tasting_notes(wine_id);
CREATE INDEX idx_tasting_notes_date       ON tasting_notes(date_tasted DESC);
CREATE INDEX idx_tasting_notes_rating     ON tasting_notes(personal_rating DESC NULLS LAST);
```

**Notes:**
- CASCADE DELETE: when a wine record is deleted, all its tasting notes are deleted.
- `bottle_event_id` is nullable (standalone notes have no linked event). `ON DELETE SET NULL` — deleting the bottle event does not delete the note.
- `personal_rating` is stored as-entered in the note's scale (`rating_scale` records which scale was used). No conversion performed on scale change.
- After any insert/update/delete on `tasting_notes`, application logic must refresh the `latest_rating`, `latest_rating_scale`, and `latest_rating_date` on the parent `wines` row.

---

### §UserSettings — `user_settings` Table

Singleton table for user-level application preferences (single-user app in v1).

```sql
CREATE TABLE user_settings (
  settings_id         UUID          PRIMARY KEY DEFAULT gen_random_uuid(),
  rating_scale        VARCHAR(10)   NOT NULL DEFAULT 'STARS_5'
                        CHECK (rating_scale IN ('STARS_5','POINTS_100')),

  created_at          TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
  updated_at          TIMESTAMPTZ   NOT NULL DEFAULT NOW()
);

-- Seed the single settings row on first run
INSERT INTO user_settings (rating_scale) VALUES ('STARS_5')
  ON CONFLICT DO NOTHING;
```

**Notes:**
- Single-user MVP: only one row expected. Application always reads/updates this single row.
- `rating_scale` controls the display and validation of `personal_rating` across all tasting notes.

---

### Entity Relationship Summary

```
storage_locations
  └─< wines (storage_location_id FK, SET NULL on delete)
        └─< bottle_events (wine_id FK, CASCADE on delete)
        │     └── tasting_notes (bottle_event_id FK, SET NULL on delete)
        └─< tasting_notes (wine_id FK, CASCADE on delete)

user_settings (standalone singleton)
```

---
---

## Y1: REST API Endpoints

**Base URL:** `/api/v1`
**Format:** All requests and responses use `application/json`.
**Authentication:** Single-user app in v1 — no auth layer required in MVP. If a session cookie or local token is introduced, all endpoints should validate it; this is a Phase 2 concern.
**Errors:** All error responses follow the structure in `Y2-errors.md §Error Response Format`.
**Calculated fields:** `readiness_status` is computed server-side at response time using `CURRENT_DATE`. Never cache or persist this field.
**Timestamps:** All `created_at` and `updated_at` values are ISO 8601 UTC strings (e.g., `"2026-06-03T14:32:00Z"`).

---

### §F00 — Wine Inventory

#### `GET /api/v1/wines`

List all wine records with optional filtering, searching, and sorting (see F03).

**Query Parameters:**

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `q` | string | — | Full-text search across name, producer, region, grape |
| `wine_type` | string | — | Comma-separated enum values (e.g., `RED,WHITE`) |
| `producer` | string | — | Exact match (case-insensitive) |
| `country` | string | — | Exact match (case-insensitive) |
| `region` | string | — | Exact match (case-insensitive) |
| `vintage_from` | integer | — | Vintage year range start (inclusive) |
| `vintage_to` | integer | — | Vintage year range end (inclusive) |
| `grape_variety` | string | — | Substring match |
| `location_id` | string | — | UUID or `"unknown"` for Location Unknown |
| `readiness` | string | — | Comma-separated: DRINK_NOW, APPROACHING_PEAK, HOLD, PAST_WINDOW, NO_WINDOW_SET |
| `rating_min` | number | — | Min latest rating (inclusive) |
| `rating_max` | number | — | Max latest rating (inclusive) |
| `sort` | string | `created_at_desc` | Sort key (see F03 sort options) |

**Response: `200 OK`**

```json
{
  "data": [
    {
      "wine_id": "uuid",
      "wine_name": "Château Margaux",
      "producer": "Château Margaux",
      "vintage_year": 2015,
      "wine_type": "RED",
      "grape_variety": "Cabernet Sauvignon, Merlot",
      "country": "France",
      "region": "Bordeaux",
      "appellation": "Margaux AOC",
      "bottle_size": "750ML",
      "quantity": 3,
      "is_open": false,
      "storage_location_id": "uuid",
      "storage_location_name": "Wine Fridge – Bottom Shelf",
      "location_unknown": false,
      "purchase_date": "2022-04-15",
      "purchase_source": "Wine.com",
      "purchase_price": 650.00,
      "estimated_value": 720.00,
      "drink_window_start": 2025,
      "drink_window_end": 2045,
      "readiness_status": "DRINK_NOW",
      "notes": "Exceptional vintage.",
      "latest_rating": 4.5,
      "latest_rating_scale": "STARS_5",
      "latest_rating_date": "2026-01-10",
      "created_at": "2022-04-16T10:00:00Z",
      "updated_at": "2026-01-10T20:00:00Z"
    }
  ],
  "meta": {
    "total": 42,
    "filtered": 12
  }
}
```

---

#### `POST /api/v1/wines`

Create a new wine record.

**Request Body:**

```json
{
  "wine_name": "Château Margaux",
  "producer": "Château Margaux",
  "vintage_year": 2015,
  "wine_type": "RED",
  "grape_variety": "Cabernet Sauvignon, Merlot",
  "country": "France",
  "region": "Bordeaux",
  "appellation": "Margaux AOC",
  "bottle_size": "750ML",
  "quantity": 3,
  "storage_location_id": "uuid",
  "purchase_date": "2022-04-15",
  "purchase_source": "Wine.com",
  "purchase_price": 650.00,
  "estimated_value": 720.00,
  "drink_window_start": 2025,
  "drink_window_end": 2045,
  "notes": "Exceptional vintage."
}
```

**Response: `201 Created`** — full wine record object (same shape as GET /wines item)

---

#### `GET /api/v1/wines/:wine_id`

Get single wine record by ID.

**Response: `200 OK`** — single wine record object (full shape as above)

**Error: `404 Not Found`** — `WINE_NOT_FOUND`

---

#### `PUT /api/v1/wines/:wine_id`

Full update of a wine record. All required fields must be provided.

**Request Body:** Same as POST.

**Response: `200 OK`** — updated wine record object.

---

#### `PATCH /api/v1/wines/:wine_id`

Partial update. Only provided fields are updated.

**Request Body:** Any subset of POST fields.

**Response: `200 OK`** — updated wine record object.

---

#### `DELETE /api/v1/wines/:wine_id`

Delete a wine record and all associated tasting notes and bottle events (cascade).

**Response: `204 No Content`**

**Error: `404 Not Found`** — `WINE_NOT_FOUND`

---

### §F01 — Bottle Events

#### `POST /api/v1/wines/:wine_id/events`

Log a bottle event.

**Request Body:**

```json
{
  "event_type": "CONSUMED",
  "event_date": "2026-06-03",
  "notes": "Opened for anniversary dinner.",
  "recipient": null
}
```

**Response: `201 Created`**

```json
{
  "event_id": "uuid",
  "wine_id": "uuid",
  "event_type": "CONSUMED",
  "event_date": "2026-06-03",
  "notes": "Opened for anniversary dinner.",
  "recipient": null,
  "tasting_note_id": null,
  "created_at": "2026-06-03T19:00:00Z"
}
```

**Error: `422 Unprocessable Entity`** — `QUANTITY_EMPTY` (CONSUMED or GIFTED when quantity = 0)

---

#### `GET /api/v1/wines/:wine_id/events`

Get all bottle events for a wine, sorted by `event_date` descending.

**Response: `200 OK`**

```json
{
  "data": [
    {
      "event_id": "uuid",
      "wine_id": "uuid",
      "event_type": "CONSUMED",
      "event_date": "2026-06-03",
      "notes": "Anniversary dinner.",
      "recipient": null,
      "tasting_note_id": "uuid",
      "created_at": "2026-06-03T19:00:00Z"
    }
  ]
}
```

---

#### `PATCH /api/v1/wines/:wine_id/quantity`

Directly adjust quantity by +1 or −1 without logging an event (for the +/− UI controls).

**Request Body:**

```json
{
  "adjustment": 1
}
```

`adjustment` must be `1` or `-1`. System rejects `−1` when current quantity = 0.

**Response: `200 OK`**

```json
{
  "wine_id": "uuid",
  "quantity": 4
}
```

---

### §F02 — Storage Locations

#### `GET /api/v1/locations`

List all storage locations with bottle counts.

**Response: `200 OK`**

```json
{
  "data": [
    {
      "location_id": "uuid",
      "location_name": "Wine Fridge – Top Shelf",
      "bottle_count": 12,
      "created_at": "2026-01-01T00:00:00Z",
      "updated_at": "2026-01-01T00:00:00Z"
    }
  ]
}
```

---

#### `POST /api/v1/locations`

Create a new storage location.

**Request Body:** `{ "location_name": "Basement Cellar" }`

**Response: `201 Created`** — full location object (without bottle_count on create).

**Error: `422`** — `DUPLICATE_LOCATION` if name already exists.

---

#### `PUT /api/v1/locations/:location_id`

Rename a storage location.

**Request Body:** `{ "location_name": "Basement Cellar – Rack A" }`

**Response: `200 OK`** — updated location object.

---

#### `DELETE /api/v1/locations/:location_id`

Delete a location. All wines assigned to it have `storage_location_id` set to NULL and `location_unknown` set to TRUE.

**Response: `200 OK`**

```json
{
  "deleted_location_id": "uuid",
  "affected_wines_count": 5
}
```

---

### §F04 — Tasting Notes

#### `GET /api/v1/wines/:wine_id/tasting-notes`

List all tasting notes for a wine, sorted by `date_tasted` descending.

**Response: `200 OK`**

```json
{
  "data": [
    {
      "note_id": "uuid",
      "wine_id": "uuid",
      "bottle_event_id": "uuid",
      "date_tasted": "2026-06-03",
      "appearance": "Deep ruby with violet hints.",
      "aroma": "Blackcurrant, cedar, tobacco.",
      "flavor": "Full-bodied with firm tannins, layers of dark fruit.",
      "finish": "Long, velvety finish.",
      "personal_rating": 4.5,
      "rating_scale": "STARS_5",
      "would_buy_again": "YES",
      "occasion": "Anniversary dinner",
      "guest_feedback": "Guests loved it.",
      "created_at": "2026-06-03T21:00:00Z",
      "updated_at": "2026-06-03T21:00:00Z"
    }
  ]
}
```

---

#### `POST /api/v1/wines/:wine_id/tasting-notes`

Add a tasting note to a wine.

**Request Body:** All tasting note fields (only `date_tasted` required; see F04 Inputs for full list).

**Response: `201 Created`** — full tasting note object.

---

#### `PUT /api/v1/wines/:wine_id/tasting-notes/:note_id`

Update a tasting note.

**Request Body:** All fields (full replace).

**Response: `200 OK`** — updated tasting note object.

---

#### `DELETE /api/v1/wines/:wine_id/tasting-notes/:note_id`

Delete a tasting note.

**Response: `204 No Content`**

---

#### `GET /api/v1/settings/rating-scale`

Get rating scale preference.

**Response: `200 OK`** `{ "rating_scale": "STARS_5" }`

---

#### `PUT /api/v1/settings/rating-scale`

Set rating scale preference.

**Request Body:** `{ "rating_scale": "POINTS_100" }` (must be `"STARS_5"` or `"POINTS_100"`)

**Response: `200 OK`** `{ "rating_scale": "POINTS_100" }`

---

### §F06 — Dashboard

#### `GET /api/v1/dashboard`

Aggregate dashboard data in a single response.

**Response: `200 OK`**

```json
{
  "stats": {
    "total_bottles": 87,
    "total_wine_records": 34,
    "drink_now_count": 8,
    "approaching_peak_count": 5
  },
  "drink_now_shelf": [
    {
      "wine_id": "uuid",
      "wine_name": "Opus One",
      "producer": "Opus One Winery",
      "vintage_year": 2018,
      "wine_type": "RED",
      "quantity": 2,
      "storage_location_name": "Wine Fridge",
      "drink_window_end": 2028,
      "readiness_status": "DRINK_NOW"
    }
  ],
  "breakdown_by_type": [
    { "wine_type": "RED", "bottle_count": 52, "percentage": 60 },
    { "wine_type": "WHITE", "bottle_count": 20, "percentage": 23 },
    { "wine_type": "ROSE", "bottle_count": 5, "percentage": 6 },
    { "wine_type": "SPARKLING", "bottle_count": 7, "percentage": 8 },
    { "wine_type": "DESSERT", "bottle_count": 2, "percentage": 2 },
    { "wine_type": "FORTIFIED", "bottle_count": 1, "percentage": 1 }
  ],
  "breakdown_by_region": [
    { "label": "Bordeaux, France", "bottle_count": 24, "percentage": 28 },
    { "label": "Napa Valley, USA", "bottle_count": 18, "percentage": 21 }
  ],
  "breakdown_by_decade": [
    { "decade": "2020s", "bottle_count": 30 },
    { "decade": "2010s", "bottle_count": 45 },
    { "decade": "2000s", "bottle_count": 12 }
  ],
  "recently_added": [
    {
      "wine_id": "uuid",
      "wine_name": "Barolo Riserva",
      "producer": "Giacomo Conterno",
      "vintage_year": 2016,
      "wine_type": "RED",
      "created_at": "2026-06-01T12:00:00Z"
    }
  ],
  "recently_consumed": [
    {
      "event_id": "uuid",
      "wine_id": "uuid",
      "wine_name": "Château Pétrus",
      "producer": "Pétrus",
      "vintage_year": 2010,
      "event_date": "2026-05-28"
    }
  ],
  "highest_rated": [
    {
      "wine_id": "uuid",
      "wine_name": "Screaming Eagle",
      "producer": "Screaming Eagle Winery",
      "vintage_year": 2019,
      "latest_rating": 5.0,
      "latest_rating_scale": "STARS_5",
      "latest_rating_date": "2026-03-15"
    }
  ]
}
```

---

#### `GET /api/v1/dashboard/stats`

Summary stats only (lightweight endpoint for stat bar updates).

**Response: `200 OK`**

```json
{
  "total_bottles": 87,
  "total_wine_records": 34,
  "drink_now_count": 8,
  "approaching_peak_count": 5
}
```

---
---

## Y2: Cross-Feature Error Catalog

**Scope:** All error scenarios across F00–F06, consolidated with HTTP status codes, error codes, user-facing messages, and developer notes.

---

### Error Response Format

All API errors use a consistent JSON envelope:

```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Wine name is required.",
    "field": "wine_name",
    "details": []
  }
}
```

| Field | Type | Description |
|-------|------|-------------|
| `code` | string | Machine-readable error code (UPPER_SNAKE_CASE) |
| `message` | string | Human-readable error message for display or logging |
| `field` | string | (Optional) The specific input field that caused the error |
| `details` | array | (Optional) Array of sub-errors for multi-field validation failures |

**Multi-field validation response example:**

```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "One or more fields failed validation.",
    "field": null,
    "details": [
      { "field": "wine_name", "message": "Wine name is required." },
      { "field": "vintage_year", "message": "Vintage must be between 1900 and 2027." }
    ]
  }
}
```

---

### HTTP Status Code Summary

| Status | Meaning | When Used |
|--------|---------|-----------|
| 200 OK | Success (read / update) | GET, PUT, PATCH, DELETE with body |
| 201 Created | Resource created | POST |
| 204 No Content | Success, no body | DELETE |
| 400 Bad Request | Malformed request (e.g., invalid JSON, wrong content-type) | Any |
| 404 Not Found | Resource does not exist | Any by-ID endpoint |
| 409 Conflict | Duplicate / uniqueness violation | POST to locations |
| 422 Unprocessable Entity | Business rule / validation failure | Any write |
| 500 Internal Server Error | Unexpected server error | Any |

---

### F00 — Wine Inventory Errors

| Error Code | HTTP | Field | Message | Notes |
|-----------|------|-------|---------|-------|
| `WINE_NOT_FOUND` | 404 | — | "Wine record not found." | wine_id does not exist |
| `VALIDATION_ERROR` | 422 | `wine_name` | "Wine name is required." | null or empty |
| `VALIDATION_ERROR` | 422 | `producer` | "Producer is required." | null or empty |
| `VALIDATION_ERROR` | 422 | `vintage_year` | "Vintage must be between 1900 and [current+1]." | out of range or non-integer |
| `VALIDATION_ERROR` | 422 | `wine_type` | "Wine type must be one of: Red, White, Rosé, Sparkling, Dessert, Fortified." | invalid enum |
| `VALIDATION_ERROR` | 422 | `quantity` | "Quantity must be at least 1." | < 1 or non-integer |
| `VALIDATION_ERROR` | 422 | `storage_location_id` | "Storage location is required." | null |
| `INVALID_REFERENCE` | 422 | `storage_location_id` | "The selected storage location no longer exists. Please choose another." | references deleted location |
| `VALIDATION_ERROR` | 422 | `drink_window_start` | "Drinking window year must be between 1900 and 2200." | out of range |
| `VALIDATION_ERROR` | 422 | `drink_window_end` | "Drinking window year must be between 1900 and 2200." | out of range |
| `VALIDATION_ERROR` | 422 | `drink_window_start` | "Drink by start year must be before or equal to end year." | start > end |
| `VALIDATION_ERROR` | 422 | `purchase_date` | "Purchase date cannot be in the future." | date > today |
| `VALIDATION_ERROR` | 422 | `notes` | "Notes must be 5000 characters or fewer." | exceeds max |
| `VALIDATION_ERROR` | 422 | `bottle_size` | "Bottle size must be one of: 375ml, 750ml, 1.5L, 3L." | invalid enum |

---

### F01 — Bottle Event Errors

| Error Code | HTTP | Field | Message | Notes |
|-----------|------|-------|---------|-------|
| `QUANTITY_EMPTY` | 422 | — | "No bottles remain in the cellar for this wine." | CONSUMED or GIFTED when quantity = 0 |
| `VALIDATION_ERROR` | 422 | `event_type` | "Event type must be Consumed, Gifted, or Opened." | invalid enum |
| `VALIDATION_ERROR` | 422 | `event_date` | "Event date is required." | null |
| `VALIDATION_ERROR` | 422 | `event_date` | "Event date cannot be in the future." | date > today |
| `VALIDATION_ERROR` | 422 | `notes` | "Notes must be 500 characters or fewer." | exceeds max |
| `VALIDATION_ERROR` | 422 | `recipient` | "Recipient must be 200 characters or fewer." | exceeds max |
| `VALIDATION_ERROR` | 422 | `adjustment` | "Adjustment must be +1 or -1." | invalid PATCH value |
| `QUANTITY_FLOOR` | 422 | `adjustment` | "Quantity cannot go below zero." | decrement at 0 |
| `WINE_NOT_FOUND` | 404 | — | "Wine record not found." | wine_id does not exist |

---

### F02 — Storage Location Errors

| Error Code | HTTP | Field | Message | Notes |
|-----------|------|-------|---------|-------|
| `VALIDATION_ERROR` | 422 | `location_name` | "Location name is required." | null or empty |
| `VALIDATION_ERROR` | 422 | `location_name` | "Location name must be 100 characters or fewer." | exceeds max |
| `DUPLICATE_LOCATION` | 409 | `location_name` | "A location with that name already exists." | case-insensitive dup check |
| `LOCATION_NOT_FOUND` | 404 | — | "Storage location not found." | location_id does not exist |

---

### F04 — Tasting Note Errors

| Error Code | HTTP | Field | Message | Notes |
|-----------|------|-------|---------|-------|
| `NOTE_NOT_FOUND` | 404 | — | "Tasting note not found." | note_id does not exist |
| `VALIDATION_ERROR` | 422 | `date_tasted` | "Tasting date is required." | null |
| `VALIDATION_ERROR` | 422 | `date_tasted` | "Tasting date cannot be in the future." | date > today |
| `VALIDATION_ERROR` | 422 | `personal_rating` | "Rating must be between 1 and 5." | 5-star out of range |
| `VALIDATION_ERROR` | 422 | `personal_rating` | "Rating must be between 1 and 100." | 100-point out of range |
| `VALIDATION_ERROR` | 422 | `would_buy_again` | "Would-buy-again must be Yes, No, or Maybe." | invalid enum |
| `INVALID_REFERENCE` | 422 | `bottle_event_id` | "Linked bottle event not found or is not a Consumed event." | wrong type or missing |
| `VALIDATION_ERROR` | 422 | `appearance` | "Appearance must be 500 characters or fewer." | exceeds max |
| `VALIDATION_ERROR` | 422 | `aroma` | "Aroma must be 500 characters or fewer." | exceeds max |
| `VALIDATION_ERROR` | 422 | `flavor` | "Flavor must be 1000 characters or fewer." | exceeds max |
| `VALIDATION_ERROR` | 422 | `finish` | "Finish must be 500 characters or fewer." | exceeds max |
| `VALIDATION_ERROR` | 422 | `guest_feedback` | "Guest feedback must be 500 characters or fewer." | exceeds max |
| `VALIDATION_ERROR` | 422 | `occasion` | "Occasion must be 200 characters or fewer." | exceeds max |
| `VALIDATION_ERROR` | 422 | `rating_scale` | "Rating scale must be STARS_5 or POINTS_100." | invalid settings value |

---

### F03 — Search & Filter Errors

| Error Code | HTTP | Field | Message | Notes |
|-----------|------|-------|---------|-------|
| `VALIDATION_ERROR` | 422 | `vintage_from` | "Start year must be before or equal to end year." | vintage_from > vintage_to |
| `VALIDATION_ERROR` | 422 | `rating_min` | "Min rating must be less than or equal to max rating." | rating_min > rating_max |

> Filter errors in the UI are shown as inline messages on the filter panel. API filter parameter errors return `422`.

---

### Global / Infrastructure Errors

| Error Code | HTTP | Message | Notes |
|-----------|------|---------|-------|
| `INTERNAL_SERVER_ERROR` | 500 | "An unexpected error occurred. Please try again." | Uncaught server exceptions |
| `BAD_REQUEST` | 400 | "Invalid request format. Expected JSON." | Malformed JSON or wrong Content-Type |
| `METHOD_NOT_ALLOWED` | 405 | "HTTP method not allowed for this endpoint." | Wrong HTTP verb |
| `NOT_FOUND` | 404 | "Endpoint not found." | Unmapped route |

---

### UI Error Display Guidelines

| Severity | UI Pattern |
|----------|-----------|
| Field validation error | Inline red text beneath the field; field border changes to error color; `aria-describedby` links input to error text |
| Form-level error | Error summary at the top of the form listing all failed fields; links to each field |
| Destructive action confirmation | Modal dialog with explicit confirmation required before proceeding |
| Toast notification (success) | Non-blocking toast at bottom of screen; auto-dismisses after 3 seconds |
| Toast notification (error) | Non-blocking toast with persistent close button; does not auto-dismiss |
| Empty state (no data) | Centered illustration + message + primary action CTA |
| Data load failure | Card-level error state with "Pull to refresh" or retry button |

---
---

## Y3: External Integration Points

**Scope:** All external system dependencies, third-party services, and external data sources for SimpleWineApp v1 MVP.

---

### Summary

SimpleWineApp v1 is deliberately minimal in external dependencies. The single-user personal-use MVP has **no required external integrations** — all data is user-entered and stored locally or in a self-controlled data store. This is a design principle from the PRD: *"No user data sent to third-party analytics or external services in v1."*

The integrations documented here are:
1. **Required infrastructure dependencies** (hosting, data store, browser APIs)
2. **UI/asset dependencies** (fonts, design system)
3. **Explicitly deferred integrations** (documented to prevent scope creep)

---

### §1 — Required Infrastructure

#### §1.1 — Data Storage

| Property | Specification |
|----------|--------------|
| **Type** | Persistent relational data store |
| **Preferred** | PostgreSQL (see `Y0-schema.md` for DDL) |
| **Alternative** | SQLite (for local desktop/offline deployment), IndexedDB (browser-local PWA variant) |
| **Architecture** | TBD in TechArch; schema is storage-engine-agnostic except where PostgreSQL-specific syntax is noted |
| **Data residency** | User's own infrastructure or a self-hosted instance; no third-party SaaS database in v1 |
| **Backup** | Application does not manage backups in v1; responsibility falls to the infrastructure layer |

#### §1.2 — Web Hosting / Deployment

| Property | Specification |
|----------|--------------|
| **Type** | Static web host + API server (or unified server-rendered app) |
| **Target** | Any standard web hosting environment capable of running the chosen application stack |
| **CDN** | Optional; no CDN-specific dependencies in the application code |
| **HTTPS** | Required for production deployment; enforced by hosting layer |

---

### §2 — UI & Asset Dependencies

#### §2.1 — USWDS (U.S. Web Design System)

| Property | Specification |
|----------|--------------|
| **Source** | [https://designsystem.digital.gov](https://designsystem.digital.gov) |
| **Version** | Latest stable release at project start (pin version in package.json) |
| **Delivery** | Bundled with the application; NOT loaded from CDN (privacy and offline requirement) |
| **Usage** | CSS design tokens, component markup patterns, grid system, form components, accessibility patterns |
| **Customization** | TechSur brand tokens override USWDS default tokens via a CSS override layer (see `00-header.md §Brand & Design Token Reference`) |

#### §2.2 — Google Fonts (Typography)

| Property | Specification |
|----------|--------------|
| **Fonts required** | Montserrat (weights 700, 900), Fraunces (weights 400–600, italic), Open Sans (weights 400, 600, 700), JetBrains Mono (weights 400, 500) |
| **Delivery** | Self-hosted font files bundled with application (NOT loaded from Google Fonts CDN — privacy requirement: no user data sent to external services) |
| **Fallback stack** | Montserrat → system-ui → sans-serif; JetBrains Mono → Courier New → monospace |
| **Format** | WOFF2 (primary), WOFF (fallback) |
| **License** | Verify open font licenses for all four families at project start (all are OFL as of this writing) |

---

### §3 — Browser & Device APIs

#### §3.1 — Browser Storage (Offline Support)

| Property | Specification |
|----------|--------------|
| **Requirement** | Core wine list read and search functional offline (progressive enhancement) |
| **Mechanism** | Service Worker + Cache API (for static assets and wine list data) or localStorage/IndexedDB for wine data cache |
| **Scope** | Read-only offline in v1 — no offline write required |
| **Implementation** | TBD in TechArch; service worker registration is application-layer concern |

#### §3.2 — Date & Time

| Property | Specification |
|----------|--------------|
| **Source** | System clock (`Date` object or server-side `NOW()`) |
| **Timezone handling** | All stored timestamps in UTC; drinking window comparison uses UTC calendar year; display dates may render in user's local timezone |
| **No external NTP** | Application trusts the host system clock; no external time-sync service |

---

### §4 — Explicitly Deferred Integrations (Out of Scope for v1)

The following integrations are explicitly excluded from v1 and must not be added without a new PRD revision and approval:

| Integration | Phase | Reason Deferred |
|-------------|-------|----------------|
| External wine database (Wine Searcher, Vivino, Wine API) | Phase 3 | Adds complexity, potential costs, external data dependency; personal entry is proven first |
| Label scanning / OCR (camera + ML) | Phase 3 | Requires native device APIs, third-party ML service, significant UX complexity |
| AI-assisted bottle entry | Phase 3 | Depends on label scanning or external wine database; LLM API cost and latency management out of MVP scope |
| Push notifications / alerts | Phase 2 | Drinking window alerts require notification permission; deferred after MVP proves base workflow |
| CSV / Excel import | Phase 2 | Non-trivial parsing and error handling; deferred until core CRUD is proven |
| PDF / spreadsheet export | Phase 2 | Low-priority future scope |
| Third-party analytics (Google Analytics, Mixpanel, etc.) | Not in v1 | Explicitly prohibited: "No user data sent to third-party analytics or external services in v1" (PRD §8 Non-Functional Requirements) |
| Authentication providers (OAuth, SAML, Azure AD) | Phase 2+ | Single-user app in v1; no auth layer required |
| Shared household accounts | Phase 4 | Multi-user architecture change; deferred per PRD |
| Wine valuation APIs | Phase 2 | Estimated value is user-entered in v1 |
| Cellar / storage map visualization | Phase 2 | 2D/3D visualization deferred; storage by name is sufficient for v1 |

---

### §5 — Privacy & Data Sovereignty

Per PRD §8 (Non-Functional Requirements):

- **No telemetry:** The application must not send any user data to third-party analytics, crash reporting, or monitoring services in v1. Server-side error logging is acceptable if it is self-hosted and does not transmit to external endpoints.
- **No CDN font loading:** Fonts must be self-hosted to prevent Google Fonts / CDN from logging user IP addresses.
- **No external API calls from the client:** All application functionality in v1 must be fulfilled from the application's own backend. No client-side API calls to external wine databases, pricing services, or any third-party endpoint.
- **Data residency:** User wine data must remain within the user's chosen deployment environment (local or self-hosted cloud). No mandatory cloud sync to external services.

---

*Y3 integrations catalog · SimpleWineApp v1.0 MVP · 2026-06-03*
