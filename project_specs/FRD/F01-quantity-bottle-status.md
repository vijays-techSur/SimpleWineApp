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
