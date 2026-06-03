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
